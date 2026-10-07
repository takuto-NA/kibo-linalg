from pathlib import Path
out=Path('.scratch/large-llt-next')
helpers='''
inline void copy_lower_to_upper(MatrixView<const double> input,MatrixView<double> storage) noexcept {
    const auto n=input.rows();
    if(input.col_stride()!=1) {
        for(std::size_t j=0;j<n;++j) for(std::size_t i=j;i<n;++i) storage(j,i)=input(i,j);
        return;
    }
    const auto zero=_mm_setzero_pd();
    for(std::size_t i=0;i<n;i+=2) {
        if(i+1==n) {for(std::size_t j=0;j<=i;++j)storage(j,i)=input(i,j);break;}
        for(std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&input(i,j)),b=_mm_loadu_pd(&input(i+1,j));
            _mm_storeu_pd(&storage(j,i),_mm_unpacklo_pd(a,b));
            _mm_storeu_pd(&storage(j+1,i),_mm_unpackhi_pd(a,b));
        }
        storage(i,i)=input(i,i);storage(i,i+1)=input(i+1,i);storage(i+1,i+1)=input(i+1,i+1);
    }
}
inline void restore_lower_from_upper(MatrixView<double> storage) noexcept {
    const auto n=storage.rows();
    const auto zero=_mm_setzero_pd();
    for(std::size_t i=0;i<n;i+=2) {
        if(i+1==n) {for(std::size_t j=0;j<i;++j){storage(i,j)=storage(j,i);storage(j,i)=0;}break;}
        for(std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&storage(j,i)),b=_mm_loadu_pd(&storage(j+1,i));
            _mm_storeu_pd(&storage(i,j),_mm_unpacklo_pd(a,b));
            _mm_storeu_pd(&storage(i+1,j),_mm_unpackhi_pd(a,b));
            _mm_storeu_pd(&storage(j,i),zero);_mm_storeu_pd(&storage(j+1,i),zero);
        }
        storage(i+1,i)=storage(i,i+1);storage(i,i+1)=0;
    }
}
'''.replace('    const auto zero=_mm_setzero_pd();\n    for(std::size_t i=0;i<n;i+=2) {','    for(std::size_t i=0;i<n;i+=2) {',1)
# This diagnostic is x64-only, like the surrounding full harness. Public
# adoption would require guards plus scalar fallback; do not use as portable core.
copy='        for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);'
start='''        for (std::size_t first=0;first<n;) {
            const auto end=first+std::min(std::size_t{8},n-first);
            for (std::size_t column=0;column<first;column+=8) {'''
end='''            first=end;
        }
    }
    return LltAccess::create(storage);'''
variants=['copy_tile','restore_tile','transfer_tile','pair8_divide_copy_tile','pair8_divide_restore_tile','pair8_divide_transfer_tile']
for variant in variants:
    base='pair8_divide' if variant.startswith('pair8') else 'actual'
    for path in (out/'variants'/base).rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            text=text.replace('inline Result<LltFactorView> factorize_column_llt',helpers+'\ninline Result<LltFactorView> factorize_column_llt',1)
            if 'copy' in variant or 'transfer' in variant:
                assert copy in text;text=text.replace(copy,'        copy_lower_to_upper(input,storage);',1)
            if 'restore' in variant or 'transfer' in variant:
                first=text.index(start);last=text.index(end,first)+len('            first=end;\n        }')
                text=text[:first]+'        restore_lower_from_upper(storage);'+text[last:]
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
print('Prepared six copy/restore controls, public code unchanged')
