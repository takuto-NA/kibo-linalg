from pathlib import Path
import shutil

root=Path.cwd();base=(root/'.scratch/qr-next/variants/combo_certified_norm/kibo/qr.hpp').read_text()
helper='''// Convert q contiguous n-by-n column blocks to caller row order.
// The first n workspace doubles hold one block. The second n doubles provide
// q*n visited bits for q<=64. No input padding is used or modified.
inline void qr_restore_row_blocks(double* packed,std::size_t m,std::size_t n,
                                  std::span<double> workspace) noexcept {
    const auto blocks=m,quotient=m/n;
    auto* marks=reinterpret_cast<unsigned char*>(workspace.data()+n);
    const auto bytes=blocks/8+(blocks%8!=0);
    std::fill_n(marks,bytes,static_cast<unsigned char>(0));
    for(std::size_t start=0;start<blocks;++start) {
        if((marks[start/8]&(1U<<(start%8)))!=0)continue;
        for(std::size_t i=0;i<n;++i)workspace[i]=packed[start*n+i];
        auto current=start;
        do {
            const auto next=(current%quotient)*n+current/quotient;
            for(std::size_t i=0;i<n;++i)std::swap(workspace[i],packed[next*n+i]);
            marks[current/8]|=static_cast<unsigned char>(1U<<(current%8));
            current=next;
        }while(current!=start);
    }
    // Transpose every square block with small tiles so both sides stay local.
    for(std::size_t b=0;b<quotient;++b) {
        auto* square=packed+b*n*n;
        for(std::size_t first=0;first<n;) {
            const auto end=first+std::min(std::size_t{8},n-first);
            for(std::size_t column=0;column<first;column+=8) {
                const auto stop=std::min(column+8,first);
                for(std::size_t j=column;j<stop;++j)for(std::size_t i=first;i<end;++i)
                    std::swap(square[i*n+j],square[j*n+i]);
            }
            for(std::size_t i=first;i<end;++i)for(std::size_t j=first;j<i;++j)
                std::swap(square[i*n+j],square[j*n+i]);
            first=end;
        }
    }
}
'''
anchor='''    if (!detail::qr_input_finite(input)) return StatusCode::non_finite_input;'''
assert anchor in base
dispatch='''    if(n>=QR_WORK_THRESHOLD && packed.col_stride()==1 && packed.row_stride()==n && m%n==0 && m/n<=64) {
        auto working=MatrixView<double>::checked(std::span<double>{&packed(0,0),m*n},m,n,1,m).value();
        auto result=factorize_qr(input,working,tau,permutation,workspace,options,diagnostics);
        if(!result)return result.status();
        detail::qr_restore_row_blocks(&packed(0,0),m,n,prepared.value());
        return detail::QrAccess::create(packed,tau.first(n),permutation.first(n),result.value().diagnostics());
    }
'''+anchor
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for threshold in [8,32]:
    name=f'column_work_{threshold}'
    code=base.replace('struct QrAccess {',helper+'\nstruct QrAccess {',1).replace(anchor,dispatch.replace('QR_WORK_THRESHOLD',str(threshold)),1)
    dest=root/f'.scratch/qr-next/variants/{name}/kibo'
    shutil.copytree(root/'.scratch/qr-next/variants/combo_certified_norm/kibo',dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code)
    target=name+'_row_best'
    if f'add_executable({target} ' not in cm:
        cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
cm_path.write_text(cm)
print('prepared internal column-work controls with caller row restoration in existing 2n workspace')
