from pathlib import Path
import shutil
root=Path.cwd();dest=root/'.scratch/large-llt-next/variants/view_wide_product/kibo'
shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
p=dest/'linalg.hpp';s=p.read_text()
s=s.replace('#include <utility>','#include <utility>\n#if defined(_MSC_VER) && defined(_M_X64)\n#include <intrin.h>\n#endif',1)
old='''        if ((rs != 1 && rows - 1 > max / rs) || (cs != 1 && cols - 1 > max / cs))
            return StatusCode::size_overflow;
        const auto last_row = (rows - 1) * rs, last_col = (cols - 1) * cs;'''
new='''#if defined(_MSC_VER) && defined(_M_X64)
        unsigned __int64 row_high=0,col_high=0;
        const auto last_row=static_cast<std::size_t>(_umul128(rows-1,rs,&row_high));
        const auto last_col=static_cast<std::size_t>(_umul128(cols-1,cs,&col_high));
        if (row_high!=0 || col_high!=0) return StatusCode::size_overflow;
#else
        if ((rs != 1 && rows - 1 > max / rs) || (cs != 1 && cols - 1 > max / cs))
            return StatusCode::size_overflow;
        const auto last_row = (rows - 1) * rs, last_col = (cols - 1) * cs;
#endif'''
assert old in s;p.write_text(s.replace(old,new,1))
p=root/'.scratch/large-llt-next/CMakeLists.txt';s=p.read_text()
for name,source in [('view_wide_product','full-adaptive.cpp'),('view_wide_product_uninitialized','uninitialized-setup.cpp')]:
    if f'add_executable({name} ' not in s:
        s+=f'''
add_executable({name} {source})
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/view_wide_product ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
p.write_text(s)
print('prepared equivalent wide-product overflow control; no public change')
