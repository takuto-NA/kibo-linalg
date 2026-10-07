from pathlib import Path
out=Path('.scratch/large-llt-next')
old='''    for (std::size_t i=0;i<n;++i) {
        double value=rhs[i];
        for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];
        value/=lower(i,i);
        if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }'''
variants=[]
for rows in [2,4]:
    packets=8//rows;step=2*packets
    helper='''
inline Status llt_forward_shared(MatrixView<const double> lower,std::span<const double> rhs,
                                 std::span<double> candidate) noexcept {
    const auto n=lower.rows();std::size_t i=0;
'''+f'    for(;n-i>={rows};i+={rows}) {{\n'
    for r in range(rows):
        for p in range(packets):helper+=f'        auto s{r}_{p}=_mm_setzero_pd();\n'
    helper+=f'        std::size_t j=0;\n        for(;i-j>={step};j+={step}) {{\n'
    for p in range(packets):
        helper+=f'            const auto x{p}=_mm_loadu_pd(candidate.data()+j+{2*p});\n'
        for r in range(rows):
            helper+=f'            s{r}_{p}=_mm_add_pd(s{r}_{p},_mm_mul_pd(_mm_loadu_pd(&lower(i+{r},j+{2*p})),x{p}));\n'
    helper+='        }\n        for(;i-j>=2;j+=2) {\n            const auto x=_mm_loadu_pd(candidate.data()+j);\n'
    for r in range(rows):helper+=f'            s{r}_0=_mm_add_pd(s{r}_0,_mm_mul_pd(_mm_loadu_pd(&lower(i+{r},j)),x));\n'
    helper+='        }\n'
    for r in range(rows):
        sums=[f's{r}_{p}' for p in range(packets)]
        while len(sums)>1:sums=[f'_mm_add_pd({sums[p]},{sums[p+1]})' for p in range(0,len(sums),2)]
        helper+=f'        const auto sum{r}={sums[0]};\n'
        helper+=f'        double v{r}=rhs[i+{r}]-(_mm_cvtsd_f64(sum{r})+_mm_cvtsd_f64(_mm_unpackhi_pd(sum{r},sum{r})));\n'
        helper+=f'        if(j<i)v{r}-=lower(i+{r},j)*candidate[j];\n'
        for k in range(r):helper+=f'        v{r}-=lower(i+{r},i+{k})*candidate[i+{k}];\n'
        helper+=f'        v{r}/=lower(i+{r},i+{r});\n'
        helper+=f'        if(!llt_is_finite(v{r}))return {{StatusCode::arithmetic_failure,i+{r}}};\n'
        helper+=f'        candidate[i+{r}]=v{r};\n'
    helper+='''    }
    for(;i<n;++i) {
        double value=rhs[i];
        for(std::size_t j=0;j<i;++j)value-=lower(i,j)*candidate[j];
        value/=lower(i,i);
        if(!llt_is_finite(value))return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }
    return {};
}
'''
    variant=f'pair8_divide_inline_forward{rows}rows';variants.append(variant)
    for path in (out/'variants/pair8_divide_inline').rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            assert old in text
            text=text.replace('inline Result<LltFactorView> factorize_column_llt',helper+'\ninline Result<LltFactorView> factorize_column_llt',1)
            text=text.replace(old,'''    if(n>=128 && lower.col_stride()==1) {
        auto status=detail::llt_forward_shared(lower,rhs,candidate);
        if(!status)return status;
    } else {
'''+old+'\n    }',1)
        target=out/'variants'/variant/path.relative_to(out/'variants/pair8_divide_inline')
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists() or target.read_text()!=text:target.write_text(text)
cmake=out/'CMakeLists.txt';text=cmake.read_text()
for variant in variants:
    if f'add_executable({variant} ' in text:continue
    text+=f'''add_executable({variant} full-adaptive.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
cmake.write_text(text)
print('Prepared two/four-row shared forward-dot controls, original public code unchanged')
