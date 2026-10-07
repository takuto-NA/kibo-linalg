#pragma once
#include <kibo/linalg.hpp>
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && \
    (defined(__SSE2__) || defined(_M_X64) || (defined(_M_IX86_FP) && _M_IX86_FP >= 2))
#include <emmintrin.h>
#define KIBO_DETAIL_ROW_SSE2 1
#endif

namespace kibo::linalg::detail {
#if defined(KIBO_DETAIL_ROW_SSE2)
inline constexpr bool row_simd_available=true;
#else
inline constexpr bool row_simd_available=false;
#endif
// Contiguous rows only. The caller guarantees non-overlapping regions;
// unaligned packets impose no alignment requirement beyond double's ABI.
inline bool finite_max_abs(const double* values, std::size_t count, double& maximum) noexcept {
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto sign=_mm_set1_pd(-0.0);
    const auto limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto largest0=_mm_set1_pd(maximum);
    auto valid0=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
    if (count>=8) {
        auto largest1=_mm_set1_pd(maximum);
        auto valid1=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
        auto largest2=_mm_set1_pd(maximum);
        auto valid2=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
        auto largest3=_mm_set1_pd(maximum);
        auto valid3=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
        for (;count-i>=8;i+=8) {
            const auto absolute0=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+0));
            valid0=_mm_and_pd(valid0,_mm_cmple_pd(absolute0,limit));
            largest0=_mm_max_pd(largest0,absolute0);
            const auto absolute1=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+2));
            valid1=_mm_and_pd(valid1,_mm_cmple_pd(absolute1,limit));
            largest1=_mm_max_pd(largest1,absolute1);
            const auto absolute2=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+4));
            valid2=_mm_and_pd(valid2,_mm_cmple_pd(absolute2,limit));
            largest2=_mm_max_pd(largest2,absolute2);
            const auto absolute3=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+6));
            valid3=_mm_and_pd(valid3,_mm_cmple_pd(absolute3,limit));
            largest3=_mm_max_pd(largest3,absolute3);
        }
        valid0=_mm_and_pd(valid0,valid1);
        largest0=_mm_max_pd(largest0,largest1);
        valid0=_mm_and_pd(valid0,valid2);
        largest0=_mm_max_pd(largest0,largest2);
        valid0=_mm_and_pd(valid0,valid3);
        largest0=_mm_max_pd(largest0,largest3);
    }
    for (;count-i>=2;i+=2) {
        const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));
        valid0=_mm_and_pd(valid0,_mm_cmple_pd(absolute,limit));
        largest0=_mm_max_pd(largest0,absolute);
    }
    if (_mm_movemask_pd(valid0)!=3) return false;
    maximum=std::max(_mm_cvtsd_f64(largest0),_mm_cvtsd_f64(_mm_unpackhi_pd(largest0,largest0)));
#endif
    for (;i<count;++i) {
        if (!(std::abs(values[i])<=std::numeric_limits<double>::max())) return false;
        maximum=std::max(maximum,std::abs(values[i]));
    }
    return true;
}
// Row-contiguous square input has already passed finite validation. A false
// result is rechecked in scalar row order to preserve the failing index.
inline bool symmetric_rows_within_tolerance(MatrixView<const double> input, double scale, double tolerance) noexcept {
    const auto n=input.rows();
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto divisor=_mm_set1_pd(scale), limit=_mm_set1_pd(tolerance), sign=_mm_set1_pd(-0.0);
    for (;n-i>=2;i+=2) {
        for (std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&input(i,j)), b=_mm_loadu_pd(&input(i+1,j));
            const auto c=_mm_loadu_pd(&input(j,i)), d=_mm_loadu_pd(&input(j+1,i));
            const auto equal=_mm_and_pd(_mm_cmpeq_pd(a,_mm_unpacklo_pd(c,d)),_mm_cmpeq_pd(b,_mm_unpackhi_pd(c,d)));
            if (_mm_movemask_pd(equal)!=3) {
                const auto da=_mm_sub_pd(_mm_div_pd(a,divisor),_mm_div_pd(_mm_unpacklo_pd(c,d),divisor));
                const auto db=_mm_sub_pd(_mm_div_pd(b,divisor),_mm_div_pd(_mm_unpackhi_pd(c,d),divisor));
                const auto near=_mm_and_pd(_mm_cmple_pd(_mm_andnot_pd(sign,da),limit),_mm_cmple_pd(_mm_andnot_pd(sign,db),limit));
                if (_mm_movemask_pd(near)!=3) return false;
            }
        }
        if (input(i+1,i)!=input(i,i+1) && std::abs(input(i+1,i)/scale-input(i,i+1)/scale)>tolerance) return false;
    }
