#include <kibo/qr.hpp>
#include <array>
#include <cmath>
#include <cstdio>
#include "test_check.hpp"
int main() {
    using namespace kibo::linalg;
    // A finite full-rank factor can overflow only in transformed residual rows.
    // Checked contiguous updates must reject it and preserve the output.
    for (const auto stride:std::array<std::array<std::size_t,2>,2>{{{1,3},{2,1}}}) {
        std::array<double,2> input{1,-1};
        std::array<double,6> packed{};
        std::array<double,1> tau{},answer{123};
        std::array<std::size_t,1> order{};
        std::array<double,3> work{};
        const std::array<double,2> rhs{.9*std::numeric_limits<double>::max(),.9*std::numeric_limits<double>::max()};
        auto a=MatrixView<const double>::checked(input,2,1,1).value();
        auto p=MatrixView<double>::checked(packed,2,1,stride[0],stride[1]).value();
        auto factor=factorize_qr(a,p,tau,order,std::as_writable_bytes(std::span<double>{work}));
        CHECK(factor);
        auto status=solve_into(factor.value(),rhs,answer,std::as_writable_bytes(std::span<double>{work}));
        CHECK(status.code==StatusCode::arithmetic_failure && status.index==0 && answer[0]==123);
    }
    // A dense multi-column solve exercises unfinished tau slots and strided
    // factor storage. Padding must remain outside the logical writes.
    {
        constexpr std::array<double,24> values{1,2,-1,10,2,0,3,4,0,1,2,7,3,-1,0,2,1,1,1,-3,-2,0,1,5};
        constexpr std::array<double,4> expected{1,-2,0.5,3};
        auto a=MatrixView<const double>::checked(values,6,4,4).value();
        std::array<double,6> rhs{};
        CHECK(matvec_into(a,std::span<const double>{expected},std::span<double>{rhs}));
        for(const auto strides:std::array<std::array<std::size_t,2>,3>{{{4,1},{1,6},{8,1}}}) {
            std::array<double,48> storage;storage.fill(999);
            std::array<double,4> coefficients;coefficients.fill(std::numeric_limits<double>::quiet_NaN());
            std::array<std::size_t,4> order{};
            alignas(double) std::array<std::byte,80> work{};
            auto view=MatrixView<double>::checked(storage,6,4,strides[0],strides[1]).value();
            auto result=factorize_qr(a,view,coefficients,order,std::span<std::byte>{work}.first(64));
            CHECK(result && result.value().diagnostics().rank==4 && order[0]==3);
            std::array<double,4> answer{};
            CHECK(solve_into(result.value(),std::span<const double>{rhs},std::span<double>{answer},work));
            for(std::size_t j=0;j<4;++j) CHECK(std::abs(answer[j]-expected[j])<1e-12 && std::isfinite(coefficients[j]));
            std::array<bool,48> logical{};
            for(std::size_t i=0;i<6;++i) for(std::size_t j=0;j<4;++j) logical[i*strides[0]+j*strides[1]]=true;
            for(std::size_t index=0;index<48;++index) if(!logical[index]) CHECK(storage[index]==999);
        }
    }
    // Inconsistent b has least-squares solution [1,2]; residual [-1,-1,1] is orthogonal to columns.
    {
        constexpr std::size_t m=15,n=9;
        std::array<double,m*n> values{};
        std::array<double,n> truth{},answer{},coefficients{};
        std::array<double,m> rhs{};
        std::array<std::size_t,n> order{};
        std::array<double,m+n> work{};
        for(std::size_t j=0;j<n;++j) truth[j]=double(j%3)-1;
        for(std::size_t i=0;i<m;++i) for(std::size_t j=0;j<n;++j) {
            values[i*n+j]=(double((i*7+j*3)%11)-5)*0.0625+(i==j?4:0);
            rhs[i]+=values[i*n+j]*truth[j];
        }
        auto dense=MatrixView<const double>::checked(values,m,n,n).value();
        for(const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{n+3,1},{2*n+3,2},{1,m+3}}}) {
            std::array<double,m*(2*n+3)> backing;backing.fill(999);
            auto target=MatrixView<double>::checked(backing,m,n,strides[0],strides[1]).value();
            auto result=factorize_qr(dense,target,coefficients,order,std::as_writable_bytes(std::span<double>{work}.first(2*n)));
            CHECK(result && result.value().diagnostics().rank==n);
            CHECK(solve_into(result.value(),std::span<const double>{rhs},std::span<double>{answer},std::as_writable_bytes(std::span<double>{work})));
            for(std::size_t j=0;j<n;++j) CHECK(std::abs(answer[j]-truth[j])<1e-12);
            std::array<bool,m*(2*n+3)> logical{};
            for(std::size_t i=0;i<m;++i) for(std::size_t j=0;j<n;++j) logical[i*strides[0]+j*strides[1]]=true;
            for(std::size_t i=0;i<backing.size();++i) if(!logical[i]) CHECK(backing[i]==999);
        }
    }
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
    data={1,1,1,1+1e-8,1,1-1e-8};
    const std::array<double,3> difficult_rhs{0,-1e-8,1e-8}; // known x=[1,-1]
    auto difficult=factorize_qr(input.value(),packed.view(),tau,permutation,factor_workspace);
    CHECK(difficult && solve_into(difficult.value(),std::span<const double>{difficult_rhs},std::span<double>{output},solve_workspace));
    CHECK(std::abs(output[0]-1)<1e-4 && std::abs(output[1]+1)<1e-4);
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
