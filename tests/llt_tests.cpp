#include <kibo/llt.hpp>
#include <array>
#include <cmath>
#include <cstdio>
#include "test_check.hpp"
int main() {
    using namespace kibo::linalg;
    StaticMatrix<double,2,2> a, storage;
    a(0,0)=4; a(0,1)=1; a(1,0)=1; a(1,1)=3;
    auto factor=factorize_llt(a.const_view(),storage.view());
    CHECK(factor && storage(0,1)==0 && a(0,0)==4);
    const std::array<double,2> b{1,2};
    std::array<double,2> output{99,98};
    alignas(double) std::array<std::byte,2*sizeof(double)> workspace{};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},workspace));
    CHECK(std::abs(output[0]-1.0/11)<1e-14 && std::abs(output[1]-7.0/11)<1e-14);
    auto requirement=llt_solve_requirement(2);
    CHECK(requirement && requirement.value().bytes==16 && requirement.value().alignment==alignof(double));
    auto factor_requirement=llt_factor_requirement(2);
    CHECK(factor_requirement && factor_requirement.value().factor.bytes==32 && factor_requirement.value().workspace.bytes==0);
    output={99,98};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},std::span<std::byte>{workspace}.first(15)).code==StatusCode::insufficient_capacity);
    CHECK((output==std::array<double,2>{99,98}));
    alignas(double) std::array<std::byte,24> bytes{};
    CHECK(solve_into(factor.value(),std::span<const double>{b},std::span<double>{output},std::span<std::byte>{bytes}.subspan(1,16)).code==StatusCode::invalid_layout);
    CHECK((output==std::array<double,2>{99,98}));
    CHECK(solve_into(LltFactorView{},std::span<const double>{b},std::span<double>{output},workspace).code==StatusCode::invalid_factor);
    storage(0,0)=77;
    a(0,1)=2;
    CHECK(factorize_llt(a.const_view(),storage.view()).status().code==StatusCode::invalid_argument && storage(0,0)==77);
    a(0,1)=1; a(1,1)=std::numeric_limits<double>::infinity();
    CHECK(factorize_llt(a.const_view(),storage.view()).status().code==StatusCode::non_finite_input && storage(0,0)==77);
    a(0,0)=1; a(0,1)=2; a(1,0)=2; a(1,1)=1;
    auto non_spd=factorize_llt(a.const_view(),storage.view());
    CHECK(!non_spd && non_spd.status().code==StatusCode::non_positive_pivot && non_spd.status().index==1);
    CHECK(!llt_factor_requirement(0));
    CHECK(llt_factor_requirement(std::numeric_limits<std::size_t>::max()).status().code==StatusCode::size_overflow);
    StaticMatrix<double,1,1> tiny, tiny_storage;
    tiny(0,0)=1e-300;
    auto tiny_factor=factorize_llt(tiny.const_view(),tiny_storage.view());
    CHECK(tiny_factor);
    const std::array<double,1> huge_rhs{1e300};
    std::array<double,1> preserved{123};
    CHECK(solve_into(tiny_factor.value(),std::span<const double>{huge_rhs},std::span<double>{preserved},workspace).code==StatusCode::arithmetic_failure);
    CHECK(preserved[0]==123);
    // A known SPD system has the exact solution [1,-2,3].
    std::array<double,9> known_a{6,2,1,2,5,2,1,2,4};
    auto known_view=MatrixView<const double>::checked(known_a,3,3,3);
    StaticMatrix<double,3,3> known_storage;
    auto known_factor=factorize_llt(known_view.value(),known_storage.view());
    const std::array<double,3> known_b{5,-2,9};
    std::array<double,3> solution{};
    alignas(double) std::array<std::byte,24> known_workspace{};
    CHECK(known_factor && solve_into(known_factor.value(),std::span<const double>{known_b},std::span<double>{solution},known_workspace));
    CHECK(std::abs(solution[0]-1)<1e-12 && std::abs(solution[1]+2)<1e-12 && std::abs(solution[2]-3)<1e-12);
    std::puts("public LLT 2x2 factor and transactional solve passed");
}
