#if defined(CAUSE_QR)
#include <kibo/qr.hpp>
#include <Eigen/QR>
#else
#include <kibo/llt.hpp>
#endif
#include <Eigen/Cholesky>
#include "controlled_fixture.hpp"
#include <algorithm>
#include <bit>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include "affinity.hpp"

namespace {
using namespace kibo::linalg;
using Clock=std::chrono::steady_clock;
volatile double consumed=0;
std::uint64_t hash_matrix(const kibo::tests::RowMatrix& matrix,const Eigen::VectorXd& rhs) {
    std::uint64_t result=14695981039346656037ULL;
    const auto append=[&](std::uint64_t value) {
        for(int b=0;b<8;++b){result^=(value>>(8*b))&255;result*=1099511628211ULL;}
    };
    append(matrix.rows());append(matrix.cols());
    for(Eigen::Index i=0;i<matrix.size();++i)append(std::bit_cast<std::uint64_t>(matrix.data()[i]));
    for(Eigen::Index i=0;i<rhs.size();++i)append(std::bit_cast<std::uint64_t>(rhs[i]));
    return result;
}
double median(std::vector<double> v) {
    std::sort(v.begin(),v.end());
    return (v[(v.size()-1)/2]+v[v.size()/2])/2;
}
}
int main(int argc,char** argv) {
    if(!pin_probe())return 20;
    const int process=argc>1 ? std::atoi(argv[1]) : 0;
    const int samples=argc>2 ? std::atoi(argv[2]) : 30;
    if(samples<5)return 10;
    Eigen::setNbThreads(1);
    constexpr std::size_t n=512,m=2048;
    auto fixture=kibo::tests::performance_fixture(m,n);
    Eigen::MatrixXd normal=fixture.matrix.transpose()*fixture.matrix;
    normal.diagonal().array()+=1e-3;
    Eigen::VectorXd gradient=fixture.matrix.transpose()*fixture.rhs;
    Eigen::VectorXd expected=normal.ldlt().solve(gradient);
    if(!expected.allFinite())return 11;
    kibo::tests::RowMatrix input;
    Eigen::VectorXd rhs;
#if defined(CAUSE_QR)
    input=kibo::tests::RowMatrix::Zero(m+n,n);
    input.topRows(m)=fixture.matrix;
    input.bottomRows(n).diagonal().setConstant(std::sqrt(1e-3));
    rhs=Eigen::VectorXd::Zero(m+n);rhs.head(m)=fixture.rhs;
    constexpr const char* solver="augmented-QR";
#else
    input=normal;rhs=gradient;
    constexpr const char* solver="normal-LLT";
#endif
    const std::size_t rows=input.rows();
    constexpr std::size_t padding=
#if defined(CAUSE_PADDING)
        CAUSE_PADDING;
#else
        0;
#endif
    const std::size_t stride=n+padding;
    std::vector<double> packed(rows*stride),tau(n),work(rows+n),solution(n);
    std::vector<std::size_t> permutation(n);
    auto av=MatrixView<const double>::checked(std::span<const double>(input.data(),input.size()),rows,n,n).value();
#if defined(CAUSE_COLUMN)
    auto pv=MatrixView<double>::checked(packed,rows,n,1,rows).value();
#else
    auto pv=MatrixView<double>::checked(packed,rows,n,stride).value();
#endif
    auto workspace=std::as_writable_bytes(std::span<double>(work));
    using EMatrix=Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,
#if defined(CAUSE_EIGEN_ROW)
        Eigen::RowMajor
#else
        Eigen::ColMajor
#endif
    >;
    EMatrix einput=input;
#if defined(CAUSE_QR)
    Eigen::ColPivHouseholderQR<EMatrix> reference(rows,n);
    reference.setThreshold(static_cast<double>(rows)*std::numeric_limits<double>::epsilon());
#else
    Eigen::LLT<EMatrix> reference(n);
#endif
    Eigen::VectorXd esolution(n);
    auto core=[&] {
#if defined(CAUSE_QR)
        auto f=factorize_qr(av,pv,tau,permutation,workspace);
#else
        LltOptions options{};
#if defined(CAUSE_NO_SYMMETRY)
        options.check_symmetry=false;
#endif
        auto f=factorize_llt(av,pv,options);
#endif
        if(!f||!solve_into(f.value(),std::span<const double>(rhs.data(),rows),solution,workspace))return false;
        consumed=solution[0];return true;
    };
    auto eigen=[&] {
        reference.compute(einput);
#if defined(CAUSE_QR)
        if(reference.rank()!=n)return false;
#else
        if(reference.info()!=Eigen::Success)return false;
#endif
        esolution=reference.solve(rhs);consumed=esolution[0];return true;
    };
    const auto accuracy=[&] {
        auto x=Eigen::Map<const Eigen::VectorXd>(solution.data(),n);
        return x.allFinite()&&esolution.allFinite()&&(x-expected).norm()/expected.norm()<=1e-8
            &&(esolution-expected).norm()/expected.norm()<=1e-8;
    };
    if(!core()||!eigen()||!accuracy())return 12;
    for(int i=0;i<5;++i)if(!core()||!eigen())return 13;
    // Both backends use the same batch. Choose it before the measured samples.
    std::size_t batch=1;
    auto timed=[&](auto& f,std::size_t count){auto t=Clock::now();for(std::size_t i=0;i<count;++i)if(!f())return -1.0;return std::chrono::duration<double>(Clock::now()-t).count();};
    for(;;){double c=timed(core,batch),e=timed(eigen,batch);if(c<0||e<0)return 14;if(std::min(c,e)>=.025)break;batch*=2;}
#if defined(CAUSE_QR)
    for(auto& value:cause::times)value=0;
    qr_ablation::preflight_seconds=qr_ablation::copy_seconds=qr_ablation::initial_norm_seconds=0;
    qr_ablation::pivot_seconds=qr_ablation::selected_norm_seconds=qr_ablation::vector_seconds=0;
    qr_ablation::factor_calls=qr_ablation::selected_norm_calls=qr_ablation::refreshed_norm_calls=0;
#else
    for(auto& value:lltcause::times)value=0;
#endif
    std::vector<double> ct,et;
    for(int sample=0;sample<samples;++sample){
        double c,e;
        if((sample+process)%2==0){c=timed(core,batch);e=timed(eigen,batch);}
        else{e=timed(eigen,batch);c=timed(core,batch);}
        if(c<0||e<0||!accuracy())return 15;
        ct.push_back(c/batch);et.push_back(e/batch);
        std::printf("{\"kind\":\"sample\",\"process\":%d,\"sample\":%d,\"calls\":%zu,\"coreSeconds\":%.17g,\"eigenSeconds\":%.17g}\n",process,sample,batch,c/batch,e/batch);
    }
    const double cmedian=median(ct),emedian=median(et);
    std::sort(ct.begin(),ct.end());std::sort(et.begin(),et.end());
    std::printf("{\"kind\":\"summary\",\"process\":%d,\"solver\":\"%s\",\"m\":%zu,\"n\":%zu,\"rows\":%zu,\"stridePadding\":%zu,\"samples\":%d,\"batch\":%zu,\"inputHash\":\"%016llx\",\"coreSeconds\":%.17g,\"eigenSeconds\":%.17g,\"coreP95\":%.17g,\"eigenP95\":%.17g,\"ratio\":%.17g,\"accuracyPassed\":true,\"packetWidth\":%d,\"coreSIMD\":%d,\"phasesMs\":[",process,solver,m,n,rows,padding,samples,batch,static_cast<unsigned long long>(hash_matrix(input,rhs)),cmedian,emedian,ct[(samples*95+99)/100-1],et[(samples*95+99)/100-1],cmedian/emedian,Eigen::internal::packet_traits<double>::size,detail::row_simd_available);
#if defined(CAUSE_QR)
    auto& phases=cause::times;
#else
    auto& phases=lltcause::times;
#endif
    for(std::size_t i=0;i<std::size(phases);++i)std::printf("%s%.17g",i?",":"",phases[i]*1000/(samples*batch));
    std::printf("],\"logicalCpu\":0,\"cpuidCoreType\":%u",probe_core_type());
#if defined(CAUSE_QR)
    const double calls=qr_ablation::factor_calls;
    std::printf(",\"qrDetailMs\":[%.17g,%.17g,%.17g,%.17g,%.17g,%.17g],\"selectedNormsPerFactor\":%.17g,\"refreshedNormsPerFactor\":%.17g",qr_ablation::preflight_seconds*1000/calls,qr_ablation::copy_seconds*1000/calls,qr_ablation::initial_norm_seconds*1000/calls,qr_ablation::pivot_seconds*1000/calls,qr_ablation::selected_norm_seconds*1000/calls,qr_ablation::vector_seconds*1000/calls,qr_ablation::selected_norm_calls/calls,qr_ablation::refreshed_norm_calls/calls);
#endif
    std::printf("}\n");
#if defined(CAUSE_QR)
    const double a[]={1,-1},b[]={.9*std::numeric_limits<double>::max(),.9*std::numeric_limits<double>::max()};
    double p[2]{},t[1]{},w[3]{},sentinel=-123;std::size_t perm[1]{};
    auto af=MatrixView<const double>::checked(a,2,1,1).value();auto pf=MatrixView<double>::checked(p,2,1,1).value();
    auto wf=std::as_writable_bytes(std::span<double>(w));auto factor=factorize_qr(af,pf,t,perm,wf);
    if(!factor)return 16;auto status=solve_into(factor.value(),b,std::span<double>(&sentinel,1),wf);
    if(status.code!=StatusCode::arithmetic_failure||sentinel!=-123)return 17;
    std::printf("{\"kind\":\"overflowControl\",\"passed\":true}\n");
#endif
    return cmedian/emedian>1.1?1:0;
}
