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
// Keep scalar finite checks inline on MSVC as well as GCC/Clang.
// Ordered comparison rejects NaN and both infinities without a CRT call.
inline bool llt_is_finite(double value) noexcept {
    return std::abs(value)<=std::numeric_limits<double>::max();
}
struct LltAccess {
    static LltFactorView create(MatrixView<const double> lower) noexcept { return LltFactorView(lower); }
};
inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {
    // Input is fully validated and independent of storage. Compute through a
    // transposed view so panel columns are contiguous without heap/workspace.
    const auto n=input.rows();
    auto working=storage.transpose();
    for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);
    for (std::size_t first=0;first<n;) {
        const auto end=first+std::min(std::size_t{8},n-first);
        for (std::size_t k=first;k<end;++k) {
            const double diagonal=working(k,k);
            if (!detail::llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
            if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
            working(k,k)=std::sqrt(diagonal);
            for (std::size_t i=k+1;i<end;++i) {
                const double value=working(i,k)/working(k,k);
                if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }
            for (std::size_t j=k+1;j<end;++j)
                row_update(&working(j,j),&working(j,k),end-j,working(j,k));
        }
        if (end<n) for (std::size_t k=first;k<end;++k) {
            for (std::size_t i=end;i<n;++i) {
                const double value=working(i,k)/working(k,k);
                if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }
            for (std::size_t j=k+1;j<end;++j)
                row_update(&working(end,j),&working(end,k),n-end,working(j,k));
        }
        if (end<n) {
            auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1
            for (std::size_t j=end;j<n;++j) {
                for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);
                row_update_panel(&working(j,j),&working(j,first),working.col_stride(),coefficients,end-first,n-j);
            }
        }
        first=end;
    }
    // Restore the caller's lower triangle and clear every logical upper entry.
    for (std::size_t first=0;first<n;) {
        const auto end=first+std::min(std::size_t{8},n-first);
        for (std::size_t column=0;column<first;column+=8) {
            const auto stop=std::min(column+8,first);
            for (std::size_t j=column;j<stop;++j) for (std::size_t i=first;i<end;++i) {
                storage(i,j)=storage(j,i);storage(j,i)=0;
            }
        }
        for (std::size_t i=first;i<end;++i) for (std::size_t j=first;j<i;++j) {
            storage(i,j)=storage(j,i);storage(j,i)=0;
        }
        first=end;
    }
    return LltAccess::create(storage);
}
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
    if (!detail::llt_is_finite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)
        return StatusCode::invalid_argument;
    double scale=0;
    if (options.check_symmetry && input.col_stride()==1 && n>=32) {
        // The whole input, including the unused triangle, is still validated
        // before storage is touched. Combine the finite and scale scans.
        for (std::size_t i=0;i<n;++i)
            if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;
    } else {
        if (!detail::finite(input)) return StatusCode::non_finite_input;
        if (options.check_symmetry) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));
        }
    }
    if (options.check_symmetry) {
        if (scale!=0) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<i;++j)
                    if (input(i,j)!=input(j,i) &&
                        std::abs(input(i,j)/scale-input(j,i)/scale)>options.symmetry_tolerance)
                        return Status{StatusCode::invalid_argument,i};
        }
    }
    if constexpr (detail::row_simd_available) {
        if (storage.col_stride()==1 && n>=32)
            return detail::factorize_column_llt(input,storage);
    }
    for (std::size_t i=0;i<n;++i) {
        for (std::size_t j=0;j<=i;++j) {
            double value=input(i,j);
            for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);
            if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};
            if (i==j) {
                if (value<=0) return Status{StatusCode::non_positive_pivot,j};
                storage(i,j)=std::sqrt(value);
            } else {
                value/=storage(j,j);
                if (!detail::llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,j};
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
    for (auto value:rhs) if (!detail::llt_is_finite(value)) return {StatusCode::non_finite_input};
    auto candidate=prepared.value();
    auto lower=factor.lower();
    for (std::size_t i=0;i<n;++i) {
        double value=rhs[i];
        for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];
        value/=lower(i,i);
        if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    for (std::size_t i=n;i-->0;) {
        double value=candidate[i];
        for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];
        value/=lower(i,i);
        if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    for (std::size_t i=0;i<n;++i) output[i]=candidate[i];
    return {};
}
} // namespace kibo::linalg
