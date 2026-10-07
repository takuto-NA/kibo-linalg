from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/qr.hpp').read_text()
point='''inline bool qr_is_finite(double value) noexcept {
    return std::abs(value)<=std::numeric_limits<double>::max();
}
'''
packet='''inline bool qr_input_finite(MatrixView<const double> input) noexcept {
    const auto check=[](const double* values,std::size_t count) noexcept {
        std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
        auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
        for(;count-i>=2;i+=2) {
            const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));
            valid=_mm_and_pd(valid,_mm_cmple_pd(absolute,limit));
        }
        if(_mm_movemask_pd(valid)!=3)return false;
#endif
        for(;i<count;++i)if(!(std::abs(values[i])<=std::numeric_limits<double>::max()))return false;
        return true;
    };
    if(input.col_stride()==1) {
        for(std::size_t i=0;i<input.rows();++i)if(!check(&input(i,0),input.cols()))return false;
        return true;
    }
    if(input.row_stride()==1) {
        for(std::size_t j=0;j<input.cols();++j)if(!check(&input(0,j),input.rows()))return false;
        return true;
    }
    return finite(input);
}
'''
variants={'point_finite':base.replace('namespace detail {\n','namespace detail {\n'+point,1).replace('std::isfinite(','detail::qr_is_finite('),
          'packet_input':base.replace('namespace detail {\n','namespace detail {\n'+packet,1).replace('if (!detail::finite(input))','if (!detail::qr_input_finite(input))',1)}
variants['both_finite']=variants['point_finite'].replace('namespace detail {\n','namespace detail {\n'+packet,1).replace('if (!detail::finite(input))','if (!detail::qr_input_finite(input))',1)
p=root/'.scratch/qr-next/CMakeLists.txt';cm=p.read_text()
for name,code in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True);(dest/'qr.hpp').write_text(code)
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
print('prepared individual finite-check controls; no public change')
