#include <kibo/llt.hpp>
#include <kibo/qr.hpp>
#include <array>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <span>

namespace {
using namespace kibo::linalg;
struct FitResult { std::array<double,2> parameters; double cost; int iterations; bool success; };
FitResult fit(bool exponential,bool augmented_qr) {
    const std::array<double,5> y=exponential ? std::array<double,5>{1,2.7,7.4,20.1,54.6} : std::array<double,5>{2.1,3.9,6.1,8,9.9};
    std::array<double,2> parameters=exponential ? std::array<double,2>{1,1} : std::array<double,2>{0,0};
    const auto residuals=[&](std::array<double,2> p) {
        std::array<double,5> result{};
        for(std::size_t i=0;i<5;++i) {
            const double x=static_cast<double>(i)+(exponential ? 0 : 1);
            result[i]=(exponential ? p[0]*std::exp(p[1]*x) : p[0]*x+p[1])-y[i];
        }
        return result;
    };
    const auto cost=[](const std::array<double,5>& r) {
        double result=0; for(double value:r) result+=value*value/2; return result;
    };
    double lambda=1e-3;
    for(int iteration=0;iteration<100;++iteration) {
        const auto residual=residuals(parameters);
        StaticMatrix<double,5,2> jacobian;
        for(std::size_t j=0;j<2;++j) {
            auto plus=parameters,minus=parameters;
            const double step=1e-6*(1+std::abs(parameters[j]));
            plus[j]+=step; minus[j]-=step;
            const auto rp=residuals(plus),rm=residuals(minus);
            for(std::size_t i=0;i<5;++i) jacobian(i,j)=(rp[i]-rm[i])/(2*step);
        }
        std::array<double,2> gradient{};
        auto status=matvec_into(jacobian.const_view().transpose(),std::span<const double>{residual},std::span<double>{gradient});
        if(!status) return {parameters,cost(residual),iteration,false};
        if(std::max(std::abs(gradient[0]),std::abs(gradient[1]))<=1e-6) return {parameters,cost(residual),iteration,true};
        std::array<double,2> delta{};
        alignas(double) std::array<std::byte,72> workspace{};
        if(augmented_qr) {
            StaticMatrix<double,7,2> augmented,packed;
            for(std::size_t i=0;i<5;++i) for(std::size_t j=0;j<2;++j) augmented(i,j)=jacobian(i,j);
            augmented(5,0)=std::sqrt(lambda); augmented(6,1)=std::sqrt(lambda); // D=I
            std::array<double,7> rhs{}; for(std::size_t i=0;i<5;++i) rhs[i]=-residual[i];
            std::array<double,2> tau{}; std::array<std::size_t,2> permutation{};
            auto factor=factorize_qr(augmented.const_view(),packed.view(),tau,permutation,workspace);
            status=factor ? solve_into(factor.value(),std::span<const double>{rhs},std::span<double>{delta},workspace) : factor.status();
        } else {
            StaticMatrix<double,2,2> normal,lower;
            status=matmul_into(jacobian.const_view().transpose(),jacobian.const_view(),normal.view());
            if(status) status=add_diagonal_inplace(normal.view(),lambda); // H=J^T J+lambda D^T D; D=I
            for(auto& value:gradient) value=-value;
            auto factor=status ? factorize_llt(normal.const_view(),lower.view()) : Result<LltFactorView>{status};
            status=factor ? solve_into(factor.value(),std::span<const double>{gradient},std::span<double>{delta},workspace) : factor.status();
        }
        if(!status) {lambda*=10; continue;}
        auto candidate=parameters; for(std::size_t j=0;j<2;++j) candidate[j]+=delta[j];
        const double candidate_cost=cost(residuals(candidate));
        if(std::isfinite(candidate_cost) && candidate_cost<cost(residual)) {parameters=candidate; lambda=std::max(lambda*0.3,1e-15);}
        else lambda*=10;
    }
    return {parameters,cost(residuals(parameters)),100,false};
}
}
int main() {
    for(bool exponential:{false,true}) for(bool qr:{false,true}) {
        const auto result=fit(exponential,qr);
        const bool parameters_ok=exponential ? std::abs(result.parameters[0]-1)<0.2 && std::abs(result.parameters[1]-1)<0.2 :
            std::abs(result.parameters[0]-1.97)<=1e-6 && std::abs(result.parameters[1]-0.09)<=1e-6;
        const bool passed=result.success && result.cost<0.1 && parameters_ok;
        std::printf("{\"problem\":\"%s\",\"solver\":\"%s\",\"parameters\":[%.17g,%.17g],\"cost\":%.17g,\"iterations\":%d,\"passed\":%s}\n",
            exponential?"exponential":"line",qr?"augmented-QR":"normal-LLT",result.parameters[0],result.parameters[1],result.cost,result.iterations,passed?"true":"false");
        if(!passed) return 1;
    }
}
