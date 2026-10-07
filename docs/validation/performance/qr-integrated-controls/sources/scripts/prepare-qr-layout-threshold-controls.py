from pathlib import Path
import shutil

root=Path.cwd(); base=(root/'include/kibo/qr.hpp').read_text()
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
harness=(root/'.scratch/qr-next/full-adaptive.cpp').read_text()
pad=harness.replace('std::vector<double> storage(rows*n)', 'std::vector<double> storage(rows*(n+QR_PADDING))')
pad=pad.replace('const std::size_t rs=n,cs=1;', 'const std::size_t rs=n+QR_PADDING,cs=1;')
pad=pad.replace('std::vector<double> packed(rows*n)', 'std::vector<double> packed(rows*(n+QR_PADDING))')
pad=pad.replace('+12*n*sizeof(std::size_t);', '+12*n*sizeof(std::size_t)+2*rows*QR_PADDING*sizeof(double);')
assert pad!=harness
(root/'.scratch/qr-next/padded-adaptive.cpp').write_text(pad)
for amount in [1,8,16]:
    name=f'padded_{amount}_row_best'
    if f'add_executable({name} ' not in cm:
        cm+=f'''
add_executable({name} padded-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE ../../include ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1 QR_PADDING={amount})
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
row4=(root/'.scratch/qr-next/variants/row_update_four/kibo/qr.hpp').read_text()
old='if (packed.col_stride()==1 && count>=16) {'
assert base.count(old)==1 and row4.count(old)==2
update_start=row4.index('std::size_t update_row')
variants={'project_four_4':base.replace(old,old.replace('16','4')),
          'update_four_4':row4[:update_start]+row4[update_start:].replace(old,old.replace('16','4'),1),
          'both_four_4':row4.replace(old,old.replace('16','4'))}
old_scale='''        for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);'''
assert old_scale in base
for name,expression in [('householder_divide','packed(i,k)/denominator'),('householder_recip','packed(i,k)*inverse')]:
    declaration='const double inverse=1/denominator;' if name.endswith('recip') else ''
    new=f'''        if (std::abs(alpha)<=std::numeric_limits<double>::max()-std::abs(beta)) {{
            const double denominator=alpha-beta;
            if (std::abs(denominator)>=std::numeric_limits<double>::min()) {{
                {declaration}
                for (std::size_t i=k+1;i<m;++i) packed(i,k)={expression};
            }} else {{
                for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
            }}
        }} else {{
            for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);
        }}'''
    variants[name]=base.replace(old_scale,new,1)
for name,code in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo'
    shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    if name in ['update_four_4','both_four_4']:
        shutil.copyfile(root/'.scratch/qr-next/variants/row_update_four/kibo/detail/row_kernels.hpp',dest/'detail/row_kernels.hpp')
    (dest/'qr.hpp').write_text(code)
    layouts=['row_best'] if 'four' in name else ['column','row_best']
    for layout in layouts:
        target=f'{name}_{layout}';defs='QR_COLUMN=1' if layout=='column' else ''
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
cm_path.write_text(cm)
print('prepared stride-only, four-row threshold, and guarded Householder scaling controls')
