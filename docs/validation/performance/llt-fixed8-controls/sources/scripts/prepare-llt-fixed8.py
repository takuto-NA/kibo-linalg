from pathlib import Path
import shutil
root=Path.cwd();folder=root/'.scratch/large-llt-next/variants/fixed8'
shutil.copytree(root/'include/kibo',folder/'kibo',dirs_exist_ok=True)
p=folder/'kibo/llt.hpp';s=p.read_text();pos=s.index('#if defined(_MSC_VER)\n__forceinline')
s=s[:pos]+'template<std::size_t FixedWidth=0>\n'+s[pos:]
start=s.index('void update_column_pair(');end=s.index('\n\n\ninline bool divide_contiguous_checked',start)
part=s[start:end].replace('    std::size_t i=0;','    const auto active_width=FixedWidth?FixedWidth:width;\n    std::size_t i=0;').replace('k<width','k<active_width')
s=s[:start]+part+s[end:]
old='''                    update_column_pair(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                       working.col_stride(),&working(j,first),end-first,n-j-1);'''
new='''                    if(end-first==8)
                        update_column_pair<8>(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                              working.col_stride(),&working(j,first),8,n-j-1);
                    else
                        update_column_pair<>(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                             working.col_stride(),&working(j,first),end-first,n-j-1);'''
assert old in s;s=s.replace(old,new);p.write_text(s)
p=root/'.scratch/large-llt-next/CMakeLists.txt';s=p.read_text()
if 'add_executable(fixed8 ' not in s:
    s+='''
add_executable(fixed8 full-adaptive.cpp)
target_compile_features(fixed8 PRIVATE cxx_std_20)
target_include_directories(fixed8 PRIVATE variants/fixed8 ../../tests ../../.cache/eigen)
target_compile_definitions(fixed8 PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options(fixed8 PRIVATE /O2 /fp:precise /FAs "/Fa${CMAKE_CURRENT_BINARY_DIR}/fixed8.asm")
'''
p.write_text(s)
print('constant width 8 probe prepared; public source unchanged')
