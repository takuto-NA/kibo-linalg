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
