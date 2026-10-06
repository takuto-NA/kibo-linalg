#include <kibo/qr.hpp>
#include <array>
#include <cmath>
#include <cstdio>
#include "test_check.hpp"
int main() {
    using namespace kibo::linalg;
    // Inconsistent b has least-squares solution [1,2]; residual [-1,-1,1] is orthogonal to columns.
    std::array<double,6> data{1,0,0,1,1,1};
    auto input=MatrixView<const double>::checked(data,3,2,2);
    StaticMatrix<double,3,2> packed;
    std::array<double,2> tau{};
    std::array<std::size_t,2> permutation{};
    alignas(double) std::array<std::byte,32> factor_workspace{};
    QrDiagnostics diagnostics;
    auto factor=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace,{},&diagnostics);
    CHECK(factor && diagnostics.rank==2);
    const std::array<double,3> b{0,1,4};
    std::array<double,2> output{99,98};
    alignas(double) std::array<std::byte,40> solve_workspace{};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-1)<1e-12 && std::abs(output[1]-2)<1e-12);
    auto required=qr_factor_requirement(3,2);
    CHECK(required && required.value().packed.bytes==48 && required.value().workspace.bytes==32);
    CHECK(qr_solve_requirement(3,2).value().bytes==40);
    output={99,98};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},std::span<std::byte>{solve_workspace}.first(39)).code==StatusCode::insufficient_capacity);
    CHECK((output==std::array<double,2>{99,98}));
    CHECK(solve_into(QrFactorView{},std::span<const double>{b},std::span<double>{output},solve_workspace).code==StatusCode::invalid_factor);
    packed(0,0)=77; tau[0]=88; permutation[0]=99;
    auto short_capacity=factorize_qr(input.value(),packed.view(),tau,permutation,std::span<std::byte>{factor_workspace}.first(31));
    CHECK(!short_capacity && short_capacity.status().code==StatusCode::insufficient_capacity);
    CHECK(packed(0,0)==77 && tau[0]==88 && permutation[0]==99);
    data={1,1,2,2,3,3};
    auto deficient=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace,{},&diagnostics);
    CHECK(!deficient && deficient.status().code==StatusCode::rank_deficient && deficient.status().rank==1 && diagnostics.rank==1);
    StaticMatrix<double,2,2> square, square_packed;
    square(0,0)=1; square(0,1)=10; square(1,0)=0; square(1,1)=1;
    auto swapped=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace);
    CHECK(swapped && permutation[0]==1);
    const std::array<double,2> square_rhs{-28,-3};
    CHECK(solve_into(swapped.value(),std::span<const double>{square_rhs},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-2)<1e-12 && std::abs(output[1]+3)<1e-12);
    square(0,0)=1; square(0,1)=0; square(1,0)=0; square(1,1)=1e-4;
    auto below=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1e-3},&diagnostics);
    CHECK(!below && diagnostics.rank==1 && diagnostics.tolerance==1e-3);
    auto above=factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1e-5});
    CHECK(above && above.value().diagnostics().rank==2);
    CHECK(factorize_qr(square.const_view(),square_packed.view(),tau,permutation,factor_workspace,QrOptions{1.0}).status().code==StatusCode::invalid_argument);
    for (const double scale : {1e-150,1e150}) {
        data={scale,0,0,scale,scale,scale};
        auto scaled=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace);
        const std::array<double,3> consistent_rhs{scale,2*scale,3*scale};
        CHECK(scaled && solve_into(scaled.value(),std::span<const double>{consistent_rhs},std::span<double>{output},solve_workspace));
        CHECK(std::abs(output[0]-1)<1e-12 && std::abs(output[1]-2)<1e-12);
    }
    CHECK(qr_factor_requirement(1,2).status().code==StatusCode::invalid_shape);
    CHECK(qr_factor_requirement(std::numeric_limits<std::size_t>::max(),2).status().code==StatusCode::size_overflow);
    CHECK(qr_solve_requirement(std::numeric_limits<std::size_t>::max(),1).status().code==StatusCode::size_overflow);
    for (const std::size_t n : {2,8,32,128,512})
        for (const std::size_t m : {n,4*n}) CHECK(qr_factor_requirement(m,n) && qr_solve_requirement(m,n));
    data[5]=std::numeric_limits<double>::quiet_NaN();
    packed(0,0)=77;
    CHECK(factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace).status().code==StatusCode::non_finite_input && packed(0,0)==77);
    std::puts("public pivoted QR least-squares solve passed");
}
