#pragma once
#include <kibo/workspace.hpp>
#include <kibo/detail/row_kernels.hpp>
#include <algorithm>

namespace kibo::linalg::detail {
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
// Restart from the saved Q-transformed RHS. Regrouped dots or column updates
// can overflow even when these ascending-j subtractions stay finite.
inline Status qr_solve_upper_original(MatrixView<const double> packed,
                                      std::span<const double> transformed,
                                      std::span<double> candidate) noexcept {
    const auto n=packed.cols();
    for(std::size_t i=n;i-->0;) {
        double value=transformed[i];
        for(std::size_t j=i+1;j<n;++j)value-=packed(i,j)*candidate[j];
        value/=packed(i,i);
        if(!qr_is_finite(value))return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    return {};
}
inline Status qr_apply_reflectors_original(MatrixView<const double> packed,
                                           std::span<const double> tau,
                                           std::span<double> transformed) noexcept {
    const auto m=packed.rows(),n=packed.cols();
    for(std::size_t k=0;k<n;++k) {
        if(tau[k]==0)continue;
        double dot=transformed[k];
        if(packed.row_stride()==1 && m-k>1)
            dot=contiguous_dot(&packed(k+1,k),transformed.data()+k+1,m-k-1,dot);
        else for(std::size_t i=k+1;i<m;++i)dot+=packed(i,k)*transformed[i];
        const double multiplier=tau[k]*dot;
        if(!qr_is_finite(multiplier))return {StatusCode::arithmetic_failure,k};
        transformed[k]-=multiplier;
        if(!qr_is_finite(transformed[k]))return {StatusCode::arithmetic_failure,k};
        if(packed.row_stride()==1 && m-k>1) {
            if(!row_update_checked(transformed.data()+k+1,&packed(k+1,k),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        } else for(std::size_t i=k+1;i<m;++i) {
            transformed[i]-=packed(i,k)*multiplier;
            if(!qr_is_finite(transformed[i]))return {StatusCode::arithmetic_failure,k};
        }
    }
    return {};
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
// Convert q contiguous n-by-n column blocks to caller row order.
// The first n workspace doubles hold one block. The second n doubles provide
// q*n visited bits for q<=64. No input padding is used or modified.
// A two-by-two off-diagonal pair is exchanged and transposed using registers.
inline void qr_swap_transpose_pair(double* square,std::size_t n,std::size_t i,std::size_t j) noexcept {
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto a=_mm_loadu_pd(square+i*n+j),b=_mm_loadu_pd(square+(i+1)*n+j);
    const auto c=_mm_loadu_pd(square+j*n+i),d=_mm_loadu_pd(square+(j+1)*n+i);
    _mm_storeu_pd(square+i*n+j,_mm_unpacklo_pd(c,d));
    _mm_storeu_pd(square+(i+1)*n+j,_mm_unpackhi_pd(c,d));
    _mm_storeu_pd(square+j*n+i,_mm_unpacklo_pd(a,b));
    _mm_storeu_pd(square+(j+1)*n+i,_mm_unpackhi_pd(a,b));
#else
    std::swap(square[i*n+j],square[j*n+i]);
    std::swap(square[i*n+j+1],square[(j+1)*n+i]);
    std::swap(square[(i+1)*n+j],square[j*n+i+1]);
    std::swap(square[(i+1)*n+j+1],square[(j+1)*n+i+1]);
#endif
}
inline void qr_restore_row_blocks(double* packed,std::size_t m,std::size_t n,
                                  std::span<double> workspace) noexcept {
    const auto quotient=m/n;
    if(quotient!=1) {
        auto* marks=reinterpret_cast<unsigned char*>(workspace.data()+n);
        const auto bytes=m/8+(m%8!=0);
        std::fill_n(marks,bytes,static_cast<unsigned char>(0));
        for(std::size_t start=0;start<m;++start) {
            if((marks[start/8]&(1U<<(start%8)))!=0)continue;
            std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
            for(;n-i>=2;i+=2)_mm_storeu_pd(workspace.data()+i,_mm_loadu_pd(packed+start*n+i));
#endif
            for(;i<n;++i)workspace[i]=packed[start*n+i];
            auto current=start;
            do {
                const auto next=(current%quotient)*n+current/quotient;
                auto* block=packed+next*n;i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
                for(;n-i>=2;i+=2) {
                    const auto held=_mm_loadu_pd(workspace.data()+i),displaced=_mm_loadu_pd(block+i);
                    _mm_storeu_pd(block+i,held);_mm_storeu_pd(workspace.data()+i,displaced);
                }
#endif
                for(;i<n;++i)std::swap(workspace[i],block[i]);
                marks[current/8]|=static_cast<unsigned char>(1U<<(current%8));
                current=next;
            }while(current!=start);
        }
    }
    for(std::size_t b=0;b<quotient;++b) {
        auto* square=packed+b*n*n;
        for(std::size_t first=0;first<n;) {
            const auto end=first+std::min(std::size_t{8},n-first);
            for(std::size_t column=0;column<first;column+=8) {
                const auto stop=std::min(column+8,first);std::size_t i=first;
                for(;end-i>=2;i+=2) {
                    std::size_t j=column;
                    for(;stop-j>=2;j+=2)qr_swap_transpose_pair(square,n,i,j);
                    for(;j<stop;++j) {
                        std::swap(square[i*n+j],square[j*n+i]);
                        std::swap(square[(i+1)*n+j],square[j*n+i+1]);
                    }
                }
                for(;i<end;++i)for(std::size_t j=column;j<stop;++j)std::swap(square[i*n+j],square[j*n+i]);
            }
            std::size_t i=first;
            for(;end-i>=2;i+=2) {
                for(std::size_t j=first;j<i;j+=2)qr_swap_transpose_pair(square,n,i,j);
                std::swap(square[i*n+i+1],square[(i+1)*n+i]);
            }
            for(;i<end;++i)for(std::size_t j=first;j<i;++j)std::swap(square[i*n+j],square[j*n+i]);
            first=end;
        }
    }
}

// Four reflector projections share one contiguous row read. Ten candidate
// doubles hold the panel coefficients; unsupported ranges use the ordinary solve.
inline bool qr_apply_packet_panels(MatrixView<const double> packed,std::span<const double> tau,
                                  std::span<double> transformed,std::span<double> scratch) noexcept {
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto m=packed.rows(),n=packed.cols();
    if(n%4!=0 || scratch.size()<10)return false;
    double safe=std::numeric_limits<double>::max();
    for(std::size_t i=0;i<5;++i)safe/=8*static_cast<double>(m)+2;
    const auto sign=_mm_set1_pd(-0.0);
    for(std::size_t first=0;first<n;first+=4) {
        std::fill_n(scratch.data(),10,0.0);
        for(std::size_t j=0;j<4;++j)if(!(tau[first+j]>=0 && tau[first+j]<=2))return false;
        for(std::size_t r=first;r<first+4;++r) {
            double v[4];
            if(!(std::abs(transformed[r])<=safe))return false;
            for(std::size_t j=0;j<4;++j) {
                v[j]=r<first+j?0:(r==first+j?1:packed(r,first+j));
                if(!(std::abs(v[j])<=2))return false;
                scratch[j]+=v[j]*transformed[r];
            }
            scratch[4]+=v[0]*v[1];scratch[5]+=v[0]*v[2];scratch[6]+=v[0]*v[3];
            scratch[7]+=v[1]*v[2];scratch[8]+=v[1]*v[3];scratch[9]+=v[2]*v[3];
        }
        auto dot01=_mm_loadu_pd(scratch.data()),dot23=_mm_loadu_pd(scratch.data()+2);
        auto cross01=_mm_loadu_pd(scratch.data()+4),cross23=_mm_loadu_pd(scratch.data()+6),cross45=_mm_loadu_pd(scratch.data()+8);
        auto maximum=_mm_setzero_pd();double rhs_maximum=0;
        for(std::size_t r=first+4;r<m;++r) {
            const auto a=_mm_loadu_pd(&packed(r,first)),b=_mm_loadu_pd(&packed(r,first+2));
            const auto y=_mm_set1_pd(transformed[r]);
            maximum=_mm_max_pd(maximum,_mm_max_pd(_mm_andnot_pd(sign,a),_mm_andnot_pd(sign,b)));
            rhs_maximum=std::max(rhs_maximum,std::abs(transformed[r]));
            dot01=_mm_add_pd(dot01,_mm_mul_pd(a,y));dot23=_mm_add_pd(dot23,_mm_mul_pd(b,y));
            const auto middle=_mm_shuffle_pd(a,b,1);
            cross01=_mm_add_pd(cross01,_mm_mul_pd(_mm_unpacklo_pd(a,a),middle));
            cross23=_mm_add_pd(cross23,_mm_mul_pd(a,_mm_shuffle_pd(b,b,1)));
            cross45=_mm_add_pd(cross45,_mm_mul_pd(middle,_mm_unpackhi_pd(b,b)));
        }
        if(_mm_movemask_pd(_mm_cmple_pd(maximum,_mm_set1_pd(2)))!=3 || !(rhs_maximum<=safe))return false;
        _mm_storeu_pd(scratch.data(),dot01);_mm_storeu_pd(scratch.data()+2,dot23);
        _mm_storeu_pd(scratch.data()+4,cross01);_mm_storeu_pd(scratch.data()+6,cross23);_mm_storeu_pd(scratch.data()+8,cross45);
        const double p0=tau[first]*scratch[0];
        const double p1=tau[first+1]*(scratch[1]-scratch[4]*p0);
        const double p2=tau[first+2]*((scratch[2]-scratch[5]*p0)-scratch[7]*p1);
        const double p3=tau[first+3]*(((scratch[3]-scratch[6]*p0)-scratch[8]*p1)-scratch[9]*p2);
        if(!qr_is_finite(p0) || !qr_is_finite(p1) || !qr_is_finite(p2) || !qr_is_finite(p3))return false;
        const double projections[4]{p0,p1,p2,p3};
        for(std::size_t r=first;r<first+4;++r) {
            double value=transformed[r];
            for(std::size_t j=0;first+j<=r;++j)value-=(r==first+j?1:packed(r,first+j))*projections[j];
            if(!qr_is_finite(value))return false;
            transformed[r]=value;
        }
        for(std::size_t r=first+4;r<m;++r) {
            double value=transformed[r];
            value-=packed(r,first)*p0;value-=packed(r,first+1)*p1;
            value-=packed(r,first+2)*p2;value-=packed(r,first+3)*p3;
            if(!qr_is_finite(value))return false;
            transformed[r]=value;
        }
    }
    return true;
#else
    (void)packed;(void)tau;(void)transformed;(void)scratch;return false;
#endif
}


inline double column_norm(MatrixView<const double> matrix, std::size_t first, std::size_t column) noexcept {
    const auto count=matrix.rows()-first;
    if (count>=16) {
        double squared=0;
        std::size_t i=first;
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
        for (;i<matrix.rows();++i) {const double value=matrix(i,column);squared+=value*value;}
        // The fallback also covers positive subnormal sums where lost terms
        // could matter. No reciprocal scaling is used on the ordinary path.
        const auto safe_min=std::numeric_limits<double>::min()*static_cast<double>(count)/std::numeric_limits<double>::epsilon();
        if (squared>=safe_min && detail::qr_is_finite(squared)) return std::sqrt(squared);
    }
    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();
}

} // namespace kibo::linalg::detail
