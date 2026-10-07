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

#if defined(_MSC_VER)
__forceinline
#else
inline
#endif
// Reuse each panel packet across two output columns. Each element keeps the
// original increasing-k subtraction order; only the load/store grouping changes.
void update_column_pair(double* first, double* second, const double* panel,
                               std::size_t stride, const double* coefficients,
                               std::size_t width, std::size_t count) noexcept {
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
    for (;i<count;++i) {
        double a=first[i],b=second[i];
        for (std::size_t k=0;k<width;++k) {
            a-=coefficients[k*stride]*panel[k*stride+i];
            b-=coefficients[k*stride+1]*panel[k*stride+i];
        }
        first[i]=a;second[i]=b;
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


inline Status llt_forward_shared(MatrixView<const double> lower,std::span<const double> rhs,
                                 std::span<double> candidate) noexcept {
    const auto n=lower.rows();std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    // Four independent rows share candidate loads. Fold the two packet sums
    // before solving the local lower 4x4 block in the normal row order.
    for(;n-i>=4;i+=4) {
        auto s0_0=_mm_setzero_pd();
        auto s0_1=_mm_setzero_pd();
        auto s1_0=_mm_setzero_pd();
        auto s1_1=_mm_setzero_pd();
        auto s2_0=_mm_setzero_pd();
        auto s2_1=_mm_setzero_pd();
        auto s3_0=_mm_setzero_pd();
        auto s3_1=_mm_setzero_pd();
        std::size_t j=0;
        for(;i-j>=4;j+=4) {
            const auto x0=_mm_loadu_pd(candidate.data()+j+0);
            s0_0=_mm_add_pd(s0_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+0,j+0)),x0));
            s1_0=_mm_add_pd(s1_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+1,j+0)),x0));
            s2_0=_mm_add_pd(s2_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+2,j+0)),x0));
            s3_0=_mm_add_pd(s3_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+3,j+0)),x0));
            const auto x1=_mm_loadu_pd(candidate.data()+j+2);
            s0_1=_mm_add_pd(s0_1,_mm_mul_pd(_mm_loadu_pd(&lower(i+0,j+2)),x1));
            s1_1=_mm_add_pd(s1_1,_mm_mul_pd(_mm_loadu_pd(&lower(i+1,j+2)),x1));
            s2_1=_mm_add_pd(s2_1,_mm_mul_pd(_mm_loadu_pd(&lower(i+2,j+2)),x1));
            s3_1=_mm_add_pd(s3_1,_mm_mul_pd(_mm_loadu_pd(&lower(i+3,j+2)),x1));
        }
        for(;i-j>=2;j+=2) {
            const auto x=_mm_loadu_pd(candidate.data()+j);
            s0_0=_mm_add_pd(s0_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+0,j)),x));
            s1_0=_mm_add_pd(s1_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+1,j)),x));
            s2_0=_mm_add_pd(s2_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+2,j)),x));
            s3_0=_mm_add_pd(s3_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+3,j)),x));
        }
        const auto sum0=_mm_add_pd(s0_0,s0_1);
        double v0=rhs[i+0]-(_mm_cvtsd_f64(sum0)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum0,sum0)));
        if(j<i)v0-=lower(i+0,j)*candidate[j];
        v0/=lower(i+0,i+0);
        if(!llt_is_finite(v0))return {StatusCode::arithmetic_failure,i+0};
        candidate[i+0]=v0;
        const auto sum1=_mm_add_pd(s1_0,s1_1);
        double v1=rhs[i+1]-(_mm_cvtsd_f64(sum1)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum1,sum1)));
        if(j<i)v1-=lower(i+1,j)*candidate[j];
        v1-=lower(i+1,i+0)*candidate[i+0];
        v1/=lower(i+1,i+1);
        if(!llt_is_finite(v1))return {StatusCode::arithmetic_failure,i+1};
        candidate[i+1]=v1;
        const auto sum2=_mm_add_pd(s2_0,s2_1);
        double v2=rhs[i+2]-(_mm_cvtsd_f64(sum2)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum2,sum2)));
        if(j<i)v2-=lower(i+2,j)*candidate[j];
        v2-=lower(i+2,i+0)*candidate[i+0];
        v2-=lower(i+2,i+1)*candidate[i+1];
        v2/=lower(i+2,i+2);
        if(!llt_is_finite(v2))return {StatusCode::arithmetic_failure,i+2};
        candidate[i+2]=v2;
        const auto sum3=_mm_add_pd(s3_0,s3_1);
        double v3=rhs[i+3]-(_mm_cvtsd_f64(sum3)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum3,sum3)));
        if(j<i)v3-=lower(i+3,j)*candidate[j];
        v3-=lower(i+3,i+0)*candidate[i+0];
        v3-=lower(i+3,i+1)*candidate[i+1];
        v3-=lower(i+3,i+2)*candidate[i+2];
        v3/=lower(i+3,i+3);
        if(!llt_is_finite(v3))return {StatusCode::arithmetic_failure,i+3};
        candidate[i+3]=v3;
    }
#endif
    for(;i<n;++i) {
        double value=rhs[i];
        for(std::size_t j=0;j<i;++j)value-=lower(i,j)*candidate[j];
        value/=lower(i,i);
        if(!llt_is_finite(value))return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    return {};
}


