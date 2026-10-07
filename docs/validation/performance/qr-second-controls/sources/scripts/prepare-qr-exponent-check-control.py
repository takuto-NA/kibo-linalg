from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/detail/row_kernels.hpp').read_text()
start=base.index('inline bool row_update_checked(');end=base.index('\ninline void row_project_four_rows(',start)
row=base[start:end]
row=row.replace('const auto sign=_mm_set1_pd(-0.0);\n    const auto maximum=_mm_set1_pd(std::numeric_limits<double>::max());\n    auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());',
                'const auto exponent=_mm_castsi128_pd(_mm_set1_epi64x(0x7ff0000000000000LL));\n    auto valid=_mm_setzero_pd();')
for value,mask in [('first','valid'),('second','second_valid'),('updated','valid')]:
    row=row.replace(f'{mask}=_mm_and_pd({mask},_mm_cmple_pd(_mm_andnot_pd(sign,{value}),maximum));',f'{mask}=_mm_max_pd({mask},_mm_and_pd(exponent,{value}));')
row=row.replace('finite=_mm_movemask_pd(_mm_and_pd(valid,second_valid))==3;',
                'finite=_mm_movemask_pd(_mm_cmplt_pd(_mm_max_pd(valid,second_valid),exponent))==3;')
assert 'sign' not in row and 'maximum' not in row
base=base[:start]+row+base[end:]
start=base.index('inline bool column_update_four_checked(');end=base.index('\ninline void column_project_four(',start)
col=base[start:end]
col=col.replace('const auto sign=_mm_set1_pd(-0.0),maximum=_mm_set1_pd(std::numeric_limits<double>::max());\n    auto va=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd()),vb=va,vc=va,vd=va;',
                'const auto exponent=_mm_castsi128_pd(_mm_set1_epi64x(0x7ff0000000000000LL));\n    auto va=_mm_setzero_pd(),vb=va,vc=va,vd=va;')
for mask,value in [('va','x0'),('vb','x1'),('vc','x2'),('vd','x3')]:
    col=col.replace(f'{mask}=_mm_and_pd({mask},_mm_cmple_pd(_mm_andnot_pd(sign,{value}),maximum));',f'{mask}=_mm_max_pd({mask},_mm_and_pd(exponent,{value}));')
col=col.replace('_mm_movemask_pd(_mm_and_pd(_mm_and_pd(va,vb),_mm_and_pd(vc,vd)))',
                '_mm_movemask_pd(_mm_cmplt_pd(_mm_max_pd(_mm_max_pd(va,vb),_mm_max_pd(vc,vd)),exponent))')
assert 'sign' not in col and 'maximum' not in col
base=base[:start]+col+base[end:]
name='exponent_check';dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
(dest/'detail/row_kernels.hpp').write_text(base)
p=root/'.scratch/qr-next/CMakeLists.txt';cm=p.read_text()
for layout,defs in [('column','QR_COLUMN=1'),('row_same','EIGEN_ROW=1'),('row_best','')]:
    target=f'{name}_{layout}'
    if f'add_executable({target} ' not in cm:
        cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
p.write_text(cm)
print('prepared private exact exponent classification reduction; no public change')
