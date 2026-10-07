from pathlib import Path
import json

out=Path('.scratch/large-llt-next')
helper='''
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
'''
variants=['divide','pair8_divide','pair_pack8','pair_pack8_divide','pair_pack16','pair_pack16_divide','forward','pair8_forward']
for variant in variants:
    base='pair16' if 'pack16' in variant else 'pair8' if variant.startswith('pair') else 'actual'
    for path in (out/'variants'/base).rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            if 'pack' in variant:
                text=text.replace('std::size_t width, std::size_t count) noexcept {\n    std::size_t i=0;',
                                  'std::size_t width, std::size_t count, std::size_t coefficient_stride) noexcept {\n    std::size_t i=0;')
                text=text.replace('coefficients+k*stride','coefficients+k*coefficient_stride')
                text=text.replace('coefficients[k*stride','coefficients[k*coefficient_stride')
                before='''                    update_column_pair(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                       working.col_stride(),&working(j,first),end-first,n-j-1);'''
                after='''                    auto* coefficients=&working(0,n-1);
                    for(std::size_t k=first;k<end;++k) {
                        coefficients[2*(k-first)]=working(j,k);
                        coefficients[2*(k-first)+1]=working(j+1,k);
                    }
                    update_column_pair(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                       working.col_stride(),coefficients,end-first,n-j-1,2);'''
                assert before in text
                text=text.replace(before,after)
            if 'divide' in variant:
                text=text.replace('inline Result<LltFactorView> factorize_column_llt',helper+'\ninline Result<LltFactorView> factorize_column_llt')
                for begin,end in [('k+1','end'),('end','n')]:
                    before=f'''                for (std::size_t i={begin};i<{end};++i) {{
                    const double value=working(i,k)/working(k,k);
                    if (!detail::llt_is_finite(value)) return Status{{StatusCode::arithmetic_failure,k}};
                    working(i,k)=value;
                }}'''
                    after=f'''                if({end}>{begin} && !divide_contiguous_checked(&working({begin},k),{end}-({begin}),working(k,k)))
                    return Status{{StatusCode::arithmetic_failure,k}};'''
                    assert before in text,(variant,begin)
                    text=text.replace(before,after)
            if 'forward' in variant:
                before='        for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];'
                after='''        if(n>=128 && lower.col_stride()==1) value-=detail::contiguous_dot(&lower(i,0),candidate.data(),i,0);
        else for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];'''
                assert before in text;text=text.replace(before,after)
        target=out/'variants'/variant/path.relative_to(out/'variants'/base)
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists() or target.read_text()!=text:target.write_text(text)
cmake=out/'CMakeLists.txt'
text=cmake.read_text()
for variant in variants:
    if f'add_executable({variant} ' in text:continue
    text+=f'''add_executable({variant} ../../tools/diagnostics/small-llt/full.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
cmake.write_text(text)
(out/'next-variants.json').write_text(json.dumps(variants))
print('Prepared',len(variants),'exact-divide, paired coefficient and solve controls')