#endif
    for (;i<n;++i) for (std::size_t j=0;j<i;++j) if (input(i,j)!=input(j,i) && std::abs(input(i,j)/scale-input(j,i)/scale)>tolerance) return false;
    return true;
}
inline void row_update(double* row, const double* projection, std::size_t count, double value) noexcept {
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto multiplier=_mm_set1_pd(value);
    for (;count-j>=4;j+=4) {
        _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));
        _mm_storeu_pd(row+j+2,_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2))));
    }
    for (;count-j>=2;j+=2)
        _mm_storeu_pd(row+j,_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j))));
#endif
    for (;j<count;++j) row[j]-=value*projection[j];
}
inline void row_project(double* projection, const double* row, std::size_t count, double value) noexcept {
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto multiplier=_mm_set1_pd(value);
    for (;count-j>=4;j+=4) {
        _mm_storeu_pd(projection+j,_mm_add_pd(_mm_loadu_pd(projection+j),_mm_mul_pd(multiplier,_mm_loadu_pd(row+j))));
        _mm_storeu_pd(projection+j+2,_mm_add_pd(_mm_loadu_pd(projection+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(row+j+2))));
    }
    for (;count-j>=2;j+=2)
        _mm_storeu_pd(projection+j,_mm_add_pd(_mm_loadu_pd(projection+j),_mm_mul_pd(multiplier,_mm_loadu_pd(row+j))));
#endif
    for (;j<count;++j) projection[j]+=value*row[j];
}
inline void row_update_panel(double* row, const double* panel, std::size_t stride,
                             const double* coefficients, std::size_t width, std::size_t count) noexcept {
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    for(;count-j>=16;j+=16) {
        auto p0=_mm_loadu_pd(row+j+0);
        auto p1=_mm_loadu_pd(row+j+2);
        auto p2=_mm_loadu_pd(row+j+4);
        auto p3=_mm_loadu_pd(row+j+6);
        auto p4=_mm_loadu_pd(row+j+8);
        auto p5=_mm_loadu_pd(row+j+10);
        auto p6=_mm_loadu_pd(row+j+12);
        auto p7=_mm_loadu_pd(row+j+14);
        for(std::size_t k=0;k<width;++k) {
            const auto multiplier=_mm_set1_pd(coefficients[k]);
            p0=_mm_sub_pd(p0,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+0)));
            p1=_mm_sub_pd(p1,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));
            p2=_mm_sub_pd(p2,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+4)));
            p3=_mm_sub_pd(p3,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+6)));
            p4=_mm_sub_pd(p4,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+8)));
            p5=_mm_sub_pd(p5,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+10)));
            p6=_mm_sub_pd(p6,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+12)));
            p7=_mm_sub_pd(p7,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+14)));
        }
        _mm_storeu_pd(row+j+0,p0);
        _mm_storeu_pd(row+j+2,p1);
        _mm_storeu_pd(row+j+4,p2);
        _mm_storeu_pd(row+j+6,p3);
        _mm_storeu_pd(row+j+8,p4);
        _mm_storeu_pd(row+j+10,p5);
        _mm_storeu_pd(row+j+12,p6);
        _mm_storeu_pd(row+j+14,p7);
    }
    for (;count-j>=8;j+=8) {
        auto first=_mm_loadu_pd(row+j);
        auto second=_mm_loadu_pd(row+j+2);
        auto third=_mm_loadu_pd(row+j+4);
        auto fourth=_mm_loadu_pd(row+j+6);
        for (std::size_t k=0;k<width;++k) {
            const auto multiplier=_mm_set1_pd(coefficients[k]);
            first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));
            second=_mm_sub_pd(second,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));
            third=_mm_sub_pd(third,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+4)));
            fourth=_mm_sub_pd(fourth,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+6)));
        }
        _mm_storeu_pd(row+j,first);
        _mm_storeu_pd(row+j+2,second);
        _mm_storeu_pd(row+j+4,third);
        _mm_storeu_pd(row+j+6,fourth);
    }
    for (;count-j>=4;j+=4) {
        auto first=_mm_loadu_pd(row+j);
        auto second=_mm_loadu_pd(row+j+2);
        for (std::size_t k=0;k<width;++k) {
            const auto multiplier=_mm_set1_pd(coefficients[k]);
            first=_mm_sub_pd(first,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j)));
            second=_mm_sub_pd(second,_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+2)));
        }
        _mm_storeu_pd(row+j,first);
        _mm_storeu_pd(row+j+2,second);
    }
    for (;count-j>=2;j+=2) {
        auto updated=_mm_loadu_pd(row+j);
        for (std::size_t k=0;k<width;++k)
            updated=_mm_sub_pd(updated,_mm_mul_pd(_mm_set1_pd(coefficients[k]),_mm_loadu_pd(panel+k*stride+j)));
        _mm_storeu_pd(row+j,updated);
    }
