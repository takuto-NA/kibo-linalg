#include <kibo/qr_refined.hpp>
#include "fixtures/oracles.hpp"
#include "test_check.hpp"
#include <array>
#include <vector>

int main() {
    using namespace kibo::linalg;
    CHECK(qr_refined_solve_requirement(0,0).status().code==StatusCode::invalid_shape);
    CHECK(qr_refined_solve_requirement(2,3).status().code==StatusCode::invalid_shape);
    CHECK(qr_refined_solve_requirement(std::numeric_limits<std::size_t>::max(),1).status().code==StatusCode::size_overflow);
    CHECK(qr_refined_solve_requirement(8,2).value().bytes==22*sizeof(double));
    // The same rounded input and independent oracle are used for every layout.
    // NaNs in input padding must not become logical non-finite input errors.
    for (const auto& oracle:kibo::tests::oracles) for (bool input_column:{false,true}) {
        const auto m=oracle.m,n=oracle.n;
        const auto input_row=input_column ? 2 : 2*(n+2);
        const auto input_col=input_column ? 2*(m+2) : 2;
        std::vector<double> input(m*input_row+n*input_col,std::numeric_limits<double>::quiet_NaN());
        for (std::size_t i=0;i<m;++i) for (std::size_t j=0;j<n;++j) input[i*input_row+j*input_col]=oracle.matrix[i*n+j];
        auto a=MatrixView<const double>::checked(input,m,n,input_row,input_col).value();
        for (const auto strides:std::array<std::array<std::size_t,2>,4>{{{n,1},{1,m},{2*(n+2),2},{2,2*(m+2)}}}) {
            std::vector<double> packed(m*strides[0]+n*strides[1],777),tau(n),answer(n,123),work(2*m+3*n);
            std::vector<std::size_t> order(n);
            auto p=MatrixView<double>::checked(packed,m,n,strides[0],strides[1]).value();
            auto ws=std::as_writable_bytes(std::span<double>{work});
            auto factor=factorize_qr(a,p,tau,order,ws);
            CHECK(factor && factor.value().diagnostics().rank==n);
            CHECK(solve_refined_into(factor.value(),a,{oracle.rhs,m},answer,ws));
            double error=0,norm=0;
            for (std::size_t j=0;j<n;++j) {error+=std::pow(answer[j]-oracle.solution[j],2);norm+=oracle.solution[j]*oracle.solution[j];}
            CHECK(std::sqrt(error/norm)<=1e-4);
            std::vector<bool> logical(packed.size());
            for (std::size_t i=0;i<m;++i) for (std::size_t j=0;j<n;++j) logical[i*strides[0]+j*strides[1]]=true;
            for (std::size_t j=0;j<packed.size();++j) if (!logical[j]) CHECK(packed[j]==777);
        }
    }
    {
        // Pivot permutation, and every preflight failure, use the public API.
        std::array<double,6> input{1,0,0,10,1,1},packed{};
        std::array<double,3> rhs{2,-30,-1};
        std::array<double,2> tau{},answer{123,456};
        const auto sentinel=answer;
        std::array<std::size_t,2> order{};
        std::array<double,13> work{};
        auto a=MatrixView<const double>::checked(input,3,2,2).value();
        auto p=MatrixView<double>::checked(packed,3,2,2).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor && order[0]==1);
        const auto bytes=qr_refined_solve_requirement(3,2).value().bytes;
        CHECK(solve_refined_into({},a,rhs,answer,ws).code==StatusCode::invalid_factor && answer==sentinel);
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws.first(bytes-1)).code==StatusCode::insufficient_capacity && answer==sentinel);
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws.subspan(1,bytes)).code==StatusCode::invalid_layout && answer==sentinel);
        CHECK(solve_refined_into(factor.value(),a,std::span<const double>{rhs}.first(2),answer,ws).code==StatusCode::invalid_shape && answer==sentinel);
        auto wrong_shape=MatrixView<const double>::checked(input,2,2,2).value();
        CHECK(solve_refined_into(factor.value(),wrong_shape,rhs,answer,ws).code==StatusCode::invalid_shape && answer==sentinel);
        input[2]=std::numeric_limits<double>::quiet_NaN();
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws).code==StatusCode::non_finite_input && answer==sentinel);
        input[2]=0;rhs[2]=std::numeric_limits<double>::infinity();
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws).code==StatusCode::non_finite_input && answer==sentinel);
        rhs[2]=-1;
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws.first(bytes)));
        CHECK(std::abs(answer[0]-2)<1e-14 && std::abs(answer[1]+3)<1e-14);
    }
    {
        StaticMatrix<double,2,2> a,packed;
        a(0,0)=4;a(0,1)=1;a(1,0)=1;a(1,1)=3;
        std::array<double,2> rhs_and_output{1,2},tau{};
        std::array<std::size_t,2> order{};
        std::array<double,10> work{};
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a.const_view(),packed.view(),tau,order,ws);
        CHECK(factor && solve_refined_into(factor.value(),a.const_view(),rhs_and_output,rhs_and_output,ws));
        CHECK(std::abs(rhs_and_output[0]-1.0/11)<1e-14 && std::abs(rhs_and_output[1]-7.0/11)<1e-14);
    }
    // A finite base solve can fail later in normalized residual calculation.
    // A partially computed refinement must never reach the caller's output.
    {
        std::array<double,2> input{1e-300,0},packed{},rhs{0,1e300};
        std::array<double,1> tau{},answer{123};
        std::array<std::size_t,1> order{};
        std::array<double,7> work{};
        auto a=MatrixView<const double>::checked(input,2,1,1).value();
        auto p=MatrixView<double>::checked(packed,2,1,1).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor && solve_into(factor.value(),rhs,answer,ws) && answer[0]==0);
        answer[0]=123;
        CHECK(solve_refined_into(factor.value(),a,rhs,answer,ws).code==StatusCode::arithmetic_failure && answer[0]==123);
    }
    // These endpoints require per-value scaling rather than a reciprocal
    // multiplier that would overflow or be subnormal itself.
    for (double magnitude:{std::numeric_limits<double>::denorm_min(),1e-300,1e300,0x1p1023}) {
        const double truth=magnitude==std::numeric_limits<double>::denorm_min() ? 1 : .25;
        std::array<double,1> input{magnitude},packed{},rhs{magnitude*truth},tau{},answer{};
        std::array<std::size_t,1> order{};
        std::array<double,5> work{};
        auto a=MatrixView<const double>::checked(input,1,1,1).value();
        auto p=MatrixView<double>::checked(packed,1,1,1).value();
        auto ws=std::as_writable_bytes(std::span<double>{work});
        auto factor=factorize_qr(a,p,tau,order,ws);
        CHECK(factor && solve_refined_into(factor.value(),a,rhs,answer,ws));
        CHECK(answer[0]==truth);
    }
    std::puts("QR refinement oracles, layouts, scale endpoints and output preservation passed");
}
