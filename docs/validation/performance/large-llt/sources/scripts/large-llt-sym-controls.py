from pathlib import Path
import json

out=Path('.scratch/large-llt-next')
dot='''
inline double llt_forward_dot(const double* a,const double* b,std::size_t count) noexcept {
    double result=0;std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    auto p0=_mm_setzero_pd(),p1=p0,p2=p0,p3=p0;
    for(;count-i>=8;i+=8) {
        p0=_mm_add_pd(p0,_mm_mul_pd(_mm_loadu_pd(a+i),_mm_loadu_pd(b+i)));
        p1=_mm_add_pd(p1,_mm_mul_pd(_mm_loadu_pd(a+i+2),_mm_loadu_pd(b+i+2)));
        p2=_mm_add_pd(p2,_mm_mul_pd(_mm_loadu_pd(a+i+4),_mm_loadu_pd(b+i+4)));
        p3=_mm_add_pd(p3,_mm_mul_pd(_mm_loadu_pd(a+i+6),_mm_loadu_pd(b+i+6)));
    }
    const auto sum=_mm_add_pd(_mm_add_pd(p0,p1),_mm_add_pd(p2,p3));
    result=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
#endif
    for(;i<count;++i)result+=a[i]*b[i];
    return result;
}
'''
variants=['symmetry','pair8_divide_sym','pair8_divide_forward_sym','forward4','pair8_divide_forward4_sym']
for variant in variants:
    base='pair8_divide' if variant.startswith('pair') else 'actual'
    for path in (out/'variants'/base).rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp' and 'forward' in variant:
            name='llt_forward_dot' if 'forward4' in variant else 'contiguous_dot'
            arguments='&lower(i,0),candidate.data(),i'+('' if name=='llt_forward_dot' else ',0')
            text=text.replace('        for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];',
                f'        if(n>=128 && lower.col_stride()==1) value-=detail::{name}({arguments});\n'
                '        else for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];')
            if name=='llt_forward_dot':text=text.replace('inline Result<LltFactorView> factorize_column_llt',dot+'\ninline Result<LltFactorView> factorize_column_llt')
        if path.name=='row_kernels.hpp' and 'sym' in variant:
            text=text.replace('    const auto divisor=_mm_set1_pd(scale), limit=_mm_set1_pd(tolerance), sign=_mm_set1_pd(-0.0);',
                '''    const auto divisor=_mm_set1_pd(scale), limit=_mm_set1_pd(tolerance), sign=_mm_set1_pd(-0.0);
    // Conservative sufficient condition only; close cases retain exact divisions.
    const bool shortcut=tolerance>=16*std::numeric_limits<double>::epsilon() && (_mm_getcsr()&0xe040)==0;
    const auto certain=_mm_set1_pd((tolerance/8)*scale);''')
            text=text.replace('            if (_mm_movemask_pd(equal)!=3) {',
                '''            const auto certain_a=_mm_cmple_pd(_mm_andnot_pd(sign,_mm_sub_pd(a,_mm_unpacklo_pd(c,d))),certain);
            const auto certain_b=_mm_cmple_pd(_mm_andnot_pd(sign,_mm_sub_pd(b,_mm_unpackhi_pd(c,d))),certain);
            if (_mm_movemask_pd(equal)!=3 && !(shortcut && _mm_movemask_pd(_mm_and_pd(certain_a,certain_b))==3)) {''')
        target=out/'variants'/variant/path.relative_to(out/'variants'/base)
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists() or target.read_text()!=text:target.write_text(text)
cmake=out/'CMakeLists.txt';text=cmake.read_text()
for variant in variants:
    if f'add_executable({variant} ' in text:continue
    text+=f'''add_executable({variant} ../../tools/diagnostics/small-llt/full.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
cmake.write_text(text)
(out/'sym-variants.json').write_text(json.dumps(variants))
print('Prepared conservative symmetry acceptance and forward dependency controls')