#endif
    for (;j<count;++j) for (std::size_t k=0;k<width;++k) row[j]-=coefficients[k]*panel[k*stride+j];
}
inline bool row_update_checked(double* row, const double* projection, std::size_t count, double value) noexcept {
    bool finite=true;
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto multiplier=_mm_set1_pd(value);
    const auto sign=_mm_set1_pd(-0.0);
    const auto maximum=_mm_set1_pd(std::numeric_limits<double>::max());
    auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
    auto second_valid=valid;
    for (;count-j>=4;j+=4) {
        const auto first=_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j)));
        const auto second=_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2)));
        _mm_storeu_pd(row+j,first);
        _mm_storeu_pd(row+j+2,second);
        valid=_mm_and_pd(valid,_mm_cmple_pd(_mm_andnot_pd(sign,first),maximum));
        second_valid=_mm_and_pd(second_valid,_mm_cmple_pd(_mm_andnot_pd(sign,second),maximum));
    }
    for (;count-j>=2;j+=2) {
        const auto updated=_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j)));
        _mm_storeu_pd(row+j,updated);
        valid=_mm_and_pd(valid,_mm_cmple_pd(_mm_andnot_pd(sign,updated),maximum));
    }
    finite=_mm_movemask_pd(_mm_and_pd(valid,second_valid))==3;
#endif
    for (;j<count;++j) {
        row[j]-=value*projection[j];
        finite&=std::isfinite(row[j]);
    }
    return finite;
}

