from pathlib import Path
out=Path('.scratch/large-llt-next');base=out/'variants/shared_back2'
guard='#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))'
for path in base.rglob('*.hpp'):
    text=path.read_text()
    if path.name=='llt.hpp':
        text=text.replace('__forceinline void update_column_pair', '#if defined(_MSC_VER)\n__forceinline\n#else\ninline\n#endif\nvoid update_column_pair',1)
        start=text.index('inline Status llt_forward_shared')
        split=text.index('    for(;i<n;++i)',start)
        text=text[:split]+'#endif\n'+text[split:]
        split=text.index('    for(;n-i>=4;i+=4)',start)
        text=text[:split]+guard+'\n'+text[split:]
        start=text.index('inline void row_update_two_ordered')
        begin=text.index('    const auto x=',start)
        end=text.index('    for(;j<count;++j)',begin)
        chunk=text[begin:end].replace('    std::size_t j=0;\n','')
        text=text[:begin]+'    std::size_t j=0;\n'+guard+'\n'+chunk+'#endif\n'+text[end:]
        text=text.replace('if(n>=128 && lower.col_stride()==1)', 'if(detail::row_simd_available && n>=128 && lower.col_stride()==1)',1)
    dest=out/'variants/portable_shared'/path.relative_to(base)
    dest.parent.mkdir(parents=True,exist_ok=True);dest.write_text(text)
cmake=out/'CMakeLists.txt';text=cmake.read_text()
for name,variant,scalar in [('large_contract_baseline','actual',False),('large_contract_shared','portable_shared',False),('large_contract_scalar','portable_shared',True)]:
    if f'add_executable({name} ' in text:continue
    text+=f'''add_executable({name} ../../tests/llt_large_tests.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{variant})
target_compile_options({name} PRIVATE /O2 /fp:precise)
'''
    if scalar:text+=f'target_compile_definitions({name} PRIVATE KIBO_DISABLE_SIMD=1)\n'
cmake.write_text(text)
