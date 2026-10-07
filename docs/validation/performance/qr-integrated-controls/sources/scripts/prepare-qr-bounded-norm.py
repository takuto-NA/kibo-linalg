from pathlib import Path
import shutil
root=Path.cwd();source=root/'.scratch/qr-next/variants/column_work_packet/kibo'
base=(source/'qr.hpp').read_text();start=base.index('inline double column_norm(');end=base.index('\n}\n',start)+3
norm='''inline double column_norm(MatrixView<const double> matrix, std::size_t first, std::size_t column) noexcept {
    const auto count=matrix.rows()-first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    if(count>=16 && matrix.row_stride()==1) {
        // Check the packet exponent BEFORE squaring. The quarter margin and
        // discarded mantissa keep the whole sum below one quarter of DBL_MAX.
        const double upper=.25*std::sqrt(std::numeric_limits<double>::max()/static_cast<double>(count));
        constexpr std::uint64_t exponent_bits=0x7ff0000000000000ULL;
        const auto mask=_mm_castsi128_pd(_mm_set1_epi64x(static_cast<long long>(exponent_bits)));
        const auto limit=_mm_set1_pd(std::bit_cast<double>(std::bit_cast<std::uint64_t>(upper)&exponent_bits));
        auto a=_mm_setzero_pd(),b=a;std::size_t i=first;bool safe=true;
        for(;matrix.rows()-i>=4;i+=4) {
            const auto x=_mm_loadu_pd(&matrix(i,column)),y=_mm_loadu_pd(&matrix(i+2,column));
            const auto exponent=_mm_and_pd(_mm_or_pd(x,y),mask);
            if(_mm_movemask_pd(_mm_cmple_pd(exponent,limit))!=3){safe=false;break;}
            a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
        }
        if(safe) {
            const auto sum=_mm_add_pd(a,b);double squared=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
            for(;i<matrix.rows();++i) {
                const double value=matrix(i,column);
                if(!(std::abs(value)<=upper)){safe=false;break;}
                squared+=value*value;
            }
            if(safe && squared>=std::numeric_limits<double>::min()*static_cast<double>(count)/std::numeric_limits<double>::epsilon())
                return std::sqrt(squared);
        }
    }
#endif
    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i)sum.add(matrix(i,column));
    return sum.norm();
}
'''
bounded=base[:start]+norm+base[end:]
bounded=bounded.replace('#include <algorithm>','#include <algorithm>\n#include <bit>',1)
old='''        for(std::size_t r=first;r<m;++r) {
            for(std::size_t j=0;j<4 && first+j<=r;++j)
                transformed[r]-=(r==first+j?1:packed(r,first+j))*projections[j];
            if(!qr_is_finite(transformed[r]))return false;
        }'''
new='''        for(std::size_t r=first;r<first+4;++r) {
            double value=transformed[r];
            for(std::size_t j=0;first+j<=r;++j)value-=(r==first+j?1:packed(r,first+j))*projections[j];
            if(!qr_is_finite(value))return false;
            transformed[r]=value;
        }
        for(std::size_t r=first+4;r<m;++r) {
            double value=transformed[r];
            value-=packed(r,first)*p0;value-=packed(r,first+1)*p1;
            value-=packed(r,first+2)*p2;value-=packed(r,first+3)*p3;
            if(!qr_is_finite(value))return false;
            transformed[r]=value;
        }'''
assert old in base
variants={'column_work_packet_local':base.replace(old,new,1),'column_work_bounded':bounded.replace(old,new,1)}
cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
for name,code in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(source,dest,dirs_exist_ok=True);(dest/'qr.hpp').write_text(code)
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
print('bounded one-pass SIMD norm and local four-term panel update prepared')
