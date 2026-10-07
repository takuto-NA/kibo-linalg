from pathlib import Path
import subprocess
root=Path.cwd();commit='2f23d66af38fe4aed42811cdf6438af73de620c5'
folder=root/'.scratch/large-llt-next/variants/before_store'
for name in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include/kibo'],text=True).splitlines():
    dest=folder/Path(name).relative_to('include');dest.parent.mkdir(parents=True,exist_ok=True)
    dest.write_bytes(subprocess.check_output(['git','show',f'{commit}:{name}']))
p=root/'.scratch/large-llt-next/CMakeLists.txt';s=p.read_text()
if 'add_executable(before_store ' not in s:
    s+='''
add_executable(before_store full-adaptive.cpp)
target_compile_features(before_store PRIVATE cxx_std_20)
target_include_directories(before_store PRIVATE variants/before_store ../../tests ../../.cache/eigen)
target_compile_definitions(before_store PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options(before_store PRIVATE /O2 /fp:precise /FAs "/Fa${CMAKE_CURRENT_BINARY_DIR}/before_store.asm")
'''
p.write_text(s)
print('baseline snapshot',commit,'prepared')
