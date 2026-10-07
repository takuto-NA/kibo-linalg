from pathlib import Path
import json

out=Path('.scratch/large-llt-next')
helper='''
inline void update_column_quad(double* p0,double* p1,double* p2,double* p3,const double* panel,
                               std::size_t stride,const double* coefficients,std::size_t width,std::size_t count) noexcept {
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
'''
for packet_count in [2,1]:
    helper+=f'    for(;count-i>={2*packet_count};i+={2*packet_count}) {{\n'
    for column in range(4):
        for packet in range(packet_count):helper+=f'        auto r{column}{packet}=_mm_loadu_pd(p{column}+i+{2*packet});\n'
    helper+='''        for(std::size_t k=0;k<width;++k) {
            const auto c01=_mm_loadu_pd(coefficients+k*stride),c23=_mm_loadu_pd(coefficients+k*stride+2);
            const auto c0=_mm_unpacklo_pd(c01,c01),c1=_mm_unpackhi_pd(c01,c01);
            const auto c2=_mm_unpacklo_pd(c23,c23),c3=_mm_unpackhi_pd(c23,c23);
'''
    for packet in range(packet_count):
        helper+=f'            const auto s{packet}=_mm_loadu_pd(panel+k*stride+i+{2*packet});\n'
        for column in range(4):helper+=f'            r{column}{packet}=_mm_sub_pd(r{column}{packet},_mm_mul_pd(c{column},s{packet}));\n'
    helper+='        }\n'
    for column in range(4):
        for packet in range(packet_count):helper+=f'        _mm_storeu_pd(p{column}+i+{2*packet},r{column}{packet});\n'
    helper+='    }\n'
helper+='''#endif
    for(;i<count;++i)for(std::size_t k=0;k<width;++k) {
        p0[i]-=coefficients[k*stride]*panel[k*stride+i];
        p1[i]-=coefficients[k*stride+1]*panel[k*stride+i];
        p2[i]-=coefficients[k*stride+2]*panel[k*stride+i];
        p3[i]-=coefficients[k*stride+3]*panel[k*stride+i];
    }
}
'''
variants=['quad8_divide','quad8_divide_forward4']
for variant in variants:
    base='pair8_divide_forward4_sym' if 'forward4' in variant else 'pair8_divide'
    for path in (out/'variants'/base).rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            before='''                std::size_t j=end;
                for (;n-j>=2;j+=2) {'''
            after='''                std::size_t j=end;
                for (;n-j>=4;j+=4) {
                    for(std::size_t column=j;column<j+3;++column)
                        for(std::size_t i=column;i<j+3;++i)
                            for(std::size_t k=first;k<end;++k) working(i,column)-=working(i,k)*working(column,k);
                    update_column_quad(&working(j+3,j),&working(j+3,j+1),&working(j+3,j+2),&working(j+3,j+3),
                                       &working(j+3,first),working.col_stride(),&working(j,first),end-first,n-j-3);
                }
                for (;n-j>=2;j+=2) {'''
            assert before in text
            text=text.replace(before,after).replace('inline Result<LltFactorView> factorize_column_llt',helper+'\ninline Result<LltFactorView> factorize_column_llt')
        # No unsupported symmetry shortcut in this experiment.
        if path.name=='row_kernels.hpp':text=(out/'variants/actual/kibo/detail/row_kernels.hpp').read_text()
        target=out/'variants'/variant/path.relative_to(out/'variants'/base)
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
(out/'quad-variants.json').write_text(json.dumps(variants))
print('Prepared four-column shared-load controls; scalar per-value order preserved')