inline void row_project_four_rows(double* projection,const double* rows,std::size_t stride,
                                  const double* coefficients,std::size_t count) noexcept {
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto a=_mm_set1_pd(coefficients[0]);
    const auto b=_mm_set1_pd(coefficients[stride]);
    const auto c=_mm_set1_pd(coefficients[2*stride]);
    const auto d=_mm_set1_pd(coefficients[3*stride]);
    for(;count-j>=16;j+=16) {
        auto p0=_mm_loadu_pd(projection+j+0);
        auto p1=_mm_loadu_pd(projection+j+2);
        auto p2=_mm_loadu_pd(projection+j+4);
        auto p3=_mm_loadu_pd(projection+j+6);
        auto p4=_mm_loadu_pd(projection+j+8);
        auto p5=_mm_loadu_pd(projection+j+10);
        auto p6=_mm_loadu_pd(projection+j+12);
        auto p7=_mm_loadu_pd(projection+j+14);
        p0=_mm_add_pd(p0,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+0)));
        p1=_mm_add_pd(p1,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+6)));
        p4=_mm_add_pd(p4,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+8)));
        p5=_mm_add_pd(p5,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+10)));
        p6=_mm_add_pd(p6,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+12)));
        p7=_mm_add_pd(p7,_mm_mul_pd(a,_mm_loadu_pd(rows+0*stride+j+14)));
        p0=_mm_add_pd(p0,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+0)));
        p1=_mm_add_pd(p1,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+6)));
        p4=_mm_add_pd(p4,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+8)));
        p5=_mm_add_pd(p5,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+10)));
        p6=_mm_add_pd(p6,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+12)));
        p7=_mm_add_pd(p7,_mm_mul_pd(b,_mm_loadu_pd(rows+1*stride+j+14)));
        p0=_mm_add_pd(p0,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+0)));
        p1=_mm_add_pd(p1,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+6)));
        p4=_mm_add_pd(p4,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+8)));
        p5=_mm_add_pd(p5,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+10)));
        p6=_mm_add_pd(p6,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+12)));
        p7=_mm_add_pd(p7,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+14)));
        p0=_mm_add_pd(p0,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+0)));
        p1=_mm_add_pd(p1,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+6)));
        p4=_mm_add_pd(p4,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+8)));
        p5=_mm_add_pd(p5,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+10)));
        p6=_mm_add_pd(p6,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+12)));
        p7=_mm_add_pd(p7,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+14)));
        _mm_storeu_pd(projection+j+0,p0);
        _mm_storeu_pd(projection+j+2,p1);
        _mm_storeu_pd(projection+j+4,p2);
        _mm_storeu_pd(projection+j+6,p3);
        _mm_storeu_pd(projection+j+8,p4);
        _mm_storeu_pd(projection+j+10,p5);
        _mm_storeu_pd(projection+j+12,p6);
        _mm_storeu_pd(projection+j+14,p7);
    }
    for(;count-j>=4;j+=4) {
        auto p=_mm_loadu_pd(projection+j),q=_mm_loadu_pd(projection+j+2);
        p=_mm_add_pd(p,_mm_mul_pd(a,_mm_loadu_pd(rows+j)));
        q=_mm_add_pd(q,_mm_mul_pd(a,_mm_loadu_pd(rows+j+2)));
        p=_mm_add_pd(p,_mm_mul_pd(b,_mm_loadu_pd(rows+stride+j)));
        q=_mm_add_pd(q,_mm_mul_pd(b,_mm_loadu_pd(rows+stride+j+2)));
        p=_mm_add_pd(p,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j)));
        q=_mm_add_pd(q,_mm_mul_pd(c,_mm_loadu_pd(rows+2*stride+j+2)));
        p=_mm_add_pd(p,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j)));
        q=_mm_add_pd(q,_mm_mul_pd(d,_mm_loadu_pd(rows+3*stride+j+2)));
        _mm_storeu_pd(projection+j,p);_mm_storeu_pd(projection+j+2,q);
    }
#endif
    for(;j<count;++j) for(std::size_t i=0;i<4;++i) projection[j]+=coefficients[i*stride]*rows[i*stride+j];
}
inline double contiguous_dot(const double* left,const double* right,std::size_t count,double initial) noexcept {
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    auto first=_mm_setzero_pd(),second=first;
    for(;count-i>=4;i+=4) {
        first=_mm_add_pd(first,_mm_mul_pd(_mm_loadu_pd(left+i),_mm_loadu_pd(right+i)));
        second=_mm_add_pd(second,_mm_mul_pd(_mm_loadu_pd(left+i+2),_mm_loadu_pd(right+i+2)));
    }
    const auto total=_mm_add_pd(first,second);
    initial+=_mm_cvtsd_f64(total)+_mm_cvtsd_f64(_mm_unpackhi_pd(total,total));
#endif
    for(;i<count;++i) initial+=left[i]*right[i];
    return initial;
}
// Four columns share each Householder packet. All updated values are checked
// before the caller advances to the next pivot, including residual rows.
inline bool column_update_four_checked(double* columns, std::size_t stride, const double* values,
                                       std::size_t count, const double* coefficients) noexcept {
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    const auto a=_mm_set1_pd(coefficients[0]),b=_mm_set1_pd(coefficients[1]);
    const auto c=_mm_set1_pd(coefficients[2]),d=_mm_set1_pd(coefficients[3]);
    const auto sign=_mm_set1_pd(-0.0),maximum=_mm_set1_pd(std::numeric_limits<double>::max());
    auto va=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd()),vb=va,vc=va,vd=va;
    for (;count-i>=2;i+=2) {
        const auto v=_mm_loadu_pd(values+i);
        const auto x0=_mm_sub_pd(_mm_loadu_pd(columns+i),_mm_mul_pd(a,v));
        const auto x1=_mm_sub_pd(_mm_loadu_pd(columns+stride+i),_mm_mul_pd(b,v));
        const auto x2=_mm_sub_pd(_mm_loadu_pd(columns+2*stride+i),_mm_mul_pd(c,v));
        const auto x3=_mm_sub_pd(_mm_loadu_pd(columns+3*stride+i),_mm_mul_pd(d,v));
        _mm_storeu_pd(columns+i,x0);_mm_storeu_pd(columns+stride+i,x1);
        _mm_storeu_pd(columns+2*stride+i,x2);_mm_storeu_pd(columns+3*stride+i,x3);
        va=_mm_and_pd(va,_mm_cmple_pd(_mm_andnot_pd(sign,x0),maximum));
        vb=_mm_and_pd(vb,_mm_cmple_pd(_mm_andnot_pd(sign,x1),maximum));
        vc=_mm_and_pd(vc,_mm_cmple_pd(_mm_andnot_pd(sign,x2),maximum));
        vd=_mm_and_pd(vd,_mm_cmple_pd(_mm_andnot_pd(sign,x3),maximum));
    }
    if (_mm_movemask_pd(_mm_and_pd(_mm_and_pd(va,vb),_mm_and_pd(vc,vd)))!=3) return false;
