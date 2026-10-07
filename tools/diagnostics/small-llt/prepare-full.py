"""Extend the existing phase probe with setup/copy and explicit m/process."""
from pathlib import Path
root=Path(__file__).resolve().parents[3]
s=(root/'tools/diagnostics/assembly-gap/phases.cpp').read_text()
s=s.replace('auto f=kibo::tests::performance_fixture(n*4,n);','std::size_t m=argc>3?std::atoi(argv[3]):n*4;\n int process=argc>4?std::atoi(argv[4]):0;\n auto f=kibo::tests::performance_fixture(m,n);')
s=s.replace('phase<3','phase<4')
s=s.replace('auto core=[&]{if(phase!=1', '''auto core=[&]{
    if (phase==3) {
      auto copied=input;
      std::vector<double> packed(n*n),work(n),answer(n);
      auto source=MatrixView<const double>::checked(std::span<const double>(copied.data(),copied.size()),n,n,n).value();
      auto target=MatrixView<double>::checked(packed,n,n,n).value();
      auto factored=factorize_llt(source,target);
      if(!factored||!solve_into(factored.value(),std::span<const double>(b.data(),n),answer,std::as_writable_bytes(std::span<double>(work))))return false;
      solution=std::move(answer);consumed=solution[0];return true;
    }
    if(phase!=1''')
s=s.replace('auto ref=[&]{if(phase!=1', '''auto ref=[&]{
    if (phase==3) {
      Eigen::MatrixXd copied=input;
      Eigen::LLT<Eigen::MatrixXd> temporary(copied);
      Eigen::VectorXd answer=temporary.solve(b);
      if(temporary.info()!=Eigen::Success)return false;
      esolution=std::move(answer);consumed=esolution[0];return true;
    }
    if(phase!=1''')
s=s.replace('if(sample%2)','if((sample+process)%2)')
# Include identity in each raw sample without changing the existing phase probe.
s=s.replace('\\"phase\\":%d,\\"n\\":%zu','\\"phase\\":%d,\\"n\\":%zu,\\"m\\":%zu,\\"process\\":%d')
s=s.replace('phase,n,sample,batch','phase,n,m,process,sample,batch')
s=s.replace('if(c<0||e<0||!valid())return 6;',
    'if(c<0||e<0||!(phase==0?valid():((Eigen::Map<Eigen::VectorXd>(solution.data(),n)-expected).norm()/expected.norm()<1e-8&&(esolution-expected).norm()/expected.norm()<1e-8)))return 6;')
s=s.replace('volatile double consumed=0;', '''volatile double consumed=0;
std::uint64_t input_hash(const kibo::tests::RowMatrix& a,const Eigen::VectorXd& b) {
 std::uint64_t h=14695981039346656037ULL;
 const auto append=[&](std::uint64_t v){for(int i=0;i<8;++i){h^=(v>>(8*i))&255;h*=1099511628211ULL;}};
 append(a.rows());append(a.cols());
 for(Eigen::Index i=0;i<a.size();++i)append(std::bit_cast<std::uint64_t>(a.data()[i]));
 for(Eigen::Index i=0;i<b.size();++i)append(std::bit_cast<std::uint64_t>(b[i]));
 return h;
}''')
s=s.replace('phase,n,m,process,sample,batch,c/batch,e/batch,std::min(c,e)',
            'phase,n,m,process,sample,batch,c/batch,e/batch,std::min(c,e),static_cast<unsigned long long>(input_hash(input,b)),Eigen::internal::packet_traits<double>::size,probe_core_type()')
s=s.replace('\\"minBatch\\":%.17g}', '\\"minBatch\\":%.17g,\\"inputHash\\":\\"%016llx\\",\\"packetWidth\\":%d,\\"coreType\\":%u}')
(root/'tools/diagnostics/small-llt/full.cpp').write_text(s,encoding='utf-8')
print('Prepared full.cpp')