inline void row_update_two_ordered(double* values,const double* a,const double* b,std::size_t count,
                                   double first,double second) noexcept {
    std::size_t j=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto x=_mm_set1_pd(first),y=_mm_set1_pd(second);
    for(;count-j>=4;j+=4) {
        auto p=_mm_loadu_pd(values+j),q=_mm_loadu_pd(values+j+2);
        p=_mm_sub_pd(p,_mm_mul_pd(x,_mm_loadu_pd(a+j)));
        q=_mm_sub_pd(q,_mm_mul_pd(x,_mm_loadu_pd(a+j+2)));
        p=_mm_sub_pd(p,_mm_mul_pd(y,_mm_loadu_pd(b+j)));
        q=_mm_sub_pd(q,_mm_mul_pd(y,_mm_loadu_pd(b+j+2)));
        _mm_storeu_pd(values+j,p);_mm_storeu_pd(values+j+2,q);
    }
    for(;count-j>=2;j+=2) {
        auto p=_mm_loadu_pd(values+j);
        p=_mm_sub_pd(p,_mm_mul_pd(x,_mm_loadu_pd(a+j)));
        p=_mm_sub_pd(p,_mm_mul_pd(y,_mm_loadu_pd(b+j)));
        _mm_storeu_pd(values+j,p);
    }
#endif
    for(;j<count;++j){values[j]-=a[j]*first;values[j]-=b[j]*second;}
}


// Row-contiguous square input only. Equal opposing entries let one pass
// validate the range and symmetry; unequal entries retain the full finite
// scan and the caller's original normalized-tolerance check.
inline bool finite_max_and_exact_symmetry(MatrixView<const double> input,double& scale,bool& exact) noexcept {
    const auto n=input.rows();std::size_t i=0;
    exact=true;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto max0=_mm_setzero_pd(),max1=max0;
    auto valid0=_mm_cmpeq_pd(max0,max0),valid1=valid0,equal=valid0;
    for(;n-i>=2;i+=2) {
        const auto da=_mm_andnot_pd(sign,_mm_loadu_pd(&input(i,i)));
        const auto db=_mm_andnot_pd(sign,_mm_loadu_pd(&input(i+1,i)));
        max0=_mm_max_pd(max0,da);valid0=_mm_and_pd(valid0,_mm_cmple_pd(da,limit));
        max1=_mm_max_pd(max1,db);valid1=_mm_and_pd(valid1,_mm_cmple_pd(db,limit));
        exact&=input(i,i+1)==input(i+1,i);
        for(std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&input(i,j)),b=_mm_loadu_pd(&input(i+1,j));
            const auto c=_mm_loadu_pd(&input(j,i)),d=_mm_loadu_pd(&input(j+1,i));
            equal=_mm_and_pd(equal,_mm_and_pd(_mm_cmpeq_pd(a,_mm_unpacklo_pd(c,d)),_mm_cmpeq_pd(b,_mm_unpackhi_pd(c,d))));
            const auto aa=_mm_andnot_pd(sign,a),ab=_mm_andnot_pd(sign,b);
            // Equal opposing entries have equal absolute values. Off-diagonal
            // NaNs make the equality mask false and trigger the full finite scan.
            max0=_mm_max_pd(max0,aa);
            max1=_mm_max_pd(max1,ab);
        }
    }
    if(_mm_movemask_pd(_mm_and_pd(valid0,valid1))!=3)return false;
    const auto maximum=_mm_max_pd(max0,max1);
    scale=std::max(_mm_cvtsd_f64(maximum),_mm_cvtsd_f64(_mm_unpackhi_pd(maximum,maximum)));
    exact&=_mm_movemask_pd(equal)==3;
    if(exact) {
        if(!(scale<=std::numeric_limits<double>::max()))return false;
    } else {
        scale=0;
        for(std::size_t row=0;row<n;++row)
            if(!finite_max_abs(&input(row,0),n,scale))return false;
    }
#endif
    for(;i<n;++i) {
        if(!llt_is_finite(input(i,i)))return false;
        scale=std::max(scale,std::abs(input(i,i)));
        for(std::size_t j=0;j<i;++j) {
            const double a=input(i,j),b=input(j,i);
            if(!llt_is_finite(a)||!llt_is_finite(b))return false;
            scale=std::max(scale,std::max(std::abs(a),std::abs(b)));
            exact&=a==b;
        }
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
    double scale=0;bool exact=false;
    if(options.check_symmetry && detail::row_simd_available && input.col_stride()==1 && n>=128) {
        if(!detail::finite_max_and_exact_symmetry(input,scale,exact))return StatusCode::non_finite_input;
    } else {
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
    }
    if (options.check_symmetry && !exact) {
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
    if(detail::row_simd_available && n>=128 && lower.col_stride()==1) {
        auto status=detail::llt_forward_shared(lower,rhs,candidate);
        if(!status)return status;
    } else {
        for (std::size_t i=0;i<n;++i) {
            double value=rhs[i];
            for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];
            value/=lower(i,i);
            if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
        }
    }
    if(detail::row_simd_available && lower.col_stride()==1 && n>=128) {
        std::size_t i=n;
        for(;i>=2;i-=2) {
            const auto first=i-1,second=i-2;
            const double a=candidate[first]/lower(first,first);
            if(!detail::llt_is_finite(a))return {StatusCode::arithmetic_failure,first};
            candidate[first]=a;
            const double b=(candidate[second]-lower(first,second)*a)/lower(second,second);
            if(!detail::llt_is_finite(b))return {StatusCode::arithmetic_failure,second};
            candidate[second]=b;
            detail::row_update_two_ordered(candidate.data(),&lower(first,0),&lower(second,0),second,a,b);
        }
        if(i!=0) {
            const double value=candidate[0]/lower(0,0);
            if(!detail::llt_is_finite(value))return {StatusCode::arithmetic_failure,0};
            candidate[0]=value;
        }
    } else if (detail::row_simd_available && lower.col_stride()==1 && n>=9) {
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
