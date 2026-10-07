from pathlib import Path
import shutil
root=Path.cwd()
old='''    for (std::size_t i=n;i-->0;) {
        double value=transformed[i];
        for (std::size_t j=i+1;j<n;++j) value-=packed(i,j)*candidate[j];
        value/=packed(i,i);
        if (!detail::qr_is_finite(value)) return {StatusCode::arithmetic_failure,i};
        candidate[i]=value;
    }'''
new='''    if(packed.row_stride()==1) {
        for(std::size_t i=0;i<n;++i)candidate[i]=transformed[i];
        for(std::size_t i=n;i-->0;) {
            const double value=candidate[i]/packed(i,i);
            if(!detail::qr_is_finite(value))return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
            if(i!=0)detail::row_update(candidate.data(),&packed(0,i),i,value);
        }
    } else {
        for (std::size_t i=n;i-->0;) {
            double value=transformed[i];
            if(packed.col_stride()==1 && n-i>1)
                value-=detail::contiguous_dot(&packed(i,i+1),candidate.data()+i+1,n-i-1,0);
            else for (std::size_t j=i+1;j<n;++j)value-=packed(i,j)*candidate[j];
            value/=packed(i,i);
            if (!detail::qr_is_finite(value)) return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
        }
    }'''
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for base_name,name in [('combo_certified_norm','triangular_stream'),('column_work_8','column_work_triangular')]:
    source=root/f'.scratch/qr-next/variants/{base_name}/kibo'
    code=(source/'qr.hpp').read_text();assert old in code
    dest=root/f'.scratch/qr-next/variants/{name}/kibo'
    shutil.copytree(source,dest,dirs_exist_ok=True);(dest/'qr.hpp').write_text(code.replace(old,new,1))
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
print('column streamed R substitution and row packet dot controls prepared')
