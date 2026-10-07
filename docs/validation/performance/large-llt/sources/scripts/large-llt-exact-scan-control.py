from pathlib import Path
import shutil
root=Path.cwd();source=root/'.scratch/large-llt-next/variants/validation_fused/kibo/llt.hpp'
s=source.read_text()
old='''            const auto ac=_mm_andnot_pd(sign,c),ad=_mm_andnot_pd(sign,d);
            max0=_mm_max_pd(max0,aa);valid0=_mm_and_pd(valid0,_mm_cmple_pd(aa,limit));
            max1=_mm_max_pd(max1,ab);valid1=_mm_and_pd(valid1,_mm_cmple_pd(ab,limit));
            max2=_mm_max_pd(max2,ac);valid2=_mm_and_pd(valid2,_mm_cmple_pd(ac,limit));
            max3=_mm_max_pd(max3,ad);valid3=_mm_and_pd(valid3,_mm_cmple_pd(ad,limit));'''
new='''            // Equal opposing entries have equal absolute values. Off-diagonal
            // NaNs make the equality mask false and trigger the full finite scan.
            max0=_mm_max_pd(max0,aa);
            max1=_mm_max_pd(max1,ab);'''
assert old in s;s=s.replace(old,new)
old='''    exact&=_mm_movemask_pd(equal)==3;
#endif'''
new='''    exact&=_mm_movemask_pd(equal)==3;
    if(exact) {
        if(!(scale<=std::numeric_limits<double>::max()))return false;
    } else {
        scale=0;
        for(std::size_t row=0;row<n;++row)
            if(!finite_max_abs(&input(row,0),n,scale))return false;
    }
#endif'''
assert old in s;s=s.replace(old,new)
name='validation_exact_fused';dest=root/f'.scratch/large-llt-next/variants/{name}/kibo'
shutil.copytree(source.parent,dest,dirs_exist_ok=True);(dest/'llt.hpp').write_text(s)
p=root/'.scratch/large-llt-next/CMakeLists.txt';text=p.read_text()
if f'add_executable({name} ' not in text:
    text+=f'''
add_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
p.write_text(text);print('prepared exact-symmetry finite validation with complete fallback')

# Uninitialized temporaries match Eigen's allocation policy; keep the output
# owner separate and verify the materialized result produced by phase3.
p=root/'.scratch/large-llt-next/packed-setup.cpp';s=p.read_text()
s=s.replace('#include <vector>','#include <vector>\n#include <memory>')
s=s.replace('auto core=[&]{','std::unique_ptr<double[]> owned_answer;\n  auto core=[&]{')
old='''std::vector<double> arena(n*n+n),answer(n);
      auto packed=std::span<double>(arena).first(n*n),work=std::span<double>(arena).subspan(n*n);'''
new='''std::unique_ptr<double[]> arena(new double[n*n+n]),answer(new double[n]);
      auto packed=std::span<double>(arena.get(),n*n),work=std::span<double>(arena.get()+n*n,n);'''
assert old in s;s=s.replace(old,new)
s=s.replace('std::span<const double>(b.data(),n),answer,std::as_writable_bytes','std::span<const double>(b.data(),n),std::span<double>(answer.get(),n),std::as_writable_bytes')
s=s.replace('solution=std::move(answer);consumed=solution[0];','owned_answer=std::move(answer);consumed=owned_answer[0];')
s=s.replace('Eigen::Map<Eigen::VectorXd>(solution.data(),n)-expected','Eigen::Map<Eigen::VectorXd>(phase==3?owned_answer.get():solution.data(),n)-expected')
# The common pre-phase validator sits outside owned_answer's scope, so leave it
# on prepared storage. Every timed phase3 result uses the new pointer check.
before,after=s.split(' for(int phase=0;phase<4;++phase){',1)
before=before.replace('phase==3?owned_answer.get():solution.data()','solution.data()')
s=before+' for(int phase=0;phase<4;++phase){'+after
(root/'.scratch/large-llt-next/uninitialized-setup.cpp').write_text(s)
p=root/'.scratch/large-llt-next/CMakeLists.txt';text=p.read_text()
if 'add_executable(uninitialized_setup ' not in text:
    text+='''
add_executable(uninitialized_setup uninitialized-setup.cpp)
target_compile_features(uninitialized_setup PRIVATE cxx_std_20)
target_include_directories(uninitialized_setup PRIVATE ../../include ../../tests ../../.cache/eigen)
target_compile_definitions(uninitialized_setup PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options(uninitialized_setup PRIVATE /O2 /fp:precise /FAs "/Fa${CMAKE_CURRENT_BINARY_DIR}/uninitialized_setup.asm")
'''
p.write_text(text)
