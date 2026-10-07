#include <kibo/linalg.hpp>
#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <array>
#include <cstdio>

#if defined(_CPPUNWIND) || defined(_CPPRTTI)
#error Consumer must compile without exception handling or RTTI.
#endif
#if !defined(_MSC_VER) && (defined(__EXCEPTIONS) || defined(__GXX_RTTI))
#error Consumer must compile without exception handling or RTTI.
#endif

template<class T> concept FloatingValue = std::floating_point<T>;
static_assert(FloatingValue<double> && !FloatingValue<int>);

int main() {
    kibo::linalg::StaticMatrix<double,2,2> a;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> output{};
    const auto status=kibo::linalg::matvec_into(a.view(),std::span<const double>{b},std::span<double>{output});
    if (!status || output[0]!=6 || output[1]!=7) return 1;
    kibo::linalg::StaticMatrix<double,2,2> factor_storage;
    alignas(double) std::array<std::byte,16> workspace{};
    auto factor=kibo::linalg::factorize_llt(a.const_view(),factor_storage.view());
    if (!factor || !kibo::linalg::solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},workspace)) return 2;
    if (std::abs(output[0]-1.0/11)>1e-14 || std::abs(output[1]-7.0/11)>1e-14) return 3;
    static_assert(sizeof(a)+sizeof(factor_storage)+sizeof(b)+sizeof(output)+sizeof(workspace)<=4096);
    std::array<double,2> tau{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,32> qr_workspace{};
    auto qr=kibo::linalg::factorize_qr(a.const_view(),factor_storage.view(),tau,permutation,qr_workspace);
    if (!qr || !kibo::linalg::solve_into(qr.value(),std::span<const double>{b},std::span<double>{output},qr_workspace)) return 4;
    if (std::abs(output[0]-1.0/11)>1e-14 || std::abs(output[1]-7.0/11)>1e-14) return 5;
    std::puts("C++20 concepts/span; exceptions and RTTI disabled; Ab=[6,7]");
}
