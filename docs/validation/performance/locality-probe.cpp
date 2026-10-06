#include <kibo/qr.hpp>
#include "controlled_fixture.hpp"
#include <chrono>
#include <cstdio>
#include <vector>
volatile double consume;
int main() {
    using namespace kibo::linalg;
    const std::size_t m=1024,n=512;
    const auto fixture=kibo::tests::performance_fixture(m,n);
    auto input=MatrixView<const double>::checked(std::span<const double>{fixture.matrix.data(),m*n},m,n,n).value();
    std::vector<double> packed(m*n),tau(n),workspace(m+n),solution(n);
    std::vector<std::size_t> permutation(n);
    auto work=std::as_writable_bytes(std::span<double>{workspace});
    double seconds[2]{};
    for(int layout=0;layout<2;++layout) {
        auto storage=MatrixView<double>::checked(packed,m,n,layout==0?n:1,layout==0?1:m).value();
        for(int repeat=0;repeat<4;++repeat) {
            const auto start=std::chrono::steady_clock::now();
            auto factor=factorize_qr(input,storage,tau,permutation,work);
            const auto end=std::chrono::steady_clock::now();
            if(!factor || !solve_into(factor.value(),std::span<const double>{fixture.rhs.data(),m},std::span<double>{solution},work)) return 2;
            for(auto value:solution) if(std::abs(value-1)>1e-10) return 3;
            consume=storage(0,0);
            if(repeat>0) seconds[layout]+=std::chrono::duration<double>(end-start).count()/3;
        }
    }
    const auto ratio=seconds[0]/seconds[1];
    std::printf("{\"m\":%zu,\"n\":%zu,\"rowSeconds\":%.9g,\"columnSeconds\":%.9g,\"rowOverColumn\":%.9g,\"accuracyPassed\":true}\n",m,n,seconds[0],seconds[1],ratio);
    return ratio>4 ? 1 : 0; // diagnostic signal, not a public CI speed guarantee
}
