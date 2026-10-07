#include <kibo/llt.hpp>
#include <Eigen/Cholesky>
#include "controlled_fixture.hpp"
#include "../../tools/diagnostics/solver-locality/affinity.hpp"
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <memory>
using namespace kibo::linalg;
volatile double consumed=0;
std::uint64_t input_hash(const kibo::tests::RowMatrix& a,const Eigen::VectorXd& b) {
 std::uint64_t h=14695981039346656037ULL;
 const auto append=[&](std::uint64_t v){for(int i=0;i<8;++i){h^=(v>>(8*i))&255;h*=1099511628211ULL;}};
 append(a.rows());append(a.cols());
 for(Eigen::Index i=0;i<a.size();++i)append(std::bit_cast<std::uint64_t>(a.data()[i]));
 for(Eigen::Index i=0;i<b.size();++i)append(std::bit_cast<std::uint64_t>(b[i]));
 return h;
}
int main(int argc,char** argv){
 if(!pin_probe()||probe_core_type()!=64)return 2;
 std::size_t n=argc>1?std::atoi(argv[1]):32;int samples=argc>2?std::atoi(argv[2]):15;
 std::size_t m=argc>3?std::atoi(argv[3]):n*4;
 int process=argc>4?std::atoi(argv[4]):0;
 auto f=kibo::tests::performance_fixture(m,n);
 Eigen::MatrixXd a=f.matrix.transpose()*f.matrix;a.diagonal().array()+=1e-3;
 Eigen::VectorXd b=f.matrix.transpose()*f.rhs,expected=a.ldlt().solve(b),esolution(n);
 kibo::tests::RowMatrix input=a;
 std::vector<double>storage(n*n),w(n),solution(n);
 auto av=MatrixView<const double>::checked(std::span<const double>(input.data(),input.size()),n,n,n).value();
 auto pv=MatrixView<double>::checked(storage,n,n,n).value();auto ws=std::as_writable_bytes(std::span<double>(w));
 auto factor=factorize_llt(av,pv);if(!factor)return 3;Eigen::LLT<Eigen::MatrixXd> eigen(a);esolution.setZero();
 auto core_factor=[&]{factor=factorize_llt(av,pv);return bool(factor);};
 auto core_solve=[&]{return bool(solve_into(factor.value(),std::span<const double>(b.data(),n),solution,ws));};
 auto eigen_factor=[&]{eigen.compute(a);return eigen.info()==Eigen::Success;};
 auto eigen_solve=[&]{esolution=eigen.solve(b);return esolution.allFinite();};
 auto valid=[&]{return core_solve()&&eigen_solve()&&(Eigen::Map<Eigen::VectorXd>(solution.data(),n)-expected).norm()/expected.norm()<1e-8&&(esolution-expected).norm()/expected.norm()<1e-8;};
 for(int phase=0;phase<4;++phase){
  std::unique_ptr<double[]> owned_answer;
  auto core=[&]{
    if (phase==3) {
      auto copied=input;
      std::unique_ptr<double[]> arena(new double[n*n+n]),answer(new double[n]);
      auto packed=std::span<double>(arena.get(),n*n),work=std::span<double>(arena.get()+n*n,n);
      auto source=MatrixView<const double>::checked(std::span<const double>(copied.data(),copied.size()),n,n,n).value();
      auto target=MatrixView<double>::checked(packed,n,n,n).value();
      auto factored=factorize_llt(source,target);
      if(!factored||!solve_into(factored.value(),std::span<const double>(b.data(),n),std::span<double>(answer.get(),n),std::as_writable_bytes(std::span<double>(work))))return false;
      owned_answer=std::move(answer);consumed=owned_answer[0];return true;
    }
    if(phase!=1&&!core_factor())return false;if(phase!=0&&!core_solve())return false;consumed=storage[0]+solution[0];return true;};
  auto ref=[&]{
    if (phase==3) {
      Eigen::MatrixXd copied=input;
      Eigen::LLT<Eigen::MatrixXd> temporary(copied);
      Eigen::VectorXd answer=temporary.solve(b);
      if(temporary.info()!=Eigen::Success)return false;
      esolution=std::move(answer);consumed=esolution[0];return true;
    }
    if(phase!=1&&!eigen_factor())return false;if(phase!=0&&!eigen_solve())return false;consumed=eigen.matrixLLT()(0,0)+esolution[0];return true;};
  auto timed=[&](auto& fn,std::size_t count){auto start=std::chrono::steady_clock::now();for(std::size_t i=0;i<count;++i)if(!fn())return -1.0;return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();};
  if(!core()||!ref()||!valid())return 4;for(int i=0;i<5;++i){core();ref();}
  std::size_t batch=1;for(;;){auto c=timed(core,batch),e=timed(ref,batch);if(c<0||e<0)return 5;if(std::min(c,e)>=.03)break;batch*=2;}
  for(int sample=0;sample<samples;++sample){double c,e;
  for(;;){if((sample+process)%2){e=timed(ref,batch);c=timed(core,batch);}else{c=timed(core,batch);e=timed(ref,batch);}
  if(c<0||e<0)return 5;if(std::min(c,e)>=.02)break;batch*=2;}
  if(c<0||e<0||!(phase==0?valid():((Eigen::Map<Eigen::VectorXd>(phase==3?owned_answer.get():solution.data(),n)-expected).norm()/expected.norm()<1e-8&&(esolution-expected).norm()/expected.norm()<1e-8)))return 6;
  std::printf("{\"phase\":%d,\"n\":%zu,\"m\":%zu,\"process\":%d,\"sample\":%d,\"calls\":%zu,\"core\":%.17g,\"eigen\":%.17g,\"minBatch\":%.17g,\"inputHash\":\"%016llx\",\"packetWidth\":%d,\"coreType\":%u}\n",phase,n,m,process,sample,batch,c/batch,e/batch,std::min(c,e),static_cast<unsigned long long>(input_hash(input,b)),Eigen::internal::packet_traits<double>::size,probe_core_type());}
 }
}
