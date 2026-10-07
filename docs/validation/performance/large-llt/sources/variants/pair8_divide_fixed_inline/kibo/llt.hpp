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

__forceinline void update_column_pair(double* first, double* second, const double* panel,
                               std::size_t stride, const double* coefficients,
                               std::size_t /*width*/, std::size_t count) noexcept {
    constexpr std::size_t width=8;
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    for (;count-i>=8;i+=8) {
        auto a0=_mm_loadu_pd(first+i),a1=_mm_loadu_pd(first+i+2);
        auto a2=_mm_loadu_pd(first+i+4),a3=_mm_loadu_pd(first+i+6);
        auto b0=_mm_loadu_pd(second+i),b1=_mm_loadu_pd(second+i+2);
        auto b2=_mm_loadu_pd(second+i+4),b3=_mm_loadu_pd(second+i+6);
        for (std::size_t k=0;k<width;++k) {
            const auto pair=_mm_loadu_pd(coefficients+k*stride);
            const auto a=_mm_unpacklo_pd(pair,pair),b=_mm_unpackhi_pd(pair,pair);
            const auto p0=_mm_loadu_pd(panel+k*stride+i),p1=_mm_loadu_pd(panel+k*stride+i+2);
            const auto p2=_mm_loadu_pd(panel+k*stride+i+4),p3=_mm_loadu_pd(panel+k*stride+i+6);
            a0=_mm_sub_pd(a0,_mm_mul_pd(a,p0));b0=_mm_sub_pd(b0,_mm_mul_pd(b,p0));
            a1=_mm_sub_pd(a1,_mm_mul_pd(a,p1));b1=_mm_sub_pd(b1,_mm_mul_pd(b,p1));
            a2=_mm_sub_pd(a2,_mm_mul_pd(a,p2));b2=_mm_sub_pd(b2,_mm_mul_pd(b,p2));
            a3=_mm_sub_pd(a3,_mm_mul_pd(a,p3));b3=_mm_sub_pd(b3,_mm_mul_pd(b,p3));
        }
        _mm_storeu_pd(first+i,a0);_mm_storeu_pd(first+i+2,a1);
        _mm_storeu_pd(first+i+4,a2);_mm_storeu_pd(first+i+6,a3);
        _mm_storeu_pd(second+i,b0);_mm_storeu_pd(second+i+2,b1);
        _mm_storeu_pd(second+i+4,b2);_mm_storeu_pd(second+i+6,b3);
    }
    for (;count-i>=2;i+=2) {
        auto a0=_mm_loadu_pd(first+i),b0=_mm_loadu_pd(second+i);
        for (std::size_t k=0;k<width;++k) {
            const auto pair=_mm_loadu_pd(coefficients+k*stride);
            const auto p=_mm_loadu_pd(panel+k*stride+i);
            a0=_mm_sub_pd(a0,_mm_mul_pd(_mm_unpacklo_pd(pair,pair),p));
            b0=_mm_sub_pd(b0,_mm_mul_pd(_mm_unpackhi_pd(pair,pair),p));
        }
        _mm_storeu_pd(first+i,a0);_mm_storeu_pd(second+i,b0);
    }
#endif
    for (;i<count;++i) for (std::size_t k=0;k<width;++k) {
        first[i]-=coefficients[k*stride]*panel[k*stride+i];
        second[i]-=coefficients[k*stride+1]*panel[k*stride+i];
    }
}


inline bool divide_contiguous_checked(double* values,std::size_t count,double divisor) noexcept {
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto denominator=_mm_set1_pd(divisor);
    const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
    for(;count-i>=2;i+=2) {
        const auto result=_mm_div_pd(_mm_loadu_pd(values+i),denominator);
        valid=_mm_and_pd(valid,_mm_cmple_pd(_mm_andnot_pd(sign,result),limit));
        _mm_storeu_pd(values+i,result);
    }
    if(_mm_movemask_pd(valid)!=3)return false;
#endif
    for(;i<count;++i) {
        const double result=values[i]/divisor;
        if(!llt_is_finite(result))return false;
        values[i]=result;
    }
    return true;
}

inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input, MatrixView<double> storage) noexcept {
    // Input is fully validated and independent of storage. Compute through a
    // transposed view so panel columns are contiguous without heap/workspace.
    const auto n=input.rows();
    auto working=storage.transpose();
    if (n<=64) {
        for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) working(i,j)=input(i,j);
    } else {
        for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);
    }
    if (n<=64) {
        // Small matrices remain in cache. Apply all preceding columns once
        // per new column instead of repeatedly reading/writing trailing tiles.
        for (std::size_t k=0;k<n;++k) {
            double diagonal=working(k,k);
            for (std::size_t j=0;j<k;++j) diagonal-=working(k,j)*working(k,j);
            if (!llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
            if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
            working(k,k)=std::sqrt(diagonal);
            if (k+1<n) {
                auto* coefficients=&working(0,n-1); // unused upper entries
                for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);
                row_update_panel(&working(k+1,k),&working(k+1,0),working.col_stride(),coefficients,k,n-k-1);
                for (std::size_t i=k+1;i<n;++i) {
                    const auto value=working(i,k)/working(k,k);
                    if (!llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};
                    working(i,k)=value;
                }
            }
        }
    } else {
        for (std::size_t first=0;first<n;) {
            const auto end=first+std::min(std::size_t{8},n-first);
            for (std::size_t k=first;k<end;++k) {
                const double diagonal=working(k,k);
                if (!detail::llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
                if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
                working(k,k)=std::sqrt(diagonal);
                if(end>k+1 && !divide_contiguous_checked(&working(k+1,k),end-(k+1),working(k,k)))
                    return Status{StatusCode::arithmetic_failure,k};
                for (std::size_t j=k+1;j<end;++j)
                    row_update(&working(j,j),&working(j,k),end-j,working(j,k));
            }
            if (end<n) for (std::size_t k=first;k<end;++k) {
                if(n>end && !divide_contiguous_checked(&working(end,k),n-(end),working(k,k)))
                    return Status{StatusCode::arithmetic_failure,k};
                for (std::size_t j=k+1;j<end;++j)
                    row_update(&working(end,j),&working(end,k),n-end,working(j,k));
            }
            if (end<n) {
                std::size_t j=end;
                for (;n-j>=2;j+=2) {
                    for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);
                    update_column_pair(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                       working.col_stride(),&working(j,first),end-first,n-j-1);
                }
                if (j<n) for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);
            }
            first=end;
        }
    }
    // Restore the caller's lower triangle and clear every logical upper entry.
    if (n<=64) {
        for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {
            storage(i,j)=storage(j,i);storage(j,i)=0;
        }
    } else {
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
    if (options.check_symmetry && input.col_stride()==1) {
        // The whole input, including the unused triangle, is still validated
        // before storage is touched. Combine the finite and scale scans.
        if (input.row_stride()==n && n>=8) {
            // Checked dense layout guarantees that n*n is representable.
            if (!detail::finite_max_abs(&input(0,0),n*n,scale)) return StatusCode::non_finite_input;
        } else {
            for (std::size_t i=0;i<n;++i)
                if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;
        }
    } else {
        for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)
            if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;
        if (options.check_symmetry) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<n;++j) if (std::abs(input(i,j))>scale) scale=std::abs(input(i,j));
        }
    }
    if (options.check_symmetry) {
        const bool tiled=detail::row_simd_available && input.col_stride()==1 && n>=8;
        if (scale!=0 && !(tiled && detail::symmetric_rows_within_tolerance(input,scale,options.symmetry_tolerance))) {
            for (std::size_t i=0;i<n;++i)
                for (std::size_t j=0;j<i;++j)
                    if (input(i,j)!=input(j,i) &&
                        std::abs(input(i,j)/scale-input(j,i)/scale)>options.symmetry_tolerance)
                        return Status{StatusCode::invalid_argument,i};
        }
    }
    if constexpr (detail::row_simd_available) {
        if (storage.col_stride()==1 && n>=9)
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
    if (detail::row_simd_available && lower.col_stride()==1 && n>=9) {
        for (std::size_t i=n;i-->0;) {
            const auto value=candidate[i]/lower(i,i);
            if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
            if (i>0) detail::row_update(candidate.data(),&lower(i,0),i,value);
        }
    } else {
        for (std::size_t i=n;i-->0;) {
            double value=candidate[i];
            for (std::size_t j=i+1;j<n;++j) value-=lower(j,i)*candidate[j];
            value/=lower(i,i);
            if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
        }
    }
    for (std::size_t i=0;i<n;++i) output[i]=candidate[i];
    return {};
}
} // namespace kibo::linalg
