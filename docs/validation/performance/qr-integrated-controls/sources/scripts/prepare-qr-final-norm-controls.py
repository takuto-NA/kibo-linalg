from pathlib import Path
import shutil
root=Path.cwd();source=root/'.scratch/qr-next/variants/column_work_packet_local/kibo'
base=(source/'qr.hpp').read_text();sample=(root/'.scratch/qr-next/variants/combo_vector_norm/kibo/qr.hpp').read_text()
start=sample.index('inline double column_norm(');end=sample.index('\n}\n',start)+3
oldstart=base.index('inline double column_norm(');oldend=base.index('\n}\n',oldstart)+3
fast=base[:oldstart]+sample[start:end]+base[oldend:]
kernels=(source/'detail/row_kernels.hpp').read_text();at=kernels.index('inline bool row_update_checked(')
insert='''    auto third_valid=valid,fourth_valid=valid;
    for(;count-j>=8;j+=8) {
        const auto a=_mm_sub_pd(_mm_loadu_pd(row+j),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j)));
        const auto b=_mm_sub_pd(_mm_loadu_pd(row+j+2),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+2)));
        const auto c=_mm_sub_pd(_mm_loadu_pd(row+j+4),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+4)));
        const auto d=_mm_sub_pd(_mm_loadu_pd(row+j+6),_mm_mul_pd(multiplier,_mm_loadu_pd(projection+j+6)));
        _mm_storeu_pd(row+j,a);_mm_storeu_pd(row+j+2,b);_mm_storeu_pd(row+j+4,c);_mm_storeu_pd(row+j+6,d);
        valid=_mm_max_pd(valid,_mm_and_pd(exponent,a));second_valid=_mm_max_pd(second_valid,_mm_and_pd(exponent,b));
        third_valid=_mm_max_pd(third_valid,_mm_and_pd(exponent,c));fourth_valid=_mm_max_pd(fourth_valid,_mm_and_pd(exponent,d));
    }
'''
prefix=kernels[:at];body=kernels[at:]
body=body.replace('    for (;count-j>=4;j+=4) {',insert+'    for (;count-j>=4;j+=4) {',1)
body=body.replace('finite=_mm_movemask_pd(_mm_cmplt_pd(_mm_max_pd(valid,second_valid),exponent))==3;',
    'finite=_mm_movemask_pd(_mm_cmplt_pd(_mm_max_pd(_mm_max_pd(valid,second_valid),_mm_max_pd(third_valid,fourth_valid)),exponent))==3;',1)
checked=prefix+body
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for name,code,rows in [('column_work_fast',fast,kernels),('column_work_checked8',fast,checked)]:
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(source,dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code);(dest/'detail/row_kernels.hpp').write_text(rows)
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
print('scaled fallback after ordinary SIMD norm, plus four independent finite accumulators prepared')
