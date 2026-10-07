from pathlib import Path
p=Path('.scratch/large-llt-next/CMakeLists.txt');s=p.read_text()
for test in ['llt','llt_large']:
    for mode in ['simd','scalar']:
        name=f'fixed8_{test}_{mode}'
        if f'add_executable({name} ' in s:continue
        define='target_compile_definitions('+name+' PRIVATE KIBO_DISABLE_SIMD=1)\n' if mode=='scalar' else ''
        s+=f'''add_executable({name} ../../tests/{test}_tests.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/fixed8)
target_compile_options({name} PRIVATE /O2 /fp:precise)
{define}'''
p.write_text(s)
s=Path('.scratch/disassemble-llt-store-public.py').read_text().replace('.scratch/llt-store-public-objects','.scratch/llt-fixed8-objects')
Path('.scratch/disassemble-llt-fixed8.py').write_text(s)
