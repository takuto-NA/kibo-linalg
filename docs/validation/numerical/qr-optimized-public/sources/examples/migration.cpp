#include <kibo/dynamic_matrix.hpp>
#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <array>
#include <cmath>
#include <cstdio>

int main() {
    using namespace kibo::linalg;
    const std::array<double,4> external_column_major{4,1,1,3};
    auto mapped=MatrixView<const double>::checked(external_column_major,2,2,1,2);
    if (!mapped) return 1;
    StaticMatrix<double,2,2> gram;
    if (!matmul_into(mapped.value().transpose(),mapped.value(),gram.view())) return 2;
    if (gram(0,0)!=17 || gram(0,1)!=7 || gram(1,0)!=7 || gram(1,1)!=10) return 3;

    auto created=DynamicMatrix<double>::try_create(2,2);
    if (!created) return 4;
    auto owned=std::move(created).value();
    if (!copy_into(mapped.value(),owned.view())) return 5;
    auto clone=owned.try_clone();
    if (!clone) return 6;
    auto resized=owned.try_resize(3,3);
    if (!resized || resized.value()(2,2)!=0 || resized.value()(0,0)!=4) return 7;

    StaticMatrix<double,2,2> factor_storage;
    const std::array<double,2> rhs{1,2};
    std::array<double,2> solution{},tau{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,32> workspace{};
    auto llt=factorize_llt(mapped.value(),factor_storage.view());
    if (!llt || !solve_into(llt.value(),std::span<const double>{rhs},std::span<double>{solution},workspace)) return 8;
    if (std::abs(solution[0]-1.0/11)>1e-14 || std::abs(solution[1]-7.0/11)>1e-14) return 9;
    auto qr=factorize_qr(clone.value().const_view(),factor_storage.view(),tau,permutation,workspace);
    if (!qr || !solve_into(qr.value(),std::span<const double>{rhs},std::span<double>{solution},workspace)) return 10;
    if (std::abs(solution[0]-1.0/11)>1e-14 || std::abs(solution[1]-7.0/11)>1e-14) return 11;
    std::puts("ownership, external Map, Gram product, LLT and QR migration passed");
}
