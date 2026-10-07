from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/qr.hpp').read_text()
dot='''inline double qr_strided_dot(const double* values,std::size_t stride,const double* vector,
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
'''
update='''inline bool qr_strided_update_checked(double* vector,const double* values,std::size_t stride,
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
        if (!std::isfinite(vector[i])) return false;
    }
    return true;
}
'''
dot_old='''        else
        for (std::size_t i=k+1;i<m;++i) dot+=packed(i,k)*transformed[i];'''
dot_new='''        else if (m-k>1)
            dot=detail::qr_strided_dot(&packed(k+1,k),packed.row_stride(),transformed.data()+k+1,m-k-1,dot);'''
update_old='''        } else
        for (std::size_t i=k+1;i<m;++i) {
            transformed[i]-=packed(i,k)*multiplier;
            if (!std::isfinite(transformed[i])) return {StatusCode::arithmetic_failure,k};
        }'''
update_new='''        } else if (m-k>1) {
            if (!detail::qr_strided_update_checked(transformed.data()+k+1,&packed(k+1,k),packed.row_stride(),m-k-1,multiplier))
                return {StatusCode::arithmetic_failure,k};
        }'''
assert dot_old in base and update_old in base
variants={'strided_dot':base.replace('namespace detail {\n','namespace detail {\n'+dot,1).replace(dot_old,dot_new,1),
          'strided_update':base.replace('namespace detail {\n','namespace detail {\n'+update,1).replace(update_old,update_new,1)}
variants['strided_both']=variants['strided_dot'].replace('namespace detail {\n','namespace detail {\n'+update,1).replace(update_old,update_new,1)
p=root/'.scratch/qr-next/CMakeLists.txt';cm=p.read_text()
for name,code in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True);(dest/'qr.hpp').write_text(code)
    for layout,defs in [('column','QR_COLUMN=1'),('row_same','EIGEN_ROW=1'),('row_best','')]:
        target=f'{name}_{layout}'
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
p.write_text(cm)
print('prepared independent strided Householder solve dot/update controls; no public change')
