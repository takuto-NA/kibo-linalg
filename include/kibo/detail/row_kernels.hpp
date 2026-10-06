#pragma once
#include <kibo/linalg.hpp>
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && \
    (defined(__SSE2__) || defined(_M_X64) || (defined(_M_IX86_FP) && _M_IX86_FP >= 2))
#include <emmintrin.h>
#define KIBO_DETAIL_ROW_SSE2 1
#endif

namespace kibo::linalg::detail {
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
} // namespace kibo::linalg::detail
#if defined(KIBO_DETAIL_ROW_SSE2)
#undef KIBO_DETAIL_ROW_SSE2
#endif
