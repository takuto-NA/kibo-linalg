from pathlib import Path
import shutil

root=Path.cwd();base=(root/'.scratch/qr-next/variants/combo_certified_norm/kibo/qr.hpp').read_text()
helper='''// Private width8 initial-norm scan; each lane sums rows in increasing order.
inline void qr_initial_norms(MatrixView<const double> packed,std::span<double> norms) noexcept {
    const auto m=packed.rows(),n=packed.cols();std::size_t j=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    if(packed.col_stride()==1 && m>=16) {
        const auto sign=_mm_set1_pd(-0.0);
        const auto upper=_mm_set1_pd(.5*std::sqrt(std::numeric_limits<double>::max()/static_cast<double>(m)));
        const auto lower=_mm_set1_pd(std::sqrt(std::numeric_limits<double>::min()*static_cast<double>(m)/std::numeric_limits<double>::epsilon()));
        for(;n-j>=8;j+=8) {
            auto a=_mm_setzero_pd(),b=a,c=a,d=a;
            for(std::size_t i=0;i<m;++i) {
                const auto* row=&packed(i,j);
                a=_mm_max_pd(a,_mm_andnot_pd(sign,_mm_loadu_pd(row)));
                b=_mm_max_pd(b,_mm_andnot_pd(sign,_mm_loadu_pd(row+2)));
                c=_mm_max_pd(c,_mm_andnot_pd(sign,_mm_loadu_pd(row+4)));
                d=_mm_max_pd(d,_mm_andnot_pd(sign,_mm_loadu_pd(row+6)));
            }
            const auto minimum=_mm_min_pd(_mm_min_pd(a,b),_mm_min_pd(c,d));
            const auto maximum=_mm_max_pd(_mm_max_pd(a,b),_mm_max_pd(c,d));
            if(_mm_movemask_pd(_mm_and_pd(_mm_cmpge_pd(minimum,lower),_mm_cmple_pd(maximum,upper)))==3) {
                a=b=c=d=_mm_setzero_pd();
                for(std::size_t i=0;i<m;++i) {
                    const auto* row=&packed(i,j);
                    const auto x=_mm_loadu_pd(row),y=_mm_loadu_pd(row+2),z=_mm_loadu_pd(row+4),w=_mm_loadu_pd(row+6);
                    a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
                    c=_mm_add_pd(c,_mm_mul_pd(z,z));d=_mm_add_pd(d,_mm_mul_pd(w,w));
                }
                _mm_storeu_pd(norms.data()+j,_mm_sqrt_pd(a));_mm_storeu_pd(norms.data()+j+2,_mm_sqrt_pd(b));
                _mm_storeu_pd(norms.data()+j+4,_mm_sqrt_pd(c));_mm_storeu_pd(norms.data()+j+6,_mm_sqrt_pd(d));
            } else for(std::size_t k=0;k<8;++k)norms[j+k]=column_norm(packed,0,j+k);
        }
    }
#endif
    for(;j<n;++j)norms[j]=column_norm(packed,0,j);
}
'''
old='''        initial_norms[j]=detail::column_norm(packed,0,j);'''
assert old in base
row=base.replace('\n}\n\ninline Result<QrFactorRequirement>',helper+'\n}\n\ninline Result<QrFactorRequirement>',1)
row=row.replace('    for (std::size_t j=0;j<n;++j) {\n        permutation[j]=j;','    detail::qr_initial_norms(packed,initial_norms);\n    for (std::size_t j=0;j<n;++j) {\n        permutation[j]=j;',1).replace(old,'',1)
assert 'inline void qr_initial_norms(' in row
flat='''    if((input.col_stride()==1 && input.row_stride()==input.cols()) ||
       (input.row_stride()==1 && input.col_stride()==input.rows()))
        return check(&input(0,0),input.rows()*input.cols());
'''
def flatten(code):
    anchor='    if(input.col_stride()==1) {'
    assert anchor in code
    return code.replace(anchor,flat+anchor,1)
variants={'combo_flat_input':flatten(base),'combo_row_initial':row,'combo_flat_row_initial':flatten(row)}
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for name,code in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo'
    shutil.copytree(root/'.scratch/qr-next/variants/combo_certified_norm/kibo',dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code)
    for layout,defs in [('column','QR_COLUMN=1'),('row_best','')]:
        target=f'{name}_{layout}'
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} full-adaptive.cpp)
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
cm_path.write_text(cm)
print('prepared independent flat input scan and certified width8 row initial norms')
