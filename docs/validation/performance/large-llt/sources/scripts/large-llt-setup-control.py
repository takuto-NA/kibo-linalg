from pathlib import Path
p=Path('.scratch/large-llt-next/full-adaptive.cpp');base=p.read_text()
old='std::vector<double> packed(n*n),work(n),answer(n);'
new='''std::vector<double> arena(n*n+n),answer(n);
      auto packed=std::span<double>(arena).first(n*n),work=std::span<double>(arena).subspan(n*n);'''
assert old in base
Path('.scratch/large-llt-next/packed-setup.cpp').write_text(base.replace(old,new))
p=Path('.scratch/large-llt-next/CMakeLists.txt');text=p.read_text()
if 'add_executable(packed_setup ' not in text:
    text+='''
add_executable(packed_setup packed-setup.cpp)
target_compile_features(packed_setup PRIVATE cxx_std_20)
target_include_directories(packed_setup PRIVATE ../../include ../../tests ../../.cache/eigen)
target_compile_definitions(packed_setup PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options(packed_setup PRIVATE /O2 /fp:precise /FAs "/Fa${CMAKE_CURRENT_BINARY_DIR}/packed_setup.asm")
'''
p.write_text(text)
print('prepared setup-only allocation control: factor/work in one owner, output separate')
