from pathlib import Path
import hashlib,json,shutil

root=Path.cwd();out=root/'.scratch/large-llt-next/variants'
base=(root/'include/kibo/llt.hpp').read_text()
assert hashlib.sha256((root/'include/kibo/llt.hpp').read_bytes()).hexdigest(), 'fixed public source required'
start=base.index('    double scale=0;\n',base.index('inline Result<LltFactorView> factorize_llt('))
stop=base.index('    if constexpr (detail::row_simd_available)',start)
sym=base.index('    if (options.check_symmetry) {\n        const bool tiled',start)
helper=r'''
inline bool finite_exact_symmetric(MatrixView<const double> input,double& scale,bool& exact) noexcept {
    const auto n=input.rows();std::size_t i=0;
    exact=true;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
    auto max0=_mm_setzero_pd(),max1=max0,max2=max0,max3=max0;
    auto valid0=_mm_cmpeq_pd(max0,max0),valid1=valid0,valid2=valid0,valid3=valid0,equal=valid0;
    for(;n-i>=2;i+=2) {
        const auto da=_mm_andnot_pd(sign,_mm_loadu_pd(&input(i,i)));
        const auto db=_mm_andnot_pd(sign,_mm_loadu_pd(&input(i+1,i)));
        max0=_mm_max_pd(max0,da);valid0=_mm_and_pd(valid0,_mm_cmple_pd(da,limit));
        max1=_mm_max_pd(max1,db);valid1=_mm_and_pd(valid1,_mm_cmple_pd(db,limit));
        exact&=input(i,i+1)==input(i+1,i);
        for(std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&input(i,j)),b=_mm_loadu_pd(&input(i+1,j));
            const auto c=_mm_loadu_pd(&input(j,i)),d=_mm_loadu_pd(&input(j+1,i));
            equal=_mm_and_pd(equal,_mm_and_pd(_mm_cmpeq_pd(a,_mm_unpacklo_pd(c,d)),_mm_cmpeq_pd(b,_mm_unpackhi_pd(c,d))));
            const auto aa=_mm_andnot_pd(sign,a),ab=_mm_andnot_pd(sign,b);
            const auto ac=_mm_andnot_pd(sign,c),ad=_mm_andnot_pd(sign,d);
            max0=_mm_max_pd(max0,aa);valid0=_mm_and_pd(valid0,_mm_cmple_pd(aa,limit));
            max1=_mm_max_pd(max1,ab);valid1=_mm_and_pd(valid1,_mm_cmple_pd(ab,limit));
            max2=_mm_max_pd(max2,ac);valid2=_mm_and_pd(valid2,_mm_cmple_pd(ac,limit));
            max3=_mm_max_pd(max3,ad);valid3=_mm_and_pd(valid3,_mm_cmple_pd(ad,limit));
        }
    }
    if(_mm_movemask_pd(_mm_and_pd(_mm_and_pd(valid0,valid1),_mm_and_pd(valid2,valid3)))!=3)return false;
    const auto maximum=_mm_max_pd(_mm_max_pd(max0,max1),_mm_max_pd(max2,max3));
    scale=std::max(_mm_cvtsd_f64(maximum),_mm_cvtsd_f64(_mm_unpackhi_pd(maximum,maximum)));
    exact&=_mm_movemask_pd(equal)==3;
#endif
    for(;i<n;++i) {
        if(!llt_is_finite(input(i,i)))return false;
        scale=std::max(scale,std::abs(input(i,i)));
        for(std::size_t j=0;j<i;++j) {
            const double a=input(i,j),b=input(j,i);
            if(!llt_is_finite(a)||!llt_is_finite(b))return false;
            scale=std::max(scale,std::max(std::abs(a),std::abs(b)));
            exact&=a==b;
        }
    }
    return true;
}
'''
scan=base[start:stop]
fused=base[:start]+'''    double scale=0;bool exact=false;
    if(options.check_symmetry && detail::row_simd_available && input.col_stride()==1 && n>=128) {
        if(!detail::finite_exact_symmetric(input,scale,exact))return StatusCode::non_finite_input;
    } else {
'''+base[start:sym].replace('    double scale=0;\n','')+'    }\n'+base[sym:stop].replace('if (options.check_symmetry) {','if (options.check_symmetry && !exact) {',1)+base[stop:]
fused=fused.replace('inline Result<LltFactorView> factorize_column_llt(',helper+'\ninline Result<LltFactorView> factorize_column_llt(',1)

variants={
 'validation_none':base[:start]+base[stop:],
 'validation_no_sym':base[:sym]+base[stop:],
 'validation_no_finite':base[:start]+'    double scale=1;\n'+base[sym:],
 'validation_fused':fused,
}

# Keep the old small path in a separate call target to test the larger frame.
small_start=base.index('inline Result<LltFactorView> factorize_column_llt(')
small_stop=base.index('\n}\n}\n\ninline Result<FactorRequirement>',small_start)+2
body=base[small_start:small_stop]
copy_start=body.index('    if (n<=64) {')
copy_else=body.index('    } else {',copy_start)
copy_end=body.index('\n    if (n<=64) {',copy_else)
small=body[:copy_start]+body[copy_start+len('    if (n<=64) {\n'):copy_else]+body[copy_end:]
algorithm_start=small.index('    if (n<=64) {')
algorithm_else=small.index('    } else {',algorithm_start)
algorithm_end=small.index('    // Restore the caller',algorithm_else)
small=small[:algorithm_start]+small[algorithm_start+len('    if (n<=64) {\n'):algorithm_else]+small[algorithm_end:]
restore_start=small.index('    if (n<=64) {')
restore_else=small.index('    } else {',restore_start)
restore_end=small.index('    return LltAccess',restore_else)
small=small[:restore_start]+small[restore_start+len('    if (n<=64) {\n'):restore_else]+small[restore_end:]
small=small.replace('factorize_column_llt(','factorize_column_llt_small(',1)
large=body.replace('inline Result<LltFactorView> factorize_column_llt(','__declspec(noinline) inline Result<LltFactorView> factorize_column_llt_large(',1)
wrapper='''
inline Result<LltFactorView> factorize_column_llt(MatrixView<const double> input,MatrixView<double> storage) noexcept {
    if(input.rows()<=64)return factorize_column_llt_small(input,storage);
    return factorize_column_llt_large(input,storage);
}
'''
variants['small_frame_split']=base[:small_start]+small+'\n'+large+wrapper+base[small_stop:]
cmake=root/'.scratch/large-llt-next/CMakeLists.txt'
text=cmake.read_text();records={}
for name,header in variants.items():
    dest=out/name/'kibo';dest.mkdir(parents=True,exist_ok=True)
    for source in (root/'include/kibo').glob('*'):
        if source.is_file():shutil.copyfile(source,dest/source.name)
    shutil.copytree(root/'include/kibo/detail',dest/'detail',dirs_exist_ok=True)
    (dest/'llt.hpp').write_text(header)
    records[name]={'sourceSha256':hashlib.sha256(header.encode()).hexdigest(),'contractPreserved':name in ['validation_fused','small_frame_split']}
    if f'add_executable({name} ' not in text:
        text+=f'''\nadd_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
cmake.write_text(text)
(root/'.scratch/large-llt-validation-controls.json').write_text(json.dumps(records,indent=2)+'\n')
print('prepared',list(records))
