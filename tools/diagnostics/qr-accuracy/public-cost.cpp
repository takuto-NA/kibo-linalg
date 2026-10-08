#include <kibo/qr_refined.hpp>
#include "controlled_fixture.hpp"
#include <chrono>
#include <cstdio>
#include <vector>
#include "../solver-locality/affinity.hpp"

volatile double public_cost_consumed=0;
int main() {
    using namespace kibo::linalg;
    if (!pin_probe() || probe_core_type()!=64) return 2;
    for (std::size_t n:{2,8,32,128,512}) for (double condition:{2.0,1e8}) {
        const std::size_t m=4*n;
        auto fixture=kibo::tests::controlled_fixture(m,n,condition,true);
        std::vector<double> packed(m*n),tau(n),work(2*m+3*n),solution(n);
        std::vector<std::size_t> permutation(n);
        auto input=MatrixView<const double>::checked({fixture.matrix.data(),m*n},m,n,n).value();
        auto storage=MatrixView<double>::checked(packed,m,n,1,m).value();
        auto workspace=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(input,storage,tau,permutation,workspace);
        if (!factor) return 3;
        for (int phase=0;phase<4;++phase) {
            auto call=[&]() {
                if (phase>=2) factor=factorize_qr(input,storage,tau,permutation,workspace);
                if (!factor) return false;
                auto status=phase%2==0 ? solve_into(factor.value(),{fixture.rhs.data(),m},solution,workspace)
                    : solve_refined_into(factor.value(),input,{fixture.rhs.data(),m},solution,workspace);
                public_cost_consumed=solution[0];
                return static_cast<bool>(status);
            };
            auto time=[&](std::size_t calls) {
                const auto start=std::chrono::steady_clock::now();
                for (std::size_t i=0;i<calls;++i) if (!call()) return -1.0;
                return std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();
            };
            for (int i=0;i<5;++i) if (!call()) return 4;
            std::size_t calls=1;
            for (int sample=0;sample<5;++sample) {
                double elapsed;
                for (;;) {elapsed=time(calls);if (elapsed<0) return 5;if (elapsed>=.02) break;calls*=2;}
                std::printf("{\"n\":%zu,\"m\":%zu,\"condition\":%.0f,\"phase\":%d,\"sample\":%d,\"calls\":%zu,\"elapsed\":%.17g,\"seconds\":%.17g,\"workspaceDoubles\":%zu,\"originalMatrixDoubles\":%zu,\"setupExcluded\":true}\n",
                    n,m,condition,phase,sample,calls,elapsed,elapsed/calls,2*m+3*n,m*n);
            }
            if (phase%2!=0 && (Eigen::Map<const Eigen::VectorXd>(solution.data(),n)-fixture.truth).norm()/fixture.truth.norm()
                >(condition<=1e4 ? 1e-8 : 1e-4)) return 6;
        }
    }
}
