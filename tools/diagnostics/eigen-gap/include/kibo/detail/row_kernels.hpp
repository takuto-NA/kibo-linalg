// DIAGNOSTIC SNAPSHOT ONLY: not an installed library header.
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
#if defined(KIBO_DIAG_LLT_WIDE)
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
#endif
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
#if defined(KIBO_DIAG_ALL_UPDATE_NOCHECK)
    row_update(row,projection,count,value);return true;
#else
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
#endif

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
#if defined(KIBO_DIAG_DOT_WIDE)
    auto p0=_mm_setzero_pd();
    auto p1=_mm_setzero_pd();
    auto p2=_mm_setzero_pd();
    auto p3=_mm_setzero_pd();
    auto p4=_mm_setzero_pd();
    auto p5=_mm_setzero_pd();
    auto p6=_mm_setzero_pd();
    auto p7=_mm_setzero_pd();
    for(;count-i>=16;i+=16) {
        p0=_mm_add_pd(p0,_mm_mul_pd(_mm_loadu_pd(left+i+0),_mm_loadu_pd(right+i+0)));
        p1=_mm_add_pd(p1,_mm_mul_pd(_mm_loadu_pd(left+i+2),_mm_loadu_pd(right+i+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(_mm_loadu_pd(left+i+4),_mm_loadu_pd(right+i+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(_mm_loadu_pd(left+i+6),_mm_loadu_pd(right+i+6)));
        p4=_mm_add_pd(p4,_mm_mul_pd(_mm_loadu_pd(left+i+8),_mm_loadu_pd(right+i+8)));
        p5=_mm_add_pd(p5,_mm_mul_pd(_mm_loadu_pd(left+i+10),_mm_loadu_pd(right+i+10)));
        p6=_mm_add_pd(p6,_mm_mul_pd(_mm_loadu_pd(left+i+12),_mm_loadu_pd(right+i+12)));
        p7=_mm_add_pd(p7,_mm_mul_pd(_mm_loadu_pd(left+i+14),_mm_loadu_pd(right+i+14)));
    }
    const auto wide=_mm_add_pd(_mm_add_pd(_mm_add_pd(p0,p1),_mm_add_pd(p2,p3)),_mm_add_pd(_mm_add_pd(p4,p5),_mm_add_pd(p6,p7)));
    initial+=_mm_cvtsd_f64(wide)+_mm_cvtsd_f64(_mm_unpackhi_pd(wide,wide));
#endif
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
inline void row_update_two_rows_panel(double* rows,const double* panel,std::size_t stride,
    const double* coefficients,std::size_t width,std::size_t count) noexcept {
    std::size_t j=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    for(;count-j>=8;j+=8) {
        auto p00=_mm_loadu_pd(rows+0*stride+j+0);
        auto p01=_mm_loadu_pd(rows+0*stride+j+2);
        auto p02=_mm_loadu_pd(rows+0*stride+j+4);
        auto p03=_mm_loadu_pd(rows+0*stride+j+6);
        auto p10=_mm_loadu_pd(rows+1*stride+j+0);
        auto p11=_mm_loadu_pd(rows+1*stride+j+2);
        auto p12=_mm_loadu_pd(rows+1*stride+j+4);
        auto p13=_mm_loadu_pd(rows+1*stride+j+6);
        for(std::size_t k=0;k<width;++k) {
            const auto a=_mm_set1_pd(coefficients[k]);
            const auto b=_mm_set1_pd(coefficients[stride+k]);
            const auto v0=_mm_loadu_pd(panel+k*stride+j+0);
            p00=_mm_sub_pd(p00,_mm_mul_pd(a,v0));
            p10=_mm_sub_pd(p10,_mm_mul_pd(b,v0));
            const auto v1=_mm_loadu_pd(panel+k*stride+j+2);
            p01=_mm_sub_pd(p01,_mm_mul_pd(a,v1));
            p11=_mm_sub_pd(p11,_mm_mul_pd(b,v1));
            const auto v2=_mm_loadu_pd(panel+k*stride+j+4);
            p02=_mm_sub_pd(p02,_mm_mul_pd(a,v2));
            p12=_mm_sub_pd(p12,_mm_mul_pd(b,v2));
            const auto v3=_mm_loadu_pd(panel+k*stride+j+6);
            p03=_mm_sub_pd(p03,_mm_mul_pd(a,v3));
            p13=_mm_sub_pd(p13,_mm_mul_pd(b,v3));
        }
        _mm_storeu_pd(rows+0*stride+j+0,p00);
        _mm_storeu_pd(rows+0*stride+j+2,p01);
        _mm_storeu_pd(rows+0*stride+j+4,p02);
        _mm_storeu_pd(rows+0*stride+j+6,p03);
        _mm_storeu_pd(rows+1*stride+j+0,p10);
        _mm_storeu_pd(rows+1*stride+j+2,p11);
        _mm_storeu_pd(rows+1*stride+j+4,p12);
        _mm_storeu_pd(rows+1*stride+j+6,p13);
    }
#endif
    for(;j<count;++j) for(std::size_t k=0;k<width;++k) { rows[j]-=coefficients[k]*panel[k*stride+j];rows[stride+j]-=coefficients[stride+k]*panel[k*stride+j]; }
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
