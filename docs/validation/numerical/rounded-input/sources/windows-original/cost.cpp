#include <kibo/qr.hpp>
#include "controlled_fixture.hpp"
#include <Eigen/QR>
#include <chrono>
#include <cstdio>
#include <vector>
#include "refine.hpp"
#include "../../tools/diagnostics/solver-locality/affinity.hpp"
volatile double consumed=0;
int main() {
    using namespace kibo::linalg;
    if(!pin_probe()||probe_core_type()!=64)return 2;
    for(std::size_t n:{2,8,32,128,512})for(double condition:{2.0,1e8}) {
        const std::size_t m=4*n;
        auto f=kibo::tests::controlled_fixture(m,n,condition,true);
        std::vector<double> packed(m*n),tau(n),work(m+n),solution(n),r(n*n),refined;
        std::vector<std::size_t> permutation(n);
        auto input=MatrixView<const double>::checked({f.matrix.data(),m*n},m,n,n).value();
        auto storage=MatrixView<double>::checked(packed,m,n,1,m).value();
        auto ws=std::as_writable_bytes(std::span<double>(work));
        auto factor=factorize_qr(input,storage,tau,permutation,ws);
        if(!factor||!solve_into(factor.value(),{f.rhs.data(),m},solution,ws))return 3;
        for(std::size_t i=0;i<n;++i)for(std::size_t j=0;j<n;++j)r[i*n+j]=j<i?0:storage(i,j);
        auto base=[&]{auto current=factorize_qr(input,storage,tau,permutation,ws);
            if(!current||!solve_into(current.value(),{f.rhs.data(),m},solution,ws))return false;
            consumed=solution[0];return true;};
        auto dd=[&]{refined=diagnostic_refine(f.matrix,f.rhs,r,permutation,solution,true);consumed=refined[0];return true;};
        auto time=[&](auto& function,std::size_t calls){const auto start=std::chrono::steady_clock::now();
            for(std::size_t i=0;i<calls;++i)if(!function())return -1.0;
            return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();};
        for(int i=0;i<5;++i){base();dd();}
        for(int phase=0;phase<2;++phase) {
            auto measure=[&](auto& function){std::size_t calls=1;
                for(int sample=0;sample<5;++sample){double elapsed;
                    for(;;){elapsed=time(function,calls);if(elapsed<0)return false;if(elapsed>=.02)break;calls*=2;}
                    std::printf("{\"n\":%zu,\"m\":%zu,\"condition\":%.0f,\"phase\":%d,\"sample\":%d,\"calls\":%zu,\"elapsed\":%.17g,\"seconds\":%.17g,\"prototypeAllocationsIncluded\":true,\"candidateWorkspaceDoubles\":%zu}\n",n,m,condition,phase,sample,calls,elapsed,elapsed/calls,2*m+3*n);
                }return true;};
            if(!(phase==0?measure(base):measure(dd)))return 4;
        }
        dd();
        const double error=(Eigen::Map<const Eigen::VectorXd>(refined.data(),n)-f.truth).norm()/f.truth.norm();
        if(error>(condition<=1e4?1e-8:1e-4))return 5;
    }
}
