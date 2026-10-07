#include <kibo/linalg.hpp>
#include <kibo/llt.hpp>
#include <array>
#include <cstdio>

int main() {
    using namespace kibo::linalg;
    StaticMatrix<double,2,2> a;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    const std::array<double,2> b{1,2};
    std::array<double,2> product{};
    const auto status=matvec_into(a.const_view(),std::span<const double>{b},std::span<double>{product});
    if (!status) return 1;
    std::printf("Ab=[%.17g, %.17g]\n",product[0],product[1]);
    if (product[0]!=6 || product[1]!=7) return 2;
    StaticMatrix<double,2,2> factor_storage;
    alignas(double) std::array<std::byte,16> workspace{};
    auto factor=factorize_llt(a.const_view(),factor_storage.view());
    if (!factor) return 3;
    const auto solved=solve_into(factor.value(),std::span<const double>{b},std::span<double>{product},workspace);
    if (!solved) return 4;
    std::printf("LLT x=[%.17g, %.17g]\n",product[0],product[1]);
    return std::abs(product[0]-1.0/11)>1e-14 || std::abs(product[1]-7.0/11)>1e-14;
}
