from pathlib import Path
out=Path('.scratch/large-llt-next');base='shared_back2';variant='shared_reciprocal'
for path in (out/'variants'/base).rglob('*.hpp'):
    text=path.read_text()
    if path.name=='llt.hpp':
        first=text.index('inline bool divide_contiguous_checked');last=text.index('\ninline',first+12)
        helper=text[first:last]
        helper=helper.replace('    std::size_t i=0;','    const double inverse=1.0/divisor;\n    std::size_t i=0;',1)
        helper=helper.replace('_mm_set1_pd(divisor)','_mm_set1_pd(inverse)').replace('_mm_div_pd','_mm_mul_pd')
        helper=helper.replace('values[i]/divisor','values[i]*inverse')
        text=text[:first]+helper+text[last:]
    target=out/'variants'/variant/path.relative_to(out/'variants'/base)
    target.parent.mkdir(parents=True,exist_ok=True)
    if not target.exists() or target.read_text()!=text:target.write_text(text)
cmake=out/'CMakeLists.txt';text=cmake.read_text()
if f'add_executable({variant} ' not in text:
    text+=f'''add_executable({variant} full-adaptive.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
cmake.write_text(text)
print('Prepared reciprocal-control only; changes division rounding, not public adoption')
