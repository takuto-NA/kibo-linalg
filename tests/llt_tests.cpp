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
    // Dense lower factor, odd dimensions and padding exercise row updates.
    {
        constexpr std::size_t n=33;
        std::array<double,n*n> lower{},matrix{};
        std::array<double,n> truth{},rhs{},answer{},work{};
        for(std::size_t i=0;i<n;++i) {
            truth[i]=(i%2==0)?1:-0.25;
            for(std::size_t j=0;j<=i;++j) lower[i*n+j]=i==j?2+double(i%3):(double((i*7+j*3)%5)-2)*0.125;
        }
        for(std::size_t i=0;i<n;++i) for(std::size_t j=0;j<n;++j) {
            for(std::size_t k=0;k<=std::min(i,j);++k) matrix[i*n+j]+=lower[i*n+k]*lower[j*n+k];
            rhs[i]+=matrix[i*n+j]*truth[j];
        }
        auto dense=MatrixView<const double>::checked(matrix,n,n,n).value();
        for(const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{n+3,1},{2*n+3,2},{1,n+3}}}) {
            std::array<double,2*n*n+3*n> backing;backing.fill(999);
            auto target=MatrixView<double>::checked(backing,n,n,strides[0],strides[1]).value();
            auto result=factorize_llt(dense,target);
            CHECK(result && llt_factor_requirement(n).value().workspace.bytes==0);
            CHECK(solve_into(result.value(),std::span<const double>{rhs},std::span<double>{answer},std::as_writable_bytes(std::span<double>{work})));
            std::array<bool,2*n*n+3*n> logical{};
            for(std::size_t i=0;i<n;++i) for(std::size_t j=0;j<n;++j) {
                CHECK(target(i,j)==lower[i*n+j]);
                logical[i*strides[0]+j*strides[1]]=true;
            }
            for(std::size_t i=0;i<n;++i) CHECK(std::abs(answer[i]-truth[i])<1e-12);
            for(std::size_t i=0;i<backing.size();++i) if(!logical[i]) CHECK(backing[i]==999);
        }
        matrix.fill(0);
        for(std::size_t i=0;i<n;++i) matrix[i*n+i]=1;
        matrix[n*n-1]=-1;
        StaticMatrix<double,n,n> failed_storage;
        auto late_pivot=factorize_llt(dense,failed_storage.view());
        CHECK(!late_pivot && late_pivot.status().code==StatusCode::non_positive_pivot && late_pivot.status().index==n-1);
        matrix[n*n-1]=1;matrix[0]=1e-300;matrix[1]=matrix[n]=1e300;
        auto overflow=factorize_llt(dense,failed_storage.view());
        CHECK(!overflow && overflow.status().code==StatusCode::arithmetic_failure && overflow.status().index==0);
    }
    std::puts("public LLT 2x2 factor and transactional solve passed");
}
