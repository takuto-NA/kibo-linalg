from pathlib import Path
import shutil
root=Path.cwd();cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for source_name,name in [('column_work_fast','column_work_restore'),('column_work_checked8','column_work_final')]:
    source=root/f'.scratch/qr-next/variants/{source_name}/kibo';code=(source/'qr.hpp').read_text()
    first=code.index('inline void qr_restore_row_blocks(');last=code.index('\n}\n',first)+3
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(source,dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code[:first]+(root/'.scratch/qr-restore-packet.inc').read_text()+code[last:])
    for layout,defs in [('column','QR_COLUMN=1'),('row_best','')]:
        target=f'{name}_{layout}'
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
cm_path.write_text(cm)
print('packet block permutation and two-by-two tiled transpose prepared')
