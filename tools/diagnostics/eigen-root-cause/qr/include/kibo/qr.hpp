// DIAGNOSTIC SNAPSHOT ONLY: not an installed library header.
#pragma once
#include <kibo/workspace.hpp>
#include <algorithm>
#include <chrono>
#include <kibo/detail/row_kernels.hpp>

namespace kibo::linalg {
namespace cause { inline double times[6]{}; using Clock=std::chrono::steady_clock; inline double elapsed(Clock::time_point t){return std::chrono::duration<double>(Clock::now()-t).count();} }
// Identical instrumentation for every ablation. These are inclusive arithmetic
// timings, not formal benchmark samples or allocation observations.
namespace qr_ablation {
inline double preflight_seconds{}, copy_seconds{}, initial_norm_seconds{};
inline double pivot_seconds{}, selected_norm_seconds{}, vector_seconds{};
inline std::size_t factor_calls{}, selected_norm_calls{}, refreshed_norm_calls{};
inline void reset() noexcept {
    preflight_seconds=copy_seconds=initial_norm_seconds=0;
    pivot_seconds=selected_norm_seconds=vector_seconds=0;
    factor_calls=selected_norm_calls=refreshed_norm_calls=0;
}
}
struct QrOptions { std::optional<double> relative_rank_tolerance; };
struct QrDiagnostics {
    std::size_t rank=0;
    double tolerance=0;
    std::span<const std::size_t> permutation;
};
struct QrFactorRequirement {
    WorkspaceRequirement packed, tau, permutation, workspace;
};
namespace detail { struct QrAccess; }
class QrFactorView {
    friend struct detail::QrAccess;
    MatrixView<const double> packed_;
    std::span<const double> tau_;
    std::span<const std::size_t> permutation_;
    QrDiagnostics diagnostics_;
    QrFactorView(MatrixView<const double> packed, std::span<const double> tau,
                 std::span<const std::size_t> permutation, QrDiagnostics diagnostics) noexcept
        : packed_(packed),tau_(tau),permutation_(permutation),diagnostics_(diagnostics) {}
public:
    QrFactorView() noexcept = default;
    bool valid() const noexcept { return packed_.cols()!=0; }
    MatrixView<const double> packed() const noexcept { return packed_; }
    std::span<const double> tau() const noexcept { return tau_; }
    std::span<const std::size_t> permutation() const noexcept { return permutation_; }
    QrDiagnostics diagnostics() const noexcept { return diagnostics_; }
};
namespace detail {
struct QrAccess {
    static QrFactorView create(MatrixView<const double> packed, std::span<const double> tau,
                              std::span<const std::size_t> permutation, QrDiagnostics diagnostics) noexcept {
        return QrFactorView(packed,tau,permutation,diagnostics);
    }
};
inline bool ablation_column_update_checked(double* row,const double* projection,std::size_t count,double value) noexcept {
#if defined(KIBO_QR_ABLATION_CPP_COLUMN)
    bool finite=true;
#if defined(_MSC_VER)
#pragma loop(no_vector)
#endif
    for (std::size_t i=0;i<count;++i) {
        row[i]-=value*projection[i];
        finite&=std::isfinite(row[i]);
    }
    return finite;
#else
    return row_update_checked(row,projection,count,value);
#endif
}
inline bool factor_column_update(double* row,const double* projection,std::size_t count,double value) noexcept {
#if defined(KIBO_DIAG_DEFER_FACTOR_CHECK)
    row_update(row,projection,count,value);return true;
#else
    return ablation_column_update_checked(row,projection,count,value);
#endif
}
inline double column_norm(MatrixView<const double> matrix, std::size_t first, std::size_t column) noexcept {
    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();
}

}

inline Result<QrFactorRequirement> qr_factor_requirement(std::size_t m, std::size_t n) noexcept {
    if (n==0 || m<n) return StatusCode::invalid_shape;
    const auto maximum=std::numeric_limits<std::size_t>::max();
    if (m>maximum/n || n>maximum/2 || n>maximum/sizeof(std::size_t)) return StatusCode::size_overflow;
    auto packed=detail::double_requirement(m*n);
    auto tau=detail::double_requirement(n);
    auto workspace=detail::double_requirement(2*n);
    if (!packed) return packed.status();
    if (!tau) return tau.status();
    if (!workspace) return workspace.status();
    return QrFactorRequirement{packed.value(),tau.value(),
        WorkspaceRequirement{n*sizeof(std::size_t),alignof(std::size_t)},workspace.value()};
}
inline Result<WorkspaceRequirement> qr_solve_requirement(std::size_t m, std::size_t n) noexcept {
    if (n==0 || m<n) return StatusCode::invalid_shape;
    if (n>std::numeric_limits<std::size_t>::max()-m) return StatusCode::size_overflow;
    return detail::double_requirement(m+n);
}

inline Result<QrFactorView> factorize_qr(MatrixView<const double> input, MatrixView<double> packed,
                                        std::span<double> tau, std::span<std::size_t> permutation,
                                        std::span<std::byte> workspace, QrOptions options={},
                                        QrDiagnostics* diagnostics=nullptr) noexcept {
    auto clock=cause::Clock::now();
    const auto m=input.rows(),n=input.cols();
    auto required=qr_factor_requirement(m,n);
    if (!required) return required.status();
    if (!detail::same_shape(input,packed)) return StatusCode::invalid_shape;
    if (tau.size()<n || permutation.size()<n) return StatusCode::insufficient_capacity;
    if (reinterpret_cast<std::uintptr_t>(tau.data())%alignof(double)!=0 ||
        reinterpret_cast<std::uintptr_t>(permutation.data())%alignof(std::size_t)!=0) return StatusCode::invalid_layout;
    const double tolerance=options.relative_rank_tolerance.value_or(static_cast<double>(m)*std::numeric_limits<double>::epsilon());
    if (!std::isfinite(tolerance) || tolerance<0 || tolerance>=1) return StatusCode::invalid_argument;
    auto prepared=detail::workspace_doubles(workspace,required.value().workspace);
    if (!prepared) return prepared.status();
    if (!detail::finite(input)) return StatusCode::non_finite_input;
    qr_ablation::preflight_seconds+=cause::elapsed(clock);
    ++qr_ablation::factor_calls;
    auto detail_clock=cause::Clock::now();
    // Validation is complete. Later numerical failures invalidate all factor storage.
#if defined(KIBO_DIAG_TILE_COPY)
    for(std::size_t column=0;column<n;column+=8) for(std::size_t row=0;row<m;row+=8) {
        const auto stop_column=std::min(column+8,n),stop_row=std::min(row+8,m);
        for(std::size_t j=column;j<stop_column;++j) for(std::size_t i=row;i<stop_row;++i)
            packed(i,j)=input(i,j);
    }
#elif defined(KIBO_QR_ABLATION_COPY_PREVALIDATED)
    // Same row-major traversal as copy_into, after the same public preflight.
    // This removes ONLY copy_into's second shape/finite-input validation.
    for (std::size_t i=0;i<m;++i)
        for (std::size_t j=0;j<n;++j) packed(i,j)=input(i,j);
#else
    const auto copied=copy_into(input,packed);
    if (!copied) return copied;
#endif
    qr_ablation::copy_seconds+=cause::elapsed(detail_clock);
    detail_clock=cause::Clock::now();
    auto norms=prepared.value().first(n);
    auto initial_norms=prepared.value().subspan(n,n);
    for (std::size_t j=0;j<n;++j) {
        permutation[j]=j;
        initial_norms[j]=detail::column_norm(packed,0,j);
        if (!std::isfinite(initial_norms[j])) return Status{StatusCode::arithmetic_failure,j};
        norms[j]=initial_norms[j];
    }
    qr_ablation::initial_norm_seconds+=cause::elapsed(detail_clock);
    cause::times[0]+=cause::elapsed(clock);
    for (std::size_t k=0;k<n;++k) {
        clock=cause::Clock::now();
        detail_clock=clock;
        std::size_t pivot=k;
        for (std::size_t j=k;j<n;++j) {
            if (norms[j]>norms[pivot]) pivot=j;
        }
        if (pivot!=k) {
            for (std::size_t i=0;i<m;++i) std::swap(packed(i,k),packed(i,pivot));
            std::swap(permutation[k],permutation[pivot]);
            std::swap(norms[k],norms[pivot]);
            std::swap(initial_norms[k],initial_norms[pivot]);
        }
        qr_ablation::pivot_seconds+=cause::elapsed(detail_clock);
        detail_clock=cause::Clock::now();
        const double norm=detail::column_norm(packed,k,k);
        qr_ablation::selected_norm_seconds+=cause::elapsed(detail_clock);
        ++qr_ablation::selected_norm_calls;
        if (!std::isfinite(norm)) return Status{StatusCode::arithmetic_failure,k};
        if (norm==0) { tau[k]=0; continue; }
        detail_clock=cause::Clock::now();
        const double alpha=packed(k,k), beta=-std::copysign(norm,alpha);
        const double ratio=alpha/beta;
        tau[k]=1-ratio;
        // Ratios avoid overflow in alpha-beta for large finite columns.
        for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
        packed(k,k)=beta;
        qr_ablation::vector_seconds+=cause::elapsed(detail_clock);
        cause::times[1]+=cause::elapsed(clock);
        clock=cause::Clock::now();
        if (packed.col_stride()<=packed.row_stride()) {
            // Future Householder coefficients are not assigned yet. Reuse
            // tau[k+1:n] for this projection; each slot is overwritten when
            // its own column is factored. Workspace remains 2n doubles.
            const auto first=k+1,count=n-k-1;
            const auto last=first+count;
            for (std::size_t j=first;j<last;++j) tau[j]=packed(k,j);
            std::size_t i=k+1;
#if defined(KIBO_DIAG_PROJECT_ROWS)
            if (packed.col_stride()==1 && count!=0) {
                for(;m-i>=4;i+=4) detail::row_project_four_rows(tau.data()+first,&packed(i,first),packed.row_stride(),&packed(i,k),count);
            }
#endif
            for (;i<m;++i) {
                const double value=packed(i,k);
                if (packed.col_stride()==1 && count!=0) detail::row_project(tau.data()+first,&packed(i,first),count,value);
                else for (std::size_t j=first;j<last;++j) tau[j]+=value*packed(i,j);
            }
            cause::times[2]+=cause::elapsed(clock);
            clock=cause::Clock::now();
            for (std::size_t j=first;j<last;++j) {
                tau[j]*=tau[k];
                if (!std::isfinite(tau[j])) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=tau[j];
                if (!std::isfinite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
            }
            for (std::size_t i=k+1;i<m;++i) {
                const double value=packed(i,k);
                if (packed.col_stride()==1 && count!=0) {
#if defined(KIBO_DIAG_SKIP_UPDATE_CHECK)
                    detail::row_update(&packed(i,first),tau.data()+first,count,value);
#else
                    if (!detail::factor_column_update(&packed(i,first),tau.data()+first,count,value))
                        return Status{StatusCode::arithmetic_failure,k};
#endif
                } else for (std::size_t j=first;j<last;++j) {
                    packed(i,j)-=value*tau[j];
                    if (!std::isfinite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
                }
            }
        } else {
            std::size_t j=k+1;
#if defined(KIBO_DIAG_COLUMN_FOUR)
            if(packed.row_stride()==1 && m-k>1) {
                for(;n-j>=4;j+=4) {
                    for(std::size_t a=0;a<4;++a) tau[j+a]=packed(k,j+a);
                    detail::column_project_four(tau.data()+j,&packed(k+1,j),packed.col_stride(),&packed(k+1,k),m-k-1);
                    for(std::size_t a=0;a<4;++a) {
                        const double multiplier=tau[k]*tau[j+a];
                        if(!std::isfinite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                        packed(k,j+a)-=multiplier;
                        if(!std::isfinite(packed(k,j+a))) return Status{StatusCode::arithmetic_failure,k};
                        if(!detail::factor_column_update(&packed(k+1,j+a),&packed(k+1,k),m-k-1,multiplier))
                            return Status{StatusCode::arithmetic_failure,k};
                    }
                }
            }
#endif
            for (;j<n;++j) {
                double dot=packed(k,j);
#if defined(KIBO_DIAG_COLUMN_KERNEL)
                if(packed.row_stride()==1 && m-k>1)
                    dot=detail::contiguous_dot(&packed(k+1,k),&packed(k+1,j),m-k-1,dot);
                else
#endif
                for (std::size_t i=k+1;i<m;++i) dot+=packed(i,k)*packed(i,j);
                const double multiplier=tau[k]*dot;
                if (!std::isfinite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=multiplier;
                if (!std::isfinite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
#if defined(KIBO_DIAG_COLUMN_KERNEL)
                if(packed.row_stride()==1 && m-k>1) {
                    if(!detail::factor_column_update(&packed(k+1,j),&packed(k+1,k),m-k-1,multiplier))
                        return Status{StatusCode::arithmetic_failure,k};
                } else
#endif
                for (std::size_t i=k+1;i<m;++i) {
                    packed(i,j)-=packed(i,k)*multiplier;
                    if (!std::isfinite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
                }
            }
        }
        cause::times[3]+=cause::elapsed(clock);
        clock=cause::Clock::now();
        for (std::size_t j=k+1;j<n;++j) {
            if (norms[j]!=0) {
                // LAPACK DLAQP2 partial norm update, with cancellation-triggered
                // explicit recomputation (Working Note 176). No extra storage.
                const double removed=std::abs(packed(k,j))/norms[j];
                const double remaining=std::max(0.0,(1-removed)*(1+removed));
                const double relative=norms[j]/initial_norms[j];
                if (remaining*relative*relative<=std::sqrt(std::numeric_limits<double>::epsilon())) {
                    ++qr_ablation::refreshed_norm_calls;
                    norms[j]=detail::column_norm(packed,k+1,j);
                    initial_norms[j]=norms[j];
                } else norms[j]*=std::sqrt(remaining);
            }
        }
        cause::times[4]+=cause::elapsed(clock);
    }
    double maximum_diagonal=0;
    for (std::size_t i=0;i<n;++i) if (std::abs(packed(i,i))>maximum_diagonal) maximum_diagonal=std::abs(packed(i,i));
    std::size_t rank=0;
    for (std::size_t i=0;i<n;++i) if (std::abs(packed(i,i))>tolerance*maximum_diagonal) ++rank;
    const QrDiagnostics observed{rank,tolerance,permutation.first(n)};
    if (diagnostics) *diagnostics=observed;
    if (rank<n) return Status{StatusCode::rank_deficient,rank,rank};
    return detail::QrAccess::create(packed,tau.first(n),permutation.first(n),observed);
}

inline Status solve_into(QrFactorView factor, std::span<const double> rhs, std::span<double> output,
                         std::span<std::byte> workspace) noexcept {
    auto solve_clock=cause::Clock::now();
    if (!factor.valid()) return {StatusCode::invalid_factor};
    auto packed=factor.packed();
    const auto m=packed.rows(),n=packed.cols();
    if (rhs.size()!=m || output.size()!=n) return {StatusCode::invalid_shape};
    auto requirement=qr_solve_requirement(m,n);
    if (!requirement) return requirement.status();
    auto prepared=detail::workspace_doubles(workspace,requirement.value());
    if (!prepared) return prepared.status();
    for (auto value:rhs) if (!std::isfinite(value)) return {StatusCode::non_finite_input};
    auto transformed=prepared.value().first(m);
    auto candidate=prepared.value().subspan(m,n);
    for (std::size_t i=0;i<m;++i) transformed[i]=rhs[i];
    for (std::size_t k=0;k<n;++k) {
        if (factor.tau()[k]==0) continue;
        double dot=transformed[k];
#if defined(KIBO_DIAG_COLUMN_KERNEL)
        if(packed.row_stride()==1 && m-k>1)
            dot=detail::contiguous_dot(&packed(k+1,k),transformed.data()+k+1,m-k-1,dot);
        else
#endif
        for (std::size_t i=k+1;i<m;++i) dot+=packed(i,k)*transformed[i];
        const double multiplier=factor.tau()[k]*dot;
        if (!std::isfinite(multiplier)) return {StatusCode::arithmetic_failure,k};
        transformed[k]-=multiplier;
        if (!std::isfinite(transformed[k])) return {StatusCode::arithmetic_failure,k};
#if defined(KIBO_DIAG_COLUMN_KERNEL)
        if(packed.row_stride()==1 && m-k>1) {
            if(!detail::ablation_column_update_checked(transformed.data()+k+1,&packed(k+1,k),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        } else
#endif
        for (std::size_t i=k+1;i<m;++i) {
            transformed[i]-=packed(i,k)*multiplier;
            if (!std::isfinite(transformed[i])) return {StatusCode::arithmetic_failure,k};
        }
    }
    for (std::size_t i=n;i-->0;) {
        double value=transformed[i];
        for (std::size_t j=i+1;j<n;++j) value-=packed(i,j)*candidate[j];
        value/=packed(i,i);
        if (!std::isfinite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    cause::times[5]+=cause::elapsed(solve_clock);
    for (std::size_t i=0;i<n;++i) output[factor.permutation()[i]]=candidate[i];
    return {};
}
} // namespace kibo::linalg
