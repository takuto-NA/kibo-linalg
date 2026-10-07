from pathlib import Path
path=Path('.scratch/qr-candidate-contracts/CMakeLists.txt')
code=path.read_text()
old='combo_scalar_norm combo_vector_norm combo_force_project combo_certified_norm'
new='combo_flat_input combo_row_initial combo_flat_row_initial column_work_8 column_work_32'
assert old in code
code=code.replace(old,new)
code+='''
add_executable(qr_restore_check ../qr-restore-check.cpp)
target_compile_features(qr_restore_check PRIVATE cxx_std_20)
target_include_directories(qr_restore_check PRIVATE ../qr-next/variants/column_work_8)
'''
Path('.scratch/qr-layout-contracts').mkdir(exist_ok=True)
Path('.scratch/qr-layout-contracts/CMakeLists.txt').write_text(code)
check=Path('.scratch/check-qr-combined-contracts.py').read_text()
check=check.replace('qr-combined-validation','qr-layout-validation').replace('qr-candidate-contracts','qr-layout-contracts')
check=check.replace("['combo_scalar_norm','combo_vector_norm','combo_certified_norm','combo_force_project']", "['combo_flat_input','combo_row_initial','combo_flat_row_initial','column_work_8','column_work_32']")
Path('.scratch/check-qr-layout-contracts.py').write_text(check)
print('five private variants,20 SIMD/scalar contract suites,510 oracle cases')
