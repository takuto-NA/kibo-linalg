from pathlib import Path
import shutil

root=Path.cwd();cm_path=root/'.scratch/qr-next/CMakeLists.txt';cm=cm_path.read_text()
base=(root/'include/kibo/qr.hpp').read_text();kernels=(root/'include/kibo/detail/row_kernels.hpp').read_text()
def column_norm(code):
    start=code.index('inline double column_norm(');end=code.index('\n}\n',start)+3
    return code[start:end]
norm=column_norm((root/'.scratch/qr-next/variants/adaptive_norm/kibo/qr.hpp').read_text())
vector_norm=norm.replace('''        for (std::size_t i=first;i<matrix.rows();++i) {const auto value=matrix(i,column);squared+=value*value;}''','''        std::size_t i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        if(matrix.row_stride()==1) {
            auto a=_mm_setzero_pd(),b=a;
            for(;matrix.rows()-i>=4;i+=4) {
                const auto x=_mm_loadu_pd(&matrix(i,column)),y=_mm_loadu_pd(&matrix(i+2,column));
                a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
            }
            const auto sum=_mm_add_pd(a,b);
            squared=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
        }
#endif
        for (;i<matrix.rows();++i) {const double value=matrix(i,column);squared+=value*value;}''')
assert vector_norm!=norm
certified_norm='''inline double column_norm(MatrixView<const double> matrix, std::size_t first, std::size_t column) noexcept {
    const auto count=matrix.rows()-first;
    if(count>=16) {
        double maximum=0;std::size_t i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
        if(matrix.row_stride()==1) {
            const auto sign=_mm_set1_pd(-0.0);auto a=_mm_setzero_pd(),b=a;
            for(;matrix.rows()-i>=4;i+=4) {
                a=_mm_max_pd(a,_mm_andnot_pd(sign,_mm_loadu_pd(&matrix(i,column))));
                b=_mm_max_pd(b,_mm_andnot_pd(sign,_mm_loadu_pd(&matrix(i+2,column))));
            }
            const auto largest=_mm_max_pd(a,b);
            maximum=std::max(_mm_cvtsd_f64(largest),_mm_cvtsd_f64(_mm_unpackhi_pd(largest,largest)));
        }
#endif
        for(;i<matrix.rows();++i)maximum=std::max(maximum,std::abs(matrix(i,column)));
        const double upper=.5*std::sqrt(std::numeric_limits<double>::max()/static_cast<double>(count));
        const double lower=std::sqrt(std::numeric_limits<double>::min()*static_cast<double>(count)/std::numeric_limits<double>::epsilon());
        if(maximum>=lower && maximum<=upper) {
            double squared=0;i=first;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
            if(matrix.row_stride()==1) {
                auto a=_mm_setzero_pd(),b=a;
                for(;matrix.rows()-i>=4;i+=4) {
                    const auto x=_mm_loadu_pd(&matrix(i,column)),y=_mm_loadu_pd(&matrix(i+2,column));
                    a=_mm_add_pd(a,_mm_mul_pd(x,x));b=_mm_add_pd(b,_mm_mul_pd(y,y));
                }
                const auto sum=_mm_add_pd(a,b);
                squared=_mm_cvtsd_f64(sum)+_mm_cvtsd_f64(_mm_unpackhi_pd(sum,sum));
            }
#endif
            for(;i<matrix.rows();++i){const double value=matrix(i,column);squared+=value*value;}
            return std::sqrt(squared);
        }
    }
    ScaledSquares<double> sum;
    for (std::size_t i=first;i<matrix.rows();++i) sum.add(matrix(i,column));
    return sum.norm();
}
'''
both=(root/'.scratch/qr-next/variants/both_finite/kibo/qr.hpp').read_text()
row=(root/'.scratch/qr-next/variants/both_four_4/kibo/qr.hpp').read_text()
recip=(root/'.scratch/qr-next/variants/householder_recip/kibo/qr.hpp').read_text()
start=recip.index('        if (std::abs(alpha)<=');end=recip.index('\n        packed(k,k)=beta;',start)
old_scale='        for (std::size_t i=k+1;i<m;++i) packed(i,k)=(packed(i,k)/beta)/(ratio-1);'
combo=both.replace(column_norm(both),norm).replace(old_scale,recip[start:end])
# A normal reciprocal is required before replacing per-value division.
# The diagnostic reciprocal's largest-denominator case is not adopted here.
combo=combo.replace('if (std::abs(denominator)>=std::numeric_limits<double>::min()) {',
                    'if (std::abs(denominator)>=std::numeric_limits<double>::min() && std::abs(denominator)<=1/std::numeric_limits<double>::min()) {')
