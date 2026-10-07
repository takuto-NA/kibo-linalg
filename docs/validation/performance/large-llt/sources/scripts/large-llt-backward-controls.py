from pathlib import Path
out=Path('.scratch/large-llt-next')
base='pair8_divide_inline_forward4rows'
helper='''
inline void row_update_two_ordered(double* values,const double* a,const double* b,std::size_t count,
                                   double first,double second) noexcept {
    const auto x=_mm_set1_pd(first),y=_mm_set1_pd(second);
    std::size_t j=0;
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
    for(;j<count;++j){values[j]-=a[j]*first;values[j]-=b[j]*second;}
}
'''
original='''    if (detail::row_simd_available && lower.col_stride()==1 && n>=9) {
        for (std::size_t i=n;i-->0;) {'''
replacement='''    if(detail::row_simd_available && lower.col_stride()==1 && n>=128) {
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
        for (std::size_t i=n;i-->0;) {'''
for variant in ['shared_back2','shared_back2_width16','shared_back2_width16_small']:
    for path in (out/'variants'/base).rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            assert original in text;text=text.replace(original,replacement,1)
            text=text.replace('inline Result<LltFactorView> factorize_column_llt',helper+'\ninline Result<LltFactorView> factorize_column_llt',1)
            if 'width16' in variant:
                value='(n<=128 ? std::size_t{16} : std::size_t{8})' if variant.endswith('small') else 'std::size_t{16}'
                assert 'std::size_t{8},n-first' in text
                text=text.replace('std::size_t{8},n-first',value+',n-first',1)
        target=out/'variants'/variant/path.relative_to(out/'variants'/base)
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists() or target.read_text()!=text:target.write_text(text)
cmake=out/'CMakeLists.txt';text=cmake.read_text()
for variant in ['shared_back2','shared_back2_width16','shared_back2_width16_small']:
    if f'add_executable({variant} ' in text:continue
    text+=f'''add_executable({variant} full-adaptive.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
cmake.write_text(text)
print('Prepared ordered two-row backward updates and panel16 controls')
