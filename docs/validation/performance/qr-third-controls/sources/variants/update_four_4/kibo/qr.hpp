#pragma once
#include <kibo/workspace.hpp>
#include <algorithm>
#include <kibo/detail/row_kernels.hpp>

namespace kibo::linalg {
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
    // Validation is complete. Later numerical failures invalidate all factor storage.
    if (packed.row_stride()==1 && input.col_stride()==1) {
        // Small tiles keep both sides local when copying rows into columns.
        for (std::size_t column=0;column<n;) {
            const auto stop_column=column+std::min(std::size_t{8},n-column);
            for (std::size_t row=0;row<m;) {
                const auto stop_row=row+std::min(std::size_t{8},m-row);
                for (std::size_t j=column;j<stop_column;++j)
                    for (std::size_t i=row;i<stop_row;++i) packed(i,j)=input(i,j);
                row=stop_row;
            }
            column=stop_column;
        }
    } else {
        for (std::size_t i=0;i<m;++i)
            for (std::size_t j=0;j<n;++j) packed(i,j)=input(i,j);
    }
    auto norms=prepared.value().first(n);
    auto initial_norms=prepared.value().subspan(n,n);
    for (std::size_t j=0;j<n;++j) {
        permutation[j]=j;
        initial_norms[j]=detail::column_norm(packed,0,j);
        if (!std::isfinite(initial_norms[j])) return Status{StatusCode::arithmetic_failure,j};
        norms[j]=initial_norms[j];
    }
    for (std::size_t k=0;k<n;++k) {
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
        const double norm=detail::column_norm(packed,k,k);
        if (!std::isfinite(norm)) return Status{StatusCode::arithmetic_failure,k};
        if (norm==0) { tau[k]=0; continue; }
        const double alpha=packed(k,k), beta=-std::copysign(norm,alpha);
        const double ratio=alpha/beta;
        tau[k]=1-ratio;
        // Ratios avoid overflow in alpha-beta for large finite columns.
        for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
        packed(k,k)=beta;
        if (packed.col_stride()<=packed.row_stride()) {
            // Future Householder coefficients are not assigned yet. Reuse
            // tau[k+1:n] for this projection; each slot is overwritten when
            // its own column is factored. Workspace remains 2n doubles.
            const auto first=k+1,count=n-k-1;
            const auto last=first+count;
            for (std::size_t j=first;j<last;++j) tau[j]=packed(k,j);
            std::size_t projection_row=k+1;
            if (packed.col_stride()==1 && count>=16) {
                for (;m-projection_row>=4;projection_row+=4)
                    detail::row_project_four_rows(tau.data()+first,&packed(projection_row,first),packed.row_stride(),&packed(projection_row,k),count);
            }
            for (;projection_row<m;++projection_row) {
                const double value=packed(projection_row,k);
                if (packed.col_stride()==1 && count!=0) detail::row_project(tau.data()+first,&packed(projection_row,first),count,value);
                else for (std::size_t j=first;j<last;++j) tau[j]+=value*packed(projection_row,j);
            }
            for (std::size_t j=first;j<last;++j) {
                tau[j]*=tau[k];
                if (!std::isfinite(tau[j])) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=tau[j];
                if (!std::isfinite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
            }
            std::size_t update_row=k+1;
            if (packed.col_stride()==1 && count>=4) {
                for (;m-update_row>=4;update_row+=4)
                    if (!detail::row_update_four_checked(&packed(update_row,first),packed.row_stride(),tau.data()+first,&packed(update_row,k),count))
                        return Status{StatusCode::arithmetic_failure,k};
            }
            for (std::size_t i=update_row;i<m;++i) {
                const double value=packed(i,k);
                if (packed.col_stride()==1 && count!=0) {
                    if (!detail::row_update_checked(&packed(i,first),tau.data()+first,count,value))
                        return Status{StatusCode::arithmetic_failure,k};
                } else for (std::size_t j=first;j<last;++j) {
                    packed(i,j)-=value*tau[j];
                    if (!std::isfinite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
                }
            }
        } else {
            std::size_t j=k+1;
            if(packed.row_stride()==1 && m-k>1) {
                for(;n-j>=4;j+=4) {
                    for(std::size_t a=0;a<4;++a) tau[j+a]=packed(k,j+a);
                    detail::column_project_four(tau.data()+j,&packed(k+1,j),packed.col_stride(),&packed(k+1,k),m-k-1);
                    for(std::size_t a=0;a<4;++a) {
                        const double multiplier=tau[k]*tau[j+a];
                        tau[j+a]=multiplier;
                        if(!std::isfinite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                        packed(k,j+a)-=multiplier;
                        if(!std::isfinite(packed(k,j+a))) return Status{StatusCode::arithmetic_failure,k};
                    }
                    if (!detail::column_update_four_checked(&packed(k+1,j),packed.col_stride(),&packed(k+1,k),m-k-1,tau.data()+j))
                        return Status{StatusCode::arithmetic_failure,k};
                }
            }
            for (;j<n;++j) {
                double dot=packed(k,j);
                if(packed.row_stride()==1 && m-k>1)
                    dot=detail::contiguous_dot(&packed(k+1,k),&packed(k+1,j),m-k-1,dot);
                else
                for (std::size_t i=k+1;i<m;++i) dot+=packed(i,k)*packed(i,j);
                const double multiplier=tau[k]*dot;
                if (!std::isfinite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=multiplier;
                if (!std::isfinite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
                if(packed.row_stride()==1 && m-k>1) {
                    if(!detail::row_update_checked(&packed(k+1,j),&packed(k+1,k),m-k-1,multiplier))
                        return Status{StatusCode::arithmetic_failure,k};
                } else
                for (std::size_t i=k+1;i<m;++i) {
                    packed(i,j)-=packed(i,k)*multiplier;
                    if (!std::isfinite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
                }
            }
        }
        for (std::size_t j=k+1;j<n;++j) {
            if (norms[j]!=0) {
                // LAPACK DLAQP2 partial norm update, with cancellation-triggered
                // explicit recomputation (Working Note 176). No extra storage.
                const double removed=std::abs(packed(k,j))/norms[j];
                const double remaining=std::max(0.0,(1-removed)*(1+removed));
                const double relative=norms[j]/initial_norms[j];
                if (remaining*relative*relative<=std::sqrt(std::numeric_limits<double>::epsilon())) {
                    norms[j]=detail::column_norm(packed,k+1,j);
                    initial_norms[j]=norms[j];
                } else norms[j]*=std::sqrt(remaining);
            }
        }
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
        if(packed.row_stride()==1 && m-k>1)
            dot=detail::contiguous_dot(&packed(k+1,k),transformed.data()+k+1,m-k-1,dot);
        else
        for (std::size_t i=k+1;i<m;++i) dot+=packed(i,k)*transformed[i];
        const double multiplier=factor.tau()[k]*dot;
        if (!std::isfinite(multiplier)) return {StatusCode::arithmetic_failure,k};
        transformed[k]-=multiplier;
        if (!std::isfinite(transformed[k])) return {StatusCode::arithmetic_failure,k};
        if(packed.row_stride()==1 && m-k>1) {
            if(!detail::row_update_checked(transformed.data()+k+1,&packed(k+1,k),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        } else
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
    for (std::size_t i=0;i<n;++i) output[factor.permutation()[i]]=candidate[i];
    return {};
}
} // namespace kibo::linalg
