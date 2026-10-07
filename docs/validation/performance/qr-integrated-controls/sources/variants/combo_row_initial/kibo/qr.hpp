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
inline bool qr_input_finite(MatrixView<const double> input) noexcept {
    const auto check=[](const double* values,std::size_t count) noexcept {
        std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
        auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
        for(;count-i>=2;i+=2) {
            const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));
            valid=_mm_and_pd(valid,_mm_cmple_pd(absolute,limit));
        }
        if(_mm_movemask_pd(valid)!=3)return false;
#endif
        for(;i<count;++i)if(!(std::abs(values[i])<=std::numeric_limits<double>::max()))return false;
        return true;
    };
    if(input.col_stride()==1) {
        for(std::size_t i=0;i<input.rows();++i)if(!check(&input(i,0),input.cols()))return false;
        return true;
    }
    if(input.row_stride()==1) {
        for(std::size_t j=0;j<input.cols();++j)if(!check(&input(0,j),input.rows()))return false;
        return true;
    }
    return finite(input);
}
inline bool qr_is_finite(double value) noexcept {
    return std::abs(value)<=std::numeric_limits<double>::max();
}
inline bool qr_strided_update_checked(double* vector,const double* values,std::size_t stride,
                                     std::size_t count,double multiplier) noexcept {
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto factor=_mm_set1_pd(multiplier),sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
    for (;count-i>=2;i+=2) {
        const auto x=_mm_set_pd(values[(i+1)*stride],values[i*stride]);
        const auto result=_mm_sub_pd(_mm_loadu_pd(vector+i),_mm_mul_pd(factor,x));
        _mm_storeu_pd(vector+i,result);
        valid=_mm_and_pd(valid,_mm_cmple_pd(_mm_andnot_pd(sign,result),limit));
    }
    if (_mm_movemask_pd(valid)!=3) return false;
#endif
    for (;i<count;++i) {
        vector[i]-=values[i*stride]*multiplier;
        if (!detail::qr_is_finite(vector[i])) return false;
    }
    return true;
}
inline double qr_strided_dot(const double* values,std::size_t stride,const double* vector,
                              std::size_t count,double initial) noexcept {
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    auto a=_mm_setzero_pd(),b=a;
    for (;count-i>=4;i+=4) {
        const auto x=_mm_set_pd(values[(i+1)*stride],values[i*stride]);
        const auto y=_mm_set_pd(values[(i+3)*stride],values[(i+2)*stride]);
        a=_mm_add_pd(a,_mm_mul_pd(x,_mm_loadu_pd(vector+i)));
        b=_mm_add_pd(b,_mm_mul_pd(y,_mm_loadu_pd(vector+i+2)));
    }
    const auto sum=_mm_add_pd(a,b);
    initial+=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
#endif
    for (;i<count;++i) initial+=values[i*stride]*vector[i];
    return initial;
}
struct QrAccess {
    static QrFactorView create(MatrixView<const double> packed, std::span<const double> tau,
                              std::span<const std::size_t> permutation, QrDiagnostics diagnostics) noexcept {
        return QrFactorView(packed,tau,permutation,diagnostics);
    }
};
inline double column_norm(MatrixView<const double> matrix, std::size_t first, std::size_t column) noexcept {
    const auto count=matrix.rows()-first;
    if(count>=16) {
        double maximum=0;std::size_t i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        if(matrix.row_stride()==1) {
            const auto sign=_mm_set1_pd(-0.0);auto a=_mm_setzero_pd(),b=a;
            for(;matrix.rows()-i>=4;i+=4) {
                a=_mm_max_pd(a,_mm_andnot_pd(sign,_mm_loadu_pd(&matrix(i,column))));
                b=_mm_max_pd(b,_mm_andnot_pd(sign,_mm_loadu_pd(&matrix(i+2,column))));
            }
            const auto largest=_mm_max_pd(a,b);
            maximum=std::max(_mm_cvtsd_f64(largest),_mm_cvtsd_f64(_mm_unpackhi_pd(largest,largest)));
        }
#endif
        for(;i<matrix.rows();++i)maximum=std::max(maximum,std::abs(matrix(i,column)));
        const double upper=.5*std::sqrt(std::numeric_limits<double>::max()/static_cast<double>(count));
        const double lower=std::sqrt(std::numeric_limits<double>::min()*static_cast<double>(count)/std::numeric_limits<double>::epsilon());
        if(maximum>=lower && maximum<=upper) {
            double squared=0;i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
            if(matrix.row_stride()==1) {
                auto a=_mm_setzero_pd(),b=a;
                for(;matrix.rows()-i>=4;i+=4) {
                    const auto x=_mm_loadu_pd(&matrix(i,column)),y=_mm_loadu_pd(&matrix(i+2,column));
                    a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
                }
                const auto sum=_mm_add_pd(a,b);
                squared=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
            }
#endif
            for(;i<matrix.rows();++i){const double value=matrix(i,column);squared+=value*value;}
            return std::sqrt(squared);
        }
    }
    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();
}
// Private width8 initial-norm scan; each lane sums rows in increasing order.
inline void qr_initial_norms(MatrixView<const double> packed,std::span<double> norms) noexcept {
    const auto m=packed.rows(),n=packed.cols();std::size_t j=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    if(packed.col_stride()==1 && m>=16) {
        const auto sign=_mm_set1_pd(-0.0);
        const auto upper=_mm_set1_pd(.5*std::sqrt(std::numeric_limits<double>::max()/static_cast<double>(m)));
        const auto lower=_mm_set1_pd(std::sqrt(std::numeric_limits<double>::min()*static_cast<double>(m)/std::numeric_limits<double>::epsilon()));
        for(;n-j>=8;j+=8) {
            auto a=_mm_setzero_pd(),b=a,c=a,d=a;
            for(std::size_t i=0;i<m;++i) {
                const auto* row=&packed(i,j);
                a=_mm_max_pd(a,_mm_andnot_pd(sign,_mm_loadu_pd(row)));
                b=_mm_max_pd(b,_mm_andnot_pd(sign,_mm_loadu_pd(row+2)));
                c=_mm_max_pd(c,_mm_andnot_pd(sign,_mm_loadu_pd(row+4)));
                d=_mm_max_pd(d,_mm_andnot_pd(sign,_mm_loadu_pd(row+6)));
            }
            const auto minimum=_mm_min_pd(_mm_min_pd(a,b),_mm_min_pd(c,d));
            const auto maximum=_mm_max_pd(_mm_max_pd(a,b),_mm_max_pd(c,d));
            if(_mm_movemask_pd(_mm_and_pd(_mm_cmpge_pd(minimum,lower),_mm_cmple_pd(maximum,upper)))==3) {
                a=b=c=d=_mm_setzero_pd();
                for(std::size_t i=0;i<m;++i) {
                    const auto* row=&packed(i,j);
                    const auto x=_mm_loadu_pd(row),y=_mm_loadu_pd(row+2),z=_mm_loadu_pd(row+4),w=_mm_loadu_pd(row+6);
                    a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
                    c=_mm_add_pd(c,_mm_mul_pd(z,z));d=_mm_add_pd(d,_mm_mul_pd(w,w));
                }
                _mm_storeu_pd(norms.data()+j,_mm_sqrt_pd(a));_mm_storeu_pd(norms.data()+j+2,_mm_sqrt_pd(b));
                _mm_storeu_pd(norms.data()+j+4,_mm_sqrt_pd(c));_mm_storeu_pd(norms.data()+j+6,_mm_sqrt_pd(d));
            } else for(std::size_t k=0;k<8;++k)norms[j+k]=column_norm(packed,0,j+k);
        }
    }
#endif
    for(;j<n;++j)norms[j]=column_norm(packed,0,j);
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
    if (!detail::qr_is_finite(tolerance) || tolerance<0 || tolerance>=1) return StatusCode::invalid_argument;
    auto prepared=detail::workspace_doubles(workspace,required.value().workspace);
    if (!prepared) return prepared.status();
    if (!detail::qr_input_finite(input)) return StatusCode::non_finite_input;
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
    detail::qr_initial_norms(packed,initial_norms);
    for (std::size_t j=0;j<n;++j) {
        permutation[j]=j;

        if (!detail::qr_is_finite(initial_norms[j])) return Status{StatusCode::arithmetic_failure,j};
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
        if (!detail::qr_is_finite(norm)) return Status{StatusCode::arithmetic_failure,k};
        if (norm==0) { tau[k]=0; continue; }
        const double alpha=packed(k,k), beta=-std::copysign(norm,alpha);
        const double ratio=alpha/beta;
        tau[k]=1-ratio;
        // Ratios avoid overflow in alpha-beta for large finite columns.
        if (std::abs(alpha)<=std::numeric_limits<double>::max()-std::abs(beta)) {
            const double denominator=alpha-beta;
            if (std::abs(denominator)>=std::numeric_limits<double>::min() && std::abs(denominator)<=1/std::numeric_limits<double>::min()) {
                const double inverse=1/denominator;
                for (std::size_t i=k+1;i<m;++i) packed(i,k)=packed(i,k)*inverse;
            } else {
                for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
            }
        } else {
            for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
        }
        packed(k,k)=beta;
        if (packed.col_stride()<=packed.row_stride()) {
            // Future Householder coefficients are not assigned yet. Reuse
            // tau[k+1:n] for this projection; each slot is overwritten when
            // its own column is factored. Workspace remains 2n doubles.
            const auto first=k+1,count=n-k-1;
            const auto last=first+count;
            for (std::size_t j=first;j<last;++j) tau[j]=packed(k,j);
            std::size_t projection_row=k+1;
            if (packed.col_stride()==1 && count>=4) {
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
                if (!detail::qr_is_finite(tau[j])) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=tau[j];
                if (!detail::qr_is_finite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
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
                    if (!detail::qr_is_finite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
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
                        if(!detail::qr_is_finite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                        packed(k,j+a)-=multiplier;
                        if(!detail::qr_is_finite(packed(k,j+a))) return Status{StatusCode::arithmetic_failure,k};
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
                if (!detail::qr_is_finite(multiplier)) return Status{StatusCode::arithmetic_failure,k};
                packed(k,j)-=multiplier;
                if (!detail::qr_is_finite(packed(k,j))) return Status{StatusCode::arithmetic_failure,k};
                if(packed.row_stride()==1 && m-k>1) {
                    if(!detail::row_update_checked(&packed(k+1,j),&packed(k+1,k),m-k-1,multiplier))
                        return Status{StatusCode::arithmetic_failure,k};
                } else
                for (std::size_t i=k+1;i<m;++i) {
                    packed(i,j)-=packed(i,k)*multiplier;
                    if (!detail::qr_is_finite(packed(i,j))) return Status{StatusCode::arithmetic_failure,k};
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
    for (auto value:rhs) if (!detail::qr_is_finite(value)) return {StatusCode::non_finite_input};
    auto transformed=prepared.value().first(m);
    auto candidate=prepared.value().subspan(m,n);
    for (std::size_t i=0;i<m;++i) transformed[i]=rhs[i];
    for (std::size_t k=0;k<n;++k) {
        if (factor.tau()[k]==0) continue;
        double dot=transformed[k];
        if(packed.row_stride()==1 && m-k>1)
            dot=detail::contiguous_dot(&packed(k+1,k),transformed.data()+k+1,m-k-1,dot);
        else if (m-k>1)
            dot=detail::qr_strided_dot(&packed(k+1,k),packed.row_stride(),transformed.data()+k+1,m-k-1,dot);
        const double multiplier=factor.tau()[k]*dot;
        if (!detail::qr_is_finite(multiplier)) return {StatusCode::arithmetic_failure,k};
        transformed[k]-=multiplier;
        if (!detail::qr_is_finite(transformed[k])) return {StatusCode::arithmetic_failure,k};
        if(packed.row_stride()==1 && m-k>1) {
            if(!detail::row_update_checked(transformed.data()+k+1,&packed(k+1,k),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        } else if (m-k>1) {
            if (!detail::qr_strided_update_checked(transformed.data()+k+1,&packed(k+1,k),packed.row_stride(),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        }
    }
    for (std::size_t i=n;i-->0;) {
        double value=transformed[i];
        for (std::size_t j=i+1;j<n;++j) value-=packed(i,j)*candidate[j];
        value/=packed(i,i);
        if (!detail::qr_is_finite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    for (std::size_t i=0;i<n;++i) output[factor.permutation()[i]]=candidate[i];
    return {};
}
} // namespace kibo::linalg
