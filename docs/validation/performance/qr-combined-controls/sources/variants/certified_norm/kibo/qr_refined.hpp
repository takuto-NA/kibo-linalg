#pragma once
#include <kibo/qr.hpp>

namespace kibo::linalg {
namespace detail {
struct QrDoubleDouble { double high=0, low=0; };
inline QrDoubleDouble qr_dd_add(QrDoubleDouble a, QrDoubleDouble b) noexcept {
    const double sum=a.high+b.high;
    const double virtual_b=sum-a.high;
    const double error=(a.high-(sum-virtual_b))+(b.high-virtual_b)+a.low+b.low;
    const double high=sum+error;
    return {high,error-(high-sum)};
}
inline QrDoubleDouble qr_dd_product(double a, double b) noexcept {
    const double high=a*b;
    return {high,std::fma(a,b,-high)};
}
inline QrDoubleDouble qr_dd_product(double a, QrDoubleDouble b) noexcept {
    return qr_dd_add(qr_dd_product(a,b.high),{a*b.low,0});
}
inline bool qr_dd_finite(QrDoubleDouble value) noexcept {
    return std::isfinite(value.high) && std::isfinite(value.low);
}
class QrPowerOfTwoScale {
    int exponent_;
    double multiplier_;
public:
    explicit QrPowerOfTwoScale(double largest) noexcept {
        std::frexp(largest,&exponent_);
        // Extreme exponents require scalbn per value: constructing the
        // reciprocal of a tiny power of two could overflow on its own.
        multiplier_=(exponent_>=-1023 && exponent_<=1022) ? std::ldexp(1.0,-exponent_) : 0;
    }
    double operator()(double value) const noexcept {
        return multiplier_!=0 ? value*multiplier_ : std::scalbn(value,-exponent_);
    }
};
} // namespace detail

inline Result<WorkspaceRequirement> qr_refined_solve_requirement(std::size_t m, std::size_t n) noexcept {
    if (n==0 || m<n) return StatusCode::invalid_shape;
    const auto maximum=std::numeric_limits<std::size_t>::max();
    if (m>maximum/2 || n>(maximum-2*m)/3) return StatusCode::size_overflow;
    return detail::double_requirement(2*m+3*n);
}

// original must contain the same A used to create factor. It is borrowed only
// during this call; factor continues to own no reference to the original A.
inline Status solve_refined_into(QrFactorView factor, MatrixView<const double> original,
                                 std::span<const double> rhs, std::span<double> output,
                                 std::span<std::byte> workspace) noexcept {
    if (!factor.valid()) return {StatusCode::invalid_factor};
    const auto packed=factor.packed();
    const auto m=packed.rows(),n=packed.cols();
    if (original.rows()!=m || original.cols()!=n || rhs.size()!=m || output.size()!=n)
        return {StatusCode::invalid_shape};
    auto requirement=qr_refined_solve_requirement(m,n);
    if (!requirement) return requirement.status();
    auto prepared=detail::workspace_doubles(workspace,requirement.value());
    if (!prepared) return prepared.status();
    double largest=0;
    for (std::size_t i=0;i<m;++i) for (std::size_t j=0;j<n;++j) {
        const double value=original(i,j);
        if (!std::isfinite(value)) return {StatusCode::non_finite_input};
        largest=std::max(largest,std::abs(value));
    }
    for (double value:rhs) if (!std::isfinite(value)) return {StatusCode::non_finite_input};
    if (largest==0) return {StatusCode::invalid_argument};
    auto values=prepared.value();
    auto residual_high=values.first(m);
    auto residual_low=values.subspan(m,m);
    auto candidate=values.subspan(2*m,n);
    auto gradient=values.subspan(2*m+n,n);
    auto correction=values.subspan(2*m+2*n,n);
    const auto base_requirement=qr_solve_requirement(m,n);
    if (!base_requirement) return base_requirement.status();
    auto status=solve_into(factor,rhs,candidate,workspace.first(base_requirement.value().bytes));
    if (!status) return status;
    const detail::QrPowerOfTwoScale scale(largest);
    for (int iteration=0;iteration<2;++iteration) {
        for (std::size_t i=0;i<m;++i) {
            detail::QrDoubleDouble residual{scale(rhs[i]),0};
            for (std::size_t j=0;j<n;++j)
                residual=detail::qr_dd_add(residual,detail::qr_dd_product(-scale(original(i,j)),candidate[j]));
            if (!detail::qr_dd_finite(residual)) return {StatusCode::arithmetic_failure,i};
            residual_high[i]=residual.high;residual_low[i]=residual.low;
        }
        for (std::size_t j=0;j<n;++j) {
            detail::QrDoubleDouble value;
            for (std::size_t i=0;i<m;++i)
                value=detail::qr_dd_add(value,detail::qr_dd_product(scale(original(i,j)),
                        detail::QrDoubleDouble{residual_high[i],residual_low[i]}));
            gradient[j]=value.high+value.low;
            if (!detail::qr_dd_finite(value) || !std::isfinite(gradient[j]))
                return {StatusCode::arithmetic_failure,j};
        }
        // A P = Q R, so solve R^T z = P^T g and R delta = z without
        // constructing A^T A. The same double R is reused for both steps.
        for (std::size_t i=0;i<n;++i) {
            double value=gradient[factor.permutation()[i]];
            for (std::size_t j=0;j<i;++j) value-=scale(packed(j,i))*correction[j];
            value/=scale(packed(i,i));
            if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
            correction[i]=value;
        }
        for (std::size_t i=n;i-->0;) {
            double value=correction[i];
            for (std::size_t j=i+1;j<n;++j) value-=scale(packed(i,j))*correction[j];
            value/=scale(packed(i,i));
            if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
            correction[i]=value;
        }
        for (std::size_t i=0;i<n;++i) {
            auto& value=candidate[factor.permutation()[i]];
            value+=correction[i];
            if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
        }
    }
    for (std::size_t i=0;i<n;++i) output[i]=candidate[i];
    return {};
}
} // namespace kibo::linalg
