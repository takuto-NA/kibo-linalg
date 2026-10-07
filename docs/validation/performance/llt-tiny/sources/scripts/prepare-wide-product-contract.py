from pathlib import Path
p=Path('.scratch/large-llt-next/CMakeLists.txt');s=p.read_text()
if 'add_executable(view_wide_product_contract ' not in s:
    s+='''
add_executable(view_wide_product_contract ../../tests/matrix_view_tests.cpp)
target_compile_features(view_wide_product_contract PRIVATE cxx_std_20)
target_include_directories(view_wide_product_contract PRIVATE variants/view_wide_product)
target_compile_options(view_wide_product_contract PRIVATE /W4 /permissive-)
'''
p.write_text(s)
