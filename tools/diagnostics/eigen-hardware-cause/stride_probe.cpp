// Prepared only: root owns all builds and serial benchmark execution.
// Compile against the existing diagnostic LLT headers, WITHOUT ablation defines.
#include <kibo/llt.hpp>
#include "controlled_fixture.hpp"
#include "affinity.hpp"
#include <Eigen/Cholesky>
#include <algorithm>
#include <array>
#include <bit>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <malloc.h>
#include <numeric>
#include <span>
#include <vector>

namespace {
using namespace kibo::linalg;
using Clock=std::chrono::steady_clock;
constexpr std::size_t n=512,m=2048,max_stride=1032;
constexpr int sample_count=30,warmups=5;
volatile double consumed=0;
struct AlignedBuffer {
    double* data=static_cast<double*>(_aligned_malloc(n*max_stride*sizeof(double),64));
    ~AlignedBuffer(){_aligned_free(data);}
    AlignedBuffer()=default;
    AlignedBuffer(const AlignedBuffer&)=delete;
    AlignedBuffer& operator=(const AlignedBuffer&)=delete;
};
double median(std::vector<double> v){
    std::sort(v.begin(),v.end());return (v[(v.size()-1)/2]+v[v.size()/2])/2;
}
std::uint64_t input_hash(const kibo::tests::RowMatrix& h,const Eigen::VectorXd& rhs){
    std::uint64_t hash=14695981039346656037ULL;
    const auto append=[&](std::uint64_t bits){for(int b=0;b<8;++b){hash^=(bits>>(8*b))&255;hash*=1099511628211ULL;}};
    append(n);append(m);
    for(Eigen::Index i=0;i<h.size();++i)append(std::bit_cast<std::uint64_t>(h.data()[i]));
    for(Eigen::Index i=0;i<rhs.size();++i)append(std::bit_cast<std::uint64_t>(rhs[i]));
    return hash;
}
void print_cache_geometry(){
    int regs[4]{};__cpuidex(regs,0,0);
    const unsigned max_leaf=static_cast<unsigned>(regs[0]);
    std::printf("{\"kind\":\"cpu\",\"pid\":%lu,\"logicalCpu\":%lu,\"cpuidCoreType\":%u,\"maxBasicLeaf\":%u}\n",GetCurrentProcessId(),GetCurrentProcessorNumber(),probe_core_type(),max_leaf);
    if(max_leaf<4){std::printf("{\"kind\":\"cacheGeometry\",\"available\":false}\n");return;}
    for(unsigned subleaf=0;subleaf<32;++subleaf){
        __cpuidex(regs,4,static_cast<int>(subleaf));
        const auto eax=static_cast<unsigned>(regs[0]),ebx=static_cast<unsigned>(regs[1]);
        const auto ecx=static_cast<unsigned>(regs[2]);
        const unsigned type=eax&31;if(type==0)break;
        const unsigned level=(eax>>5)&7,line=(ebx&4095)+1;
        const unsigned partitions=((ebx>>12)&1023)+1,ways=((ebx>>22)&1023)+1;
        const std::uint64_t sets=static_cast<std::uint64_t>(ecx)+1;
        const std::uint64_t bytes=static_cast<std::uint64_t>(line)*partitions*ways*sets;
        std::printf("{\"kind\":\"cacheGeometry\",\"cpuidLeaf\":4,\"subleaf\":%u,\"type\":%u,\"level\":%u,\"lineBytes\":%u,\"sets\":%llu,\"ways\":%u,\"partitions\":%u,\"capacityBytes\":%llu,\"l1Data\":%s,\"l1MissesMeasured\":false}\n",subleaf,type,level,line,static_cast<unsigned long long>(sets),ways,partitions,static_cast<unsigned long long>(bytes),(type==1&&level==1)?"true":"false");
    }
}
}