# Carry only the four-row projection threshold and four-row update callsite.
combo=combo.replace('if (packed.col_stride()==1 && count>=16) {','if (packed.col_stride()==1 && count>=4) {',1)
old_start=base.index('            for (std::size_t i=k+1;i<m;++i) {\n                const double value=packed(i,k);')
old_end=base.index('\n        } else {',old_start)
new_start=row.index('            std::size_t update_row=')
new_end=row.index('\n        } else {',new_start)
old_update=base[old_start:old_end].replace('std::isfinite(','detail::qr_is_finite(')
assert old_update in combo
combo=combo.replace(old_update,row[new_start:new_end])
strided=(root/'.scratch/qr-next/variants/strided_both/kibo/qr.hpp').read_text()
helper_start=strided.index('inline bool qr_strided_update_checked(');helper_end=strided.index('struct QrAccess {',helper_start)
combo=combo.replace('struct QrAccess {',strided[helper_start:helper_end]+'struct QrAccess {',1)
stride_solve=strided.index('inline Status solve_into(')
combo=combo[:combo.index('inline Status solve_into(')]+strided[stride_solve:]
combo=combo.replace('std::isfinite(','detail::qr_is_finite(')
combined_kernels=(root/'.scratch/qr-next/variants/exponent_check/kibo/detail/row_kernels.hpp').read_text()
row_kernels=(root/'.scratch/qr-next/variants/both_four_4/kibo/detail/row_kernels.hpp').read_text()
start=row_kernels.index('inline bool row_update_four_checked(');end=row_kernels.index('inline bool row_update_checked(',start)
combined_kernels=combined_kernels.replace('inline bool row_update_checked(',row_kernels[start:end]+'inline bool row_update_checked(',1)
force_prefix='''#if defined(_MSC_VER)
#define KIBO_QR_PROBE_INLINE __forceinline
#else
#define KIBO_QR_PROBE_INLINE inline
#endif
'''
def force_projection(code):
    code=code.replace('namespace kibo::linalg::detail {',force_prefix+'\nnamespace kibo::linalg::detail {',1)
    for name in ['row_project_four_rows','column_project_four']:
        code=code.replace('inline void '+name+'(', 'KIBO_QR_PROBE_INLINE void '+name+'(')
    return code+'\n#undef KIBO_QR_PROBE_INLINE\n'
variants={'adaptive_vector':(base.replace(column_norm(base),vector_norm),kernels),
          'certified_norm':(base.replace(column_norm(base),certified_norm),kernels),
          'force_project':(base,force_projection(kernels)),
          'combo_scalar_norm':(combo,combined_kernels),
          'combo_vector_norm':(combo.replace(column_norm(combo),vector_norm.replace('std::isfinite(','detail::qr_is_finite(')),combined_kernels)}
variants['combo_certified_norm']=(combo.replace(column_norm(combo),certified_norm),combined_kernels)
variants['combo_force_project']=(variants['combo_vector_norm'][0],force_projection(combined_kernels))
for name,(code,helpers) in variants.items():
    dest=root/f'.scratch/qr-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    (dest/'qr.hpp').write_text(code);(dest/'detail/row_kernels.hpp').write_text(helpers)
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
print('prepared independent vector norm/forced projection and combined controls; private only')