#endif
    for (;i<count;++i) for (std::size_t j=0;j<4;++j) {
        columns[j*stride+i]-=coefficients[j]*values[i];
        if (!std::isfinite(columns[j*stride+i])) return false;
    }
    return true;
}
inline void column_project_four(double* projection,const double* columns,std::size_t stride,const double* values,std::size_t count) noexcept {
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    auto p00=_mm_setzero_pd();
    auto p01=_mm_setzero_pd();
    auto p10=_mm_setzero_pd();
    auto p11=_mm_setzero_pd();
    auto p20=_mm_setzero_pd();
    auto p21=_mm_setzero_pd();
    auto p30=_mm_setzero_pd();
    auto p31=_mm_setzero_pd();
    for(;count-i>=4;i+=4) {
        const auto v0=_mm_loadu_pd(values+i),v1=_mm_loadu_pd(values+i+2);
        p00=_mm_add_pd(p00,_mm_mul_pd(v0,_mm_loadu_pd(columns+0*stride+i+0)));
        p01=_mm_add_pd(p01,_mm_mul_pd(v1,_mm_loadu_pd(columns+0*stride+i+2)));
        p10=_mm_add_pd(p10,_mm_mul_pd(v0,_mm_loadu_pd(columns+1*stride+i+0)));
        p11=_mm_add_pd(p11,_mm_mul_pd(v1,_mm_loadu_pd(columns+1*stride+i+2)));
        p20=_mm_add_pd(p20,_mm_mul_pd(v0,_mm_loadu_pd(columns+2*stride+i+0)));
        p21=_mm_add_pd(p21,_mm_mul_pd(v1,_mm_loadu_pd(columns+2*stride+i+2)));
        p30=_mm_add_pd(p30,_mm_mul_pd(v0,_mm_loadu_pd(columns+3*stride+i+0)));
        p31=_mm_add_pd(p31,_mm_mul_pd(v1,_mm_loadu_pd(columns+3*stride+i+2)));
    }
    const auto sum0=_mm_add_pd(p00,p01);
    projection[0]+=_mm_cvtsd_f64(sum0)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum0,sum0));
    const auto sum1=_mm_add_pd(p10,p11);
    projection[1]+=_mm_cvtsd_f64(sum1)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum1,sum1));
    const auto sum2=_mm_add_pd(p20,p21);
    projection[2]+=_mm_cvtsd_f64(sum2)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum2,sum2));
    const auto sum3=_mm_add_pd(p30,p31);
    projection[3]+=_mm_cvtsd_f64(sum3)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum3,sum3));
#endif
    for(;i<count;++i) for(std::size_t j=0;j<4;++j) projection[j]+=values[i]*columns[j*stride+i];
}
} // namespace kibo::linalg::detail
#if defined(KIBO_DETAIL_ROW_SSE2)
#undef KIBO_DETAIL_ROW_SSE2
#endif
