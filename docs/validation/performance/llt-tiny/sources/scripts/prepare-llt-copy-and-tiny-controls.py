from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/llt.hpp').read_text()
copy_old='''        for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);'''
copy_new='''        for (std::size_t column=0;column<n;column+=8) {
            const auto end_column=std::min(column+8,n);
            for (std::size_t row=column;row<n;row+=8) {
                const auto end_row=std::min(row+8,n);
                for (std::size_t j=column;j<end_column;++j)
                    for (std::size_t i=std::max(row,j);i<end_row;++i) working(i,j)=input(i,j);
            }
        }'''
factor_anchor='''    if constexpr (detail::row_simd_available) {
        if (storage.col_stride()==1 && n>=9)'''
factor_tiny='''    if (n==2) {
        const auto first=input(0,0);
        if (first<=0) return Status{StatusCode::non_positive_pivot,0};
        storage(0,0)=std::sqrt(first);
        const auto lower=input(1,0)/storage(0,0);
        if (!detail::llt_is_finite(lower)) return Status{StatusCode::arithmetic_failure,0};
        storage(1,0)=lower;
        const auto second=input(1,1)-lower*lower;
        if (!detail::llt_is_finite(second)) return Status{StatusCode::arithmetic_failure,1};
        if (second<=0) return Status{StatusCode::non_positive_pivot,1};
        storage(1,1)=std::sqrt(second);storage(0,1)=0;
        return detail::LltAccess::create(storage);
    }
'''
solve_anchor='''    auto lower=factor.lower();
'''
solve_tiny='''    if (n==2) {
        double first=rhs[0]/lower(0,0);
        if (!detail::llt_is_finite(first)) return {StatusCode::arithmetic_failure,0};
        double second=(rhs[1]-lower(1,0)*first)/lower(1,1);
        if (!detail::llt_is_finite(second)) return {StatusCode::arithmetic_failure,1};
        second/=lower(1,1);
        if (!detail::llt_is_finite(second)) return {StatusCode::arithmetic_failure,1};
        first=(first-lower(1,0)*second)/lower(0,0);
        if (!detail::llt_is_finite(first)) return {StatusCode::arithmetic_failure,0};
        output[0]=first;output[1]=second;return {};
    }
'''
assert copy_old in base and factor_anchor in base and solve_anchor in base
variants={'copy_tile8':base.replace(copy_old,copy_new,1),
          'tiny_factor':base.replace(factor_anchor,factor_tiny+factor_anchor,1),
          'tiny_solve':base.replace(solve_anchor,solve_anchor+solve_tiny,1)}
variants['tiny_both']=variants['tiny_factor'].replace(solve_anchor,solve_anchor+solve_tiny,1)
p=root/'.scratch/large-llt-next/CMakeLists.txt';cm=p.read_text()
for name,code in variants.items():
    dest=root/f'.scratch/large-llt-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    (dest/'llt.hpp').write_text(code)
    targets=[(name,'full-adaptive.cpp')]
    if name.startswith('tiny_'):targets.append((name+'_uninitialized','uninitialized-setup.cpp'))
    for target,source in targets:
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} {source})
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
p.write_text(cm)
print('prepared lower-copy tile and independent tiny factor/solve controls; no public change')
