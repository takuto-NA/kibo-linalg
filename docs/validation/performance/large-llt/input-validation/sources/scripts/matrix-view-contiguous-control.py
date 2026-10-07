from pathlib import Path
import shutil
root=Path.cwd();name='view_fast';dest=root/f'.scratch/large-llt-next/variants/{name}/kibo'
shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
p=dest/'linalg.hpp';s=p.read_text()
old='if (rows - 1 > max / rs || cols - 1 > max / cs) return StatusCode::size_overflow;'
new='if ((rs!=1 && rows-1>max/rs) || (cs!=1 && cols-1>max/cs)) return StatusCode::size_overflow;'
assert old in s;s=s.replace(old,new,1)
old='''            const auto divisor = std::gcd(rs, cs);
            if (rows > cs / divisor && cols > rs / divisor) return StatusCode::invalid_layout;'''
new='''            if(cs==1) {
                if(rows>1 && cols>rs)return StatusCode::invalid_layout;
            } else if(rs==1) {
                if(cols>1 && rows>cs)return StatusCode::invalid_layout;
            } else {
                const auto divisor=std::gcd(rs,cs);
                if(rows>cs/divisor && cols>rs/divisor)return StatusCode::invalid_layout;
            }'''
assert old in s;s=s.replace(old,new,1);p.write_text(s)
p=root/'.scratch/large-llt-next/CMakeLists.txt';s=p.read_text()
for target,source in [('view_fast','full-adaptive.cpp'),('view_fast_packed','packed-setup.cpp'),('view_fast_uninitialized','uninitialized-setup.cpp')]:
    if f'add_executable({target} ' in s:continue
    s+=f'''
add_executable({target} {source})
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
p.write_text(s);print('prepared unit-stride overflow and gcd specialization only, no public adoption')
