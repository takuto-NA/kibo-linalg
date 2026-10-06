#include <kibo/linalg.hpp>
#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <kibo/dynamic_matrix.hpp>
#include <array>
#include <cstdio>
int main() {
    using namespace kibo::linalg;
    auto owned=DynamicMatrix<double>::try_create(2,2);
    if (!owned) return 1;
    auto& a=owned.value();
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> output{};
    auto status=matvec_into(a.const_view(),std::span<const double>{b},std::span<double>{output});
    if (!status || output[0]!=6 || output[1]!=7) return 2;
    StaticMatrix<double,2,2> storage;
    alignas(double) std::array<std::byte,32> workspace{};
    auto llt=factorize_llt(a.const_view(),storage.view());
    if (!llt || !solve_into(llt.value(),std::span<const double>{b},std::span<double>{output},workspace)) return 3;
    std::array<double,2> tau{};
    std::array<std::size_t,2> permutation{};
    auto qr=factorize_qr(a.const_view(),storage.view(),tau,permutation,workspace);
    if (!qr || !solve_into(qr.value(),std::span<const double>{b},std::span<double>{output},workspace)) return 4;
    if (std::abs(output[0]-1.0/11)>1e-14 || std::abs(output[1]-7.0/11)>1e-14) return 5;
    std::puts("relocated find_package consumer passed");
}
