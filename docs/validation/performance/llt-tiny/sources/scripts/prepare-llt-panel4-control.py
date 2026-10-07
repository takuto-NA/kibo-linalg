from pathlib import Path
import shutil
root=Path.cwd();p=root/'.scratch/large-llt-next/CMakeLists.txt';cm=p.read_text()
old='            const auto end=first+std::min(std::size_t{8},n-first);'
base=(root/'include/kibo/llt.hpp').read_text();assert base.count(old)==2
for name,width in [('panel4','std::size_t{4}'),('panel4_small','n<=256?std::size_t{4}:std::size_t{8}')]:
    dest=root/f'.scratch/large-llt-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    (dest/'llt.hpp').write_text(base.replace(old,f'            const auto end=first+std::min({width},n-first);',1))
    if f'add_executable({name} ' not in cm:
        cm+=f'''
add_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
p.write_text(cm)
print('prepared private four-column depth control; restore tile stays eight')
