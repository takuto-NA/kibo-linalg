#pragma once
#include <kibo/workspace.hpp>
#include <kibo/detail/row_kernels.hpp>

namespace kibo::linalg {
struct LltOptions {
    double symmetry_tolerance=32*std::numeric_limits<double>::epsilon();
    bool check_symmetry=true;
};
namespace detail { struct LltAccess; }
class LltFactorView {
    friend struct detail::LltAccess;
    MatrixView<const double> lower_;
    explicit LltFactorView(MatrixView<const double> lower) noexcept : lower_(lower) {}
public:
    LltFactorView() noexcept = default; // invalid handle
    bool valid() const noexcept { return lower_.rows()!=0; }
    std::size_t size() const noexcept { return lower_.rows(); }
    MatrixView<const double> lower() const noexcept { return lower_; }
};
namespace detail {
struct LltAccess {
    static LltFactorView create(MatrixView<const double> lower) noexcept { return LltFactorView(lower); }
};
}

inline Result<FactorRequirement> llt_factor_requirement(std::size_t n) noexcept {
    if (n==0) return StatusCode::invalid_shape;
    if (n > std::numeric_limits<std::size_t>::max()/n) return StatusCode::size_overflow;
    auto factor=detail::double_requirement(n*n);
    if (!factor) return factor.status();
    return FactorRequirement{factor.value(),WorkspaceRequirement{0,alignof(double)}};
}
inline Result<WorkspaceRequirement> llt_solve_requirement(std::size_t n) noexcept {
    if (n==0) return StatusCode::invalid_shape;
    return detail::double_requirement(n);
}

inline Result<LltFactorView> factorize_llt(MatrixView<const double> input, MatrixView<double> storage,
                                         LltOptions options={}) noexcept {
    const auto n=input.rows();
    if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;
    if (!std::isfinite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)
        return StatusCode::invalid_argument;
    if (!detail::finite(input)) return StatusCode::non_finite_input;
    if (options.check_symmetry) {
        double scale=0;
        for (std::size_t i=0;i<n;++i)
            for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));
        if (scale!=0) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<i;++j)
                    if (std::abs(input(i,j)/scale-input(j,i)/scale)>options.symmetry_tolerance)
                        return Status{StatusCode::invalid_argument,i};
        }
    }
    if (storage.col_stride()==1 && n>=32) {
        // Right-looking updates preserve ascending subtraction order per
        // coefficient. The unused upper triangle temporarily mirrors the
        // current lower column so every update reads contiguous rows.
        const auto copied=copy_into(input,storage);
        if (!copied) return copied;
        for (std::size_t first=0;first<n;) {
            const auto end=first+std::min(std::size_t{8},n-first);
            for (std::size_t k=first;k<end;++k) {
                const double diagonal=storage(k,k);
                if (!std::isfinite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
                if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
                storage(k,k)=std::sqrt(diagonal);
                for (std::size_t i=k+1;i<n;++i) {
                    const double value=storage(i,k)/storage(k,k);
                    if (!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,k};
                    storage(i,k)=value;
                    storage(k,i)=value;
                }
                for (std::size_t i=k+1;i<n;++i)
                    detail::row_update(&storage(i,k+1),&storage(k,k+1),std::min(i+1,end)-k-1,storage(i,k));
            }
            for (std::size_t i=end;i<n;++i)
                detail::row_update_panel(&storage(i,end),&storage(first,end),storage.row_stride(),
                                         &storage(i,first),end-first,i-end+1);
            first=end;
        }
        // The public factor exposes a lower triangle, with upper entries 0.
        for (std::size_t i=0;i<n;++i)
            for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;
        return detail::LltAccess::create(storage);
    }
    for (std::size_t i=0;i<n;++i) {
        for (std::size_t j=0;j<=i;++j) {
            double value=input(i,j);
            for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);
            if (!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,j};
            if (i==j) {
                if (value<=0) return Status{StatusCode::non_positive_pivot,j};
                storage(i,j)=std::sqrt(value);
            } else {
                value/=storage(j,j);
                if (!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,j};
                storage(i,j)=value;
            }
        }
        for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;
    }
    return detail::LltAccess::create(storage);
}

inline Status solve_into(LltFactorView factor, std::span<const double> rhs, std::span<double> output,
                         std::span<std::byte> workspace) noexcept {
    if (!factor.valid()) return {StatusCode::invalid_factor};
    const auto n=factor.size();
    if (rhs.size()!=n || output.size()!=n) return {StatusCode::invalid_shape};
    auto requirement=llt_solve_requirement(n);
    if (!requirement) return requirement.status();
    auto prepared=detail::workspace_doubles(workspace,requirement.value());
    if (!prepared) return prepared.status();
    for (auto value:rhs) if (!std::isfinite(value)) return {StatusCode::non_finite_input};
    auto candidate=prepared.value();
    auto lower=factor.lower();
    for (std::size_t i=0;i<n;++i) {
        double value=rhs[i];
        for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];
        value/=lower(i,i);
        if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    for (std::size_t i=n;i-->0;) {
        double value=candidate[i];
        for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];
        value/=lower(i,i);
        if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    for (std::size_t i=0;i<n;++i) output[i]=candidate[i];
    return {};
}
} // namespace kibo::linalg
