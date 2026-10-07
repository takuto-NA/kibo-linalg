// DIAGNOSTIC SNAPSHOT ONLY: not an installed library header.
#pragma once
#include <kibo/workspace.hpp>
#include <chrono>
#include <kibo/detail/row_kernels.hpp>

namespace kibo::linalg {
namespace lltcause { inline double times[5]{}; using Clock=std::chrono::steady_clock; inline double elapsed(Clock::time_point t){return std::chrono::duration<double>(Clock::now()-t).count();} }
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
#if defined(KIBO_DIAG_LLT_COLUMN_WIDTH)
inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {
    const auto n=input.rows();
    auto working=storage.transpose();
    auto clock=lltcause::Clock::now();
    for(std::size_t j=0;j<n;++j) for(std::size_t i=j;i<n;++i) working(i,j)=input(i,j);
    lltcause::times[1]+=lltcause::elapsed(clock);
    for(std::size_t first=0;first<n;) {
        const auto end=first+std::min(std::size_t{KIBO_DIAG_LLT_COLUMN_WIDTH},n-first);
        clock=lltcause::Clock::now();
        for(std::size_t k=first;k<end;++k) {
            const double diagonal=working(k,k);
            if(!std::isfinite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
            if(diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
            working(k,k)=std::sqrt(diagonal);
            for(std::size_t i=k+1;i<end;++i) {
                const double value=working(i,k)/working(k,k);
                if(!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }
            for(std::size_t j=k+1;j<end;++j)
                row_update(&working(j,j),&working(j,k),end-j,working(j,k));
        }
        if(end<n) for(std::size_t k=first;k<end;++k) {
            for(std::size_t i=end;i<n;++i) {
                const double value=working(i,k)/working(k,k);
                if(!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }
            for(std::size_t j=k+1;j<end;++j)
                row_update(&working(end,j),&working(end,k),n-end,working(j,k));
        }
        lltcause::times[2]+=lltcause::elapsed(clock);
        clock=lltcause::Clock::now();
        if(end<n) {
            auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1
            for(std::size_t j=end;j<n;++j) {
                for(std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);
                row_update_panel(&working(j,j),&working(j,first),working.col_stride(),coefficients,end-first,n-j);
            }
        }
        lltcause::times[3]+=lltcause::elapsed(clock);
        first=end;
    }
    clock=lltcause::Clock::now();
    for(std::size_t first=0;first<n;first+=8) {
        const auto end=std::min(first+8,n);
        for(std::size_t column=0;column<first;column+=8) {
            const auto stop=std::min(column+8,first);
            for(std::size_t j=column;j<stop;++j) for(std::size_t i=first;i<end;++i) {
                storage(i,j)=storage(j,i);storage(j,i)=0;
            }
        }
        for(std::size_t i=first;i<end;++i) for(std::size_t j=first;j<i;++j) {
            storage(i,j)=storage(j,i);storage(j,i)=0;
        }
    }
    lltcause::times[4]+=lltcause::elapsed(clock);
    return LltAccess::create(storage);
}
#endif
inline Result<LltFactorView> factorize_contiguous_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {
    // Prevalidated input/storage; the public entry checks SIMD, layout and size.
    auto clock=lltcause::Clock::now();
    const auto n=input.rows();
    // Right-looking updates preserve ascending subtraction order per
    // coefficient. The unused upper triangle temporarily mirrors the
    // current lower column so every update reads contiguous rows.
    const auto copied=copy_into(input,storage);
    if (!copied) return copied;
    lltcause::times[1]+=lltcause::elapsed(clock);
    for (std::size_t first=0;first<n;) {
        clock=lltcause::Clock::now();
        const auto end=first+std::min(std::size_t{
#if defined(KIBO_DIAG_LLT_PANEL_WIDTH)
KIBO_DIAG_LLT_PANEL_WIDTH
#else
8
#endif
},n-first);
#if defined(KIBO_DIAG_LLT_BLOCK_SOLVE)
        for(std::size_t k=first;k<end;++k) {
            const double diagonal=storage(k,k);
            if(!std::isfinite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
            if(diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
            storage(k,k)=std::sqrt(diagonal);
            for(std::size_t i=k+1;i<end;++i) {
                const double value=storage(i,k)/storage(k,k);
                if(!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,k};
                storage(i,k)=value;storage(k,i)=value;
            }
            for(std::size_t i=k+1;i<end;++i)
                row_update(&storage(i,k+1),&storage(k,k+1),i-k,storage(i,k));
        }
        for(std::size_t i=end;i<n;++i) {
            for(std::size_t k=first;k<end;++k) {
                const double value=storage(i,k)/storage(k,k);
                if(!std::isfinite(value)) return Status{StatusCode::arithmetic_failure,k};
                storage(i,k)=value;storage(k,i)=value;
                if(k+1<end) row_update(&storage(i,k+1),&storage(k,k+1),end-k-1,value);
            }
        }
#else
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
                row_update(&storage(i,k+1),&storage(k,k+1),std::min(i+1,end)-k-1,storage(i,k));
        }
#endif
        lltcause::times[2]+=lltcause::elapsed(clock);
        clock=lltcause::Clock::now();
        std::size_t i=end;
#if defined(KIBO_DIAG_LLT_TWO_ROWS)
        for(;n-i>=2;i+=2) {
            row_update_two_rows_panel(&storage(i,end),&storage(first,end),storage.row_stride(),&storage(i,first),end-first,i-end+1);
            row_update_panel(&storage(i+1,i+1),&storage(first,i+1),storage.row_stride(),&storage(i+1,first),end-first,1);
        }
#endif
        for (;i<n;++i)
            row_update_panel(&storage(i,end),&storage(first,end),storage.row_stride(),
                         &storage(i,first),end-first,i-end+1);
        lltcause::times[3]+=lltcause::elapsed(clock);
        first=end;
    }
    clock=lltcause::Clock::now();
    // The public factor exposes a lower triangle, with upper entries 0.
    for (std::size_t i=0;i<n;++i)
        for (std::size_t j=i+1;j<n;++j) storage(i,j)=0;
    lltcause::times[4]+=lltcause::elapsed(clock);
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
    auto preclock=lltcause::Clock::now();
    const auto n=input.rows();
    if (n==0 || input.cols()!=n || !detail::same_shape(input,storage)) return StatusCode::invalid_shape;
    if (!std::isfinite(options.symmetry_tolerance) || options.symmetry_tolerance<0 || options.symmetry_tolerance>=1)
        return StatusCode::invalid_argument;
    if (!detail::finite(input)) return StatusCode::non_finite_input;
    if (options.check_symmetry) {
#if defined(KIBO_DIAG_LLT_EXACT_SYMMETRY)
        bool exactly_symmetric=true;
        for(std::size_t i=0;i<n && exactly_symmetric;++i)
            for(std::size_t j=0;j<i;++j)
                if(input(i,j)!=input(j,i)) { exactly_symmetric=false; break; }
        if(!exactly_symmetric) {
#endif
        double scale=0;
        for (std::size_t i=0;i<n;++i)
            for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));
        if (scale!=0) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<i;++j)
#if defined(KIBO_DIAG_LLT_FAST_SYM)
                    if(input(i,j)==input(j,i) ||
                       (options.symmetry_tolerance>=8*std::numeric_limits<double>::epsilon() &&
                        std::abs(input(i,j)-input(j,i))<=0.5*(options.symmetry_tolerance*scale))) continue;
                    else
#endif
                    if (std::abs(input(i,j)/scale-input(j,i)/scale)>options.symmetry_tolerance)
                        return Status{StatusCode::invalid_argument,i};
        }
    }
#if defined(KIBO_DIAG_LLT_EXACT_SYMMETRY)
        }
#endif
    if constexpr (detail::row_simd_available) {
        if (storage.col_stride()==1 && n>=64) {
            lltcause::times[0]+=lltcause::elapsed(preclock);
#if defined(KIBO_DIAG_LLT_COLUMN_WIDTH)
            return detail::factorize_column_llt(input,storage);
#else
            return detail::factorize_contiguous_llt(input,storage);
#endif
        }
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
