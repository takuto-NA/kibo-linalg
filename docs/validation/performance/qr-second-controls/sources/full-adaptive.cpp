#include <kibo/qr.hpp>
#include <Eigen/QR>
#include <Eigen/Cholesky>
#include "controlled_fixture.hpp"
#include "../../tools/diagnostics/solver-locality/affinity.hpp"
#include <algorithm>
#include <bit>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <vector>
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
int main(int argc,char** argv) {
    if(!pin_probe()||probe_core_type()!=64)return 2;
    Eigen::setNbThreads(1);
    const std::size_t n=argc>1?std::atoi(argv[1]):32;
    const int samples=argc>2?std::atoi(argv[2]):5;
    const std::size_t m=argc>3?std::atoi(argv[3]):n*4;
    const int process=argc>4?std::atoi(argv[4]):0;
    auto fixture=kibo::tests::performance_fixture(m,n);
    Eigen::VectorXd expected;
    {
        Eigen::MatrixXd normal=fixture.matrix.transpose()*fixture.matrix;
        normal.diagonal().array()+=1e-3;
        Eigen::VectorXd gradient=fixture.matrix.transpose()*fixture.rhs;
        expected=normal.ldlt().solve(gradient);
    }
    kibo::tests::RowMatrix input=kibo::tests::RowMatrix::Zero(m+n,n);
    input.topRows(m)=fixture.matrix;input.bottomRows(n).diagonal().setConstant(std::sqrt(1e-3));
    const std::size_t rows=input.rows();
    Eigen::VectorXd rhs=Eigen::VectorXd::Zero(rows);rhs.head(m)=fixture.rhs;
    // Both backends receive the same row input. Factor layout is a separate choice.
    // Five input-sized buffers bound root input, both prepared factors and the
    // temporary copy/factor pair. Extra vector/index space is conservative.
    const auto numeric_bound=8*(fixture.matrix.size()+fixture.rhs.size()+fixture.truth.size()+5*input.size()+12*rows+40*n)+12*n*sizeof(std::size_t);
    if(numeric_bound>64*1024*1024)return 7;
    std::vector<double> storage(rows*n),tau(n),work(rows+n),solution(n);
    std::vector<std::size_t> permutation(n);
    auto av=MatrixView<const double>::checked(std::span<const double>{input.data(),static_cast<std::size_t>(input.size())},rows,n,n).value();
#if defined(QR_COLUMN)
    const std::size_t rs=1,cs=rows;
    constexpr const char* layout="column";
#else
    const std::size_t rs=n,cs=1;
    constexpr const char* layout="row";
#endif
    auto pv=MatrixView<double>::checked(storage,rows,n,rs,cs).value();
    auto ws=std::as_writable_bytes(std::span<double>{work});
    auto factor=factorize_qr(av,pv,tau,permutation,ws);if(!factor)return 3;
#if defined(EIGEN_ROW)
    using EMatrix=kibo::tests::RowMatrix;
    constexpr const char* eigen_layout="row";
#else
    using EMatrix=Eigen::MatrixXd;
    constexpr const char* eigen_layout="column";
#endif
    Eigen::ColPivHouseholderQR<EMatrix> eigen(rows,n);
    eigen.setThreshold(static_cast<double>(rows)*std::numeric_limits<double>::epsilon());
    Eigen::VectorXd esolution(n);
    auto core_factor=[&]{factor=factorize_qr(av,pv,tau,permutation,ws);return bool(factor);};
    auto core_solve=[&]{return bool(solve_into(factor.value(),std::span<const double>{rhs.data(),rows},solution,ws));};
    auto eigen_factor=[&]{eigen.compute(input);return eigen.rank()==static_cast<Eigen::Index>(n);};
    auto eigen_solve=[&]{esolution=eigen.solve(rhs);return esolution.allFinite();};
    auto answers_valid=[&]{return (Eigen::Map<Eigen::VectorXd>{solution.data(),static_cast<Eigen::Index>(n)}-expected).norm()/expected.norm()<1e-8 && (esolution-expected).norm()/expected.norm()<1e-8;};
    if(!core_factor()||!core_solve()||!eigen_factor()||!eigen_solve()||!answers_valid())return 4;
    const auto hash=input_hash(input,rhs);
    for(int phase=0;phase<4;++phase) {
        auto core=[&] {
            if(phase==3) {
                auto copied=input;
                std::vector<double> packed(rows*n),coefficients(n),workspace(rows+n),answer(n);
                std::vector<std::size_t> order(n);
                auto source=MatrixView<const double>::checked(std::span<const double>{copied.data(),static_cast<std::size_t>(copied.size())},rows,n,n).value();
                auto target=MatrixView<double>::checked(packed,rows,n,rs,cs).value();
                auto bytes=std::as_writable_bytes(std::span<double>{workspace});
                auto temporary=factorize_qr(source,target,coefficients,order,bytes);
                if(!temporary||!solve_into(temporary.value(),std::span<const double>{rhs.data(),rows},answer,bytes))return false;
                solution=std::move(answer);consumed=solution[0];return true;
            }
            if(phase!=1&&!core_factor())return false;
            if(phase!=0&&!core_solve())return false;
            consumed=storage[0]+solution[0];return true;
        };
        auto ref=[&] {
            if(phase==3) {
                auto copied=input;
                Eigen::ColPivHouseholderQR<EMatrix> temporary(rows,n);
                temporary.setThreshold(static_cast<double>(rows)*std::numeric_limits<double>::epsilon());
                temporary.compute(copied);
                if(temporary.rank()!=static_cast<Eigen::Index>(n))return false;
                Eigen::VectorXd answer=temporary.solve(rhs);
                esolution=std::move(answer);consumed=esolution[0];return true;
            }
            if(phase!=1&&!eigen_factor())return false;
            if(phase!=0&&!eigen_solve())return false;
            consumed=eigen.matrixQR()(0,0)+esolution[0];return true;
        };
        auto timed=[&](auto& fn,std::size_t count){const auto start=std::chrono::steady_clock::now();for(std::size_t i=0;i<count;++i)if(!fn())return -1.0;return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();};
        if(!core()||!ref())return 5;
        for(int i=0;i<5;++i)if(!core()||!ref())return 5;
        std::size_t batch=1;
        for(;;){const auto c=timed(core,batch),e=timed(ref,batch);if(c<0||e<0)return 5;if(std::min(c,e)>=.03)break;batch*=2;}
        for(int sample=0;sample<samples;++sample) {
            double c,e;
            for(;;) {
                if((sample+process)%2){e=timed(ref,batch);c=timed(core,batch);}else{c=timed(core,batch);e=timed(ref,batch);}
                if(c<0||e<0)return 5;
                if(std::min(c,e)>=.02)break;batch*=2;
            }
            if(phase==0 && (!core_solve()||!eigen_solve()))return 6;
            if(!answers_valid())return 6;
            std::printf("{\"phase\":%d,\"n\":%zu,\"m\":%zu,\"rows\":%zu,\"process\":%d,\"sample\":%d,\"calls\":%zu,\"core\":%.17g,\"eigen\":%.17g,\"minBatch\":%.17g,\"inputHash\":\"%016llx\",\"packetWidth\":%d,\"coreType\":%u,\"layout\":\"%s\",\"eigenLayout\":\"%s\",\"numericBytesBound\":%zu}\n",phase,n,m,rows,process,sample,batch,c/batch,e/batch,std::min(c,e),static_cast<unsigned long long>(hash),Eigen::internal::packet_traits<double>::size,probe_core_type(),layout,eigen_layout,static_cast<std::size_t>(numeric_bound));
        }
    }
}
