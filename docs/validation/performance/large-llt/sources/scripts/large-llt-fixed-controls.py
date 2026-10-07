from pathlib import Path
out=Path('.scratch/large-llt-next')
variants=['pair8_divide_fixed','pair8_divide_inline','pair8_divide_fixed_inline']
for variant in variants:
    for path in (out/'variants/pair8_divide').rglob('*.hpp'):
        text=path.read_text()
        if path.name=='llt.hpp':
            if 'fixed' in variant:
                before='std::size_t width, std::size_t count) noexcept {\n    std::size_t i=0;'
                after='std::size_t /*width*/, std::size_t count) noexcept {\n    constexpr std::size_t width=8;\n    std::size_t i=0;'
                assert before in text;text=text.replace(before,after,1)
            if 'inline' in variant:
                assert 'inline void update_column_pair' in text
                text=text.replace('inline void update_column_pair','__forceinline void update_column_pair',1)
        target=out/'variants'/variant/path.relative_to(out/'variants/pair8_divide')
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
print('Prepared fixedwidth and inline controls for the always-width8 trailing panel')
