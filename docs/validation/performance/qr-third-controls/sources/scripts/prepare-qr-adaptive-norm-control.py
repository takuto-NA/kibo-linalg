from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/qr.hpp').read_text()
anchor='''    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();'''
probe='''    const auto count=matrix.rows()-first;
    if (count>=16) {
        double squared=0;
        for (std::size_t i=first;i<matrix.rows();++i) {const auto value=matrix(i,column);squared+=value*value;}
        // The fallback also covers positive subnormal sums where lost terms
        // could matter. No reciprocal scaling is used on the ordinary path.
        const auto safe_min=std::numeric_limits<double>::min()*static_cast<double>(count)/std::numeric_limits<double>::epsilon();
        if (squared>=safe_min && std::isfinite(squared)) return std::sqrt(squared);
    }
'''+anchor
assert anchor in base
name='adaptive_norm';dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
(dest/'qr.hpp').write_text(base.replace(anchor,probe,1))
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
print('prepared private one-pass ordinary norm with scaled fallback; no public change')
