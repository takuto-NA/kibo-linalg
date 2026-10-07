from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/qr.hpp').read_text();kernel=(root/'include/kibo/detail/row_kernels.hpp').read_text()
norm_old='''    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();'''
norm_new='''    const auto count=matrix.rows()-first;
    if (count>=16 && (ALL_STRIDES || matrix.row_stride()==1)) {
        double maximum=0;
        for (std::size_t i=first;i<matrix.rows();++i) maximum=std::max(maximum,std::abs(matrix(i,column)));
        if (maximum==0 || !std::isfinite(maximum)) return maximum;
        double total=0;std::size_t i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        if (matrix.row_stride()==1) {
            const auto scale=_mm_set1_pd(maximum);auto sum0=_mm_setzero_pd(),sum1=sum0;
            for (;matrix.rows()-i>=4;i+=4) {
                const auto a=_mm_div_pd(_mm_loadu_pd(&matrix(i,column)),scale);
                const auto b=_mm_div_pd(_mm_loadu_pd(&matrix(i+2,column)),scale);
                sum0=_mm_add_pd(sum0,_mm_mul_pd(a,a));sum1=_mm_add_pd(sum1,_mm_mul_pd(b,b));
            }
            const auto sum=_mm_add_pd(sum0,sum1);
            total=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
        }
#endif
        for (;i<matrix.rows();++i) {const auto value=matrix(i,column)/maximum;total+=value*value;}
        return maximum*std::sqrt(total);
    }
'''+norm_old
row_helper='''inline bool row_update_four_checked(double* rows,std::size_t stride,const double* projection,
                                     const double* coefficients,std::size_t count) noexcept {
    std::size_t j=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto a=_mm_set1_pd(coefficients[0]),b=_mm_set1_pd(coefficients[stride]);
    const auto c=_mm_set1_pd(coefficients[2*stride]),d=_mm_set1_pd(coefficients[3*stride]);
    const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto va=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd()),vb=va,vc=va,vd=va;
    for (;count-j>=2;j+=2) {
        const auto p=_mm_loadu_pd(projection+j);
        const auto x0=_mm_sub_pd(_mm_loadu_pd(rows+j),_mm_mul_pd(a,p));
        const auto x1=_mm_sub_pd(_mm_loadu_pd(rows+stride+j),_mm_mul_pd(b,p));
        const auto x2=_mm_sub_pd(_mm_loadu_pd(rows+2*stride+j),_mm_mul_pd(c,p));
        const auto x3=_mm_sub_pd(_mm_loadu_pd(rows+3*stride+j),_mm_mul_pd(d,p));
        _mm_storeu_pd(rows+j,x0);_mm_storeu_pd(rows+stride+j,x1);
        _mm_storeu_pd(rows+2*stride+j,x2);_mm_storeu_pd(rows+3*stride+j,x3);
        va=_mm_and_pd(va,_mm_cmple_pd(_mm_andnot_pd(sign,x0),limit));
        vb=_mm_and_pd(vb,_mm_cmple_pd(_mm_andnot_pd(sign,x1),limit));
        vc=_mm_and_pd(vc,_mm_cmple_pd(_mm_andnot_pd(sign,x2),limit));
        vd=_mm_and_pd(vd,_mm_cmple_pd(_mm_andnot_pd(sign,x3),limit));
    }
    if (_mm_movemask_pd(_mm_and_pd(_mm_and_pd(va,vb),_mm_and_pd(vc,vd)))!=3) return false;
#endif
    for (;j<count;++j) for (std::size_t r=0;r<4;++r) {
        rows[r*stride+j]-=coefficients[r*stride]*projection[j];
        if (!std::isfinite(rows[r*stride+j])) return false;
    }
    return true;
}
'''
row_old='''            for (std::size_t i=k+1;i<m;++i) {
                const double value=packed(i,k);'''
row_new='''            std::size_t update_row=k+1;
            if (packed.col_stride()==1 && count>=16) {
                for (;m-update_row>=4;update_row+=4)
                    if (!detail::row_update_four_checked(&packed(update_row,first),packed.row_stride(),tau.data()+first,&packed(update_row,k),count))
                        return Status{StatusCode::arithmetic_failure,k};
            }
            for (std::size_t i=update_row;i<m;++i) {
                const double value=packed(i,k);'''
assert norm_old in base and row_old in base
variants={'norm_column':(base.replace(norm_old,norm_new.replace('ALL_STRIDES','false'),1),kernel),
          'norm_all':(base.replace(norm_old,norm_new.replace('ALL_STRIDES','true'),1),kernel),
          'row_update_four':(base.replace(row_old,row_new,1),kernel.replace('inline bool row_update_checked(',row_helper+'\ninline bool row_update_checked(',1))}
p=root/'.scratch/qr-next/CMakeLists.txt';cm=p.read_text()
for name,(code,kernels) in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code);(dest/'detail/row_kernels.hpp').write_text(kernels)
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
print('prepared independent scale-first norm and four-row update controls; no public QR change')