int main(int argc,char** argv){
    // Default: full sweep. Optional positional strides: e.g. stride_probe 512 520.
    const std::array<std::size_t,8> allowed{512,520,528,576,640,768,1024,1032};
    std::vector<std::size_t> strides;
    if(argc==1)strides.assign(allowed.begin(),allowed.end());
    else for(int a=1;a<argc;++a){
        char* end=nullptr;const auto parsed=std::strtoull(argv[a],&end,10);
        if(!end||*end||end==argv[a]||std::find(allowed.begin(),allowed.end(),parsed)==allowed.end()){
            std::fprintf(stderr,"Allowed strides: 512 520 528 576 640 768 1024 1032\n");return 10;
        }
        const auto stride=static_cast<std::size_t>(parsed);
        if(std::find(strides.begin(),strides.end(),stride)!=strides.end())return 10;
        strides.push_back(stride);
    }
    if(!pin_probe())return 20;
    if(GetCurrentProcessorNumber()!=0){std::fprintf(stderr,"CPU0 affinity not yet effective\n");return 21;}
    Eigen::setNbThreads(1);print_cache_geometry();
    auto fixture=kibo::tests::performance_fixture(m,n);
    Eigen::MatrixXd formalH=fixture.matrix.transpose()*fixture.matrix;
    formalH.diagonal().array()+=1e-3;
    Eigen::VectorXd rhs=fixture.matrix.transpose()*fixture.rhs;
    Eigen::LDLT<Eigen::MatrixXd> independent(formalH);
    if(independent.info()!=Eigen::Success)return 11;
    const Eigen::VectorXd expected=independent.solve(rhs);
    if(!expected.allFinite()||expected.norm()==0)return 11;
    const kibo::tests::RowMatrix input=formalH;
    const auto hash=input_hash(input,rhs);
    AlignedBuffer backing;if(!backing.data)return 12;
    // One pointer, one allocation and one capacity for every stride, including
    // factor slack. factorize_llt overwrites logical input; padding is unused.
    std::fill_n(backing.data,n*max_stride,0.0);
    std::vector<double> solution(n),work(n);
    const auto workspace=std::as_writable_bytes(std::span<double>(work));
    const auto av=MatrixView<const double>::checked(std::span<const double>(input.data(),n*n),n,n,n).value();
    std::printf("{\"kind\":\"fixture\",\"m\":%zu,\"n\":%zu,\"inputHash\":\"%016llx\",\"backingAddress\":\"%p\",\"backingBytes\":%zu,\"alignmentBytes\":64,\"packetWidth\":%d,\"coreSIMD\":%d}\n",m,n,static_cast<unsigned long long>(hash),static_cast<void*>(backing.data),n*max_stride*sizeof(double),Eigen::internal::packet_traits<double>::size,detail::row_simd_available);
    for(const auto stride:strides){
        auto pv=MatrixView<double>::checked(std::span<double>(backing.data,n*max_stride),n,n,stride).value();
        auto core=[&]{
            auto factor=factorize_llt(av,pv);
            if(!factor||!solve_into(factor.value(),std::span<const double>(rhs.data(),n),solution,workspace))return false;
            consumed=solution[0];return true;
        };
        double relative_error=0,relative_residual=0;
        const auto accuracy=[&]{
            const Eigen::Map<const Eigen::VectorXd> x(solution.data(),n);
            relative_error=(x-expected).norm()/expected.norm();
            relative_residual=(formalH*x-rhs).norm()/(formalH.norm()*x.norm()+rhs.norm());
            return x.allFinite()&&std::isfinite(relative_error)&&std::isfinite(relative_residual)&&relative_error<=1e-8&&relative_residual<=1e-10;
        };
        for(int w=0;w<warmups;++w)if(!core())return 13;
        if(!accuracy())return 14;
        std::size_t batch=1;
        const auto timed=[&](std::size_t count){auto t=Clock::now();for(std::size_t c=0;c<count;++c)if(!core())return -1.0;return std::chrono::duration<double>(Clock::now()-t).count();};
        for(;;){const double seconds=timed(batch);if(seconds<0)return 15;if(seconds>=.025)break;if(batch>1048576)return 15;batch*=2;}
        std::vector<double> samples;samples.reserve(sample_count);
        std::array<double,5> phase_totals{};std::uint64_t total_calls=0;
        // Calibration/warmup phase counts are discarded. Each measured sample
        // has its own reset, and prints only after its measured interval ends.
        for(int sample=0;sample<sample_count;++sample){
            for(auto& v:lltcause::times)v=0;
            const auto start=Clock::now();std::size_t calls=0;double duration=0;
            do{
                for(std::size_t c=0;c<batch;++c){if(!core())return 16;++calls;}
                duration=std::chrono::duration<double>(Clock::now()-start).count();
            }while(duration<.020);
            if(!accuracy())return 17;
            samples.push_back(duration/calls);total_calls+=calls;
            for(std::size_t p=0;p<phase_totals.size();++p)phase_totals[p]+=lltcause::times[p];
            std::printf("{\"kind\":\"strideSample\",\"strideDoubles\":%zu,\"sample\":%d,\"calls\":%zu,\"batchSeconds\":%.17g,\"secondsPerFactorSolve\":%.17g,\"relativeErrorToLDLT\":%.17g,\"relativeResidual\":%.17g,\"accuracyPassed\":true}\n",stride,sample,calls,duration,duration/calls,relative_error,relative_residual);
        }
        auto sorted=samples;std::sort(sorted.begin(),sorted.end());
        const double denominator=static_cast<double>(total_calls);
        std::printf("{\"kind\":\"strideSummary\",\"strideDoubles\":%zu,\"strideBytes\":%zu,\"rowStartMod64\":%zu,\"m\":%zu,\"n\":%zu,\"warmups\":%d,\"samples\":%d,\"calls\":%llu,\"seconds\":%.17g,\"p95Seconds\":%.17g,\"phasesMs\":[",stride,stride*sizeof(double),(stride*sizeof(double))%64,m,n,warmups,sample_count,static_cast<unsigned long long>(total_calls),median(samples),sorted[28]);
        for(std::size_t p=0;p<phase_totals.size();++p)std::printf("%s%.17g",p?",":"",phase_totals[p]*1000/denominator);
        std::printf("],\"preflightMs\":%.17g,\"copyMs\":%.17g,\"panelMs\":%.17g,\"trailingMs\":%.17g,\"zeroUpperMs\":%.17g,\"logicalCpu\":%lu,\"cpuidCoreType\":%u,\"accuracyPassed\":true,\"l1MissesMeasured\":false}\n",phase_totals[0]*1000/denominator,phase_totals[1]*1000/denominator,phase_totals[2]*1000/denominator,phase_totals[3]*1000/denominator,phase_totals[4]*1000/denominator,GetCurrentProcessorNumber(),probe_core_type());
    }
    return 0;
}
