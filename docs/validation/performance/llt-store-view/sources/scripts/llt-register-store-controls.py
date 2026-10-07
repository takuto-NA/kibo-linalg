from pathlib import Path
import shutil
root=Path.cwd();base=(root/'include/kibo/llt.hpp').read_text()
variants={}
old='''                    for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);'''
new='''                    double diagonal=working(j,j);
                    for (std::size_t k=first;k<end;++k) diagonal-=working(j,k)*working(j,k);
                    working(j,j)=diagonal;'''
assert old in base;s=base.replace(old,new,1)
old='''                if (j<n) for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);'''
new='''                if (j<n) {
                    double diagonal=working(j,j);
                    for (std::size_t k=first;k<end;++k) diagonal-=working(j,k)*working(j,k);
                    working(j,j)=diagonal;
                }'''
assert old in s;s=s.replace(old,new,1);variants['diagonal_register']=s
old='''    for (;i<count;++i) for (std::size_t k=0;k<width;++k) {
        first[i]-=coefficients[k*stride]*panel[k*stride+i];
        second[i]-=coefficients[k*stride+1]*panel[k*stride+i];
    }'''
new='''    for (;i<count;++i) {
        double a=first[i],b=second[i];
        for (std::size_t k=0;k<width;++k) {
            a-=coefficients[k*stride]*panel[k*stride+i];
            b-=coefficients[k*stride+1]*panel[k*stride+i];
        }
        first[i]=a;second[i]=b;
    }'''
assert old in base;variants['scalar_pair_register']=base.replace(old,new,1)
old='''            const auto p0=_mm_loadu_pd(panel+k*stride+i),p1=_mm_loadu_pd(panel+k*stride+i+2);
            const auto p2=_mm_loadu_pd(panel+k*stride+i+4),p3=_mm_loadu_pd(panel+k*stride+i+6);
            a0=_mm_sub_pd(a0,_mm_mul_pd(a,p0));b0=_mm_sub_pd(b0,_mm_mul_pd(b,p0));
            a1=_mm_sub_pd(a1,_mm_mul_pd(a,p1));b1=_mm_sub_pd(b1,_mm_mul_pd(b,p1));
            a2=_mm_sub_pd(a2,_mm_mul_pd(a,p2));b2=_mm_sub_pd(b2,_mm_mul_pd(b,p2));
            a3=_mm_sub_pd(a3,_mm_mul_pd(a,p3));b3=_mm_sub_pd(b3,_mm_mul_pd(b,p3));'''
new='''            const auto p0=_mm_loadu_pd(panel+k*stride+i);
            a0=_mm_sub_pd(a0,_mm_mul_pd(a,p0));b0=_mm_sub_pd(b0,_mm_mul_pd(b,p0));
            const auto p1=_mm_loadu_pd(panel+k*stride+i+2);
            a1=_mm_sub_pd(a1,_mm_mul_pd(a,p1));b1=_mm_sub_pd(b1,_mm_mul_pd(b,p1));
            const auto p2=_mm_loadu_pd(panel+k*stride+i+4);
            a2=_mm_sub_pd(a2,_mm_mul_pd(a,p2));b2=_mm_sub_pd(b2,_mm_mul_pd(b,p2));
            const auto p3=_mm_loadu_pd(panel+k*stride+i+6);
            a3=_mm_sub_pd(a3,_mm_mul_pd(a,p3));b3=_mm_sub_pd(b3,_mm_mul_pd(b,p3));'''
assert old in base;variants['panel_short_lifetime']=base.replace(old,new,1)
variants['diagonal_pair_register']=variants['diagonal_register'].replace('''    for (;i<count;++i) for (std::size_t k=0;k<width;++k) {
        first[i]-=coefficients[k*stride]*panel[k*stride+i];
        second[i]-=coefficients[k*stride+1]*panel[k*stride+i];
    }''','''    for (;i<count;++i) {
        double a=first[i],b=second[i];
        for (std::size_t k=0;k<width;++k) {
            a-=coefficients[k*stride]*panel[k*stride+i];
            b-=coefficients[k*stride+1]*panel[k*stride+i];
        }
        first[i]=a;second[i]=b;
    }''',1)
p=root/'.scratch/large-llt-next/CMakeLists.txt';cm=p.read_text()
for name,header in variants.items():
    dest=root/f'.scratch/large-llt-next/variants/{name}/kibo';shutil.copytree(root/'include/kibo',dest,dirs_exist_ok=True)
    (dest/'llt.hpp').write_text(header)
    if f'add_executable({name} ' not in cm:
        cm+=f'''
add_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
for name,base_folder in [('view_inline',root/'include/kibo'),('view_fast_inline',root/'.scratch/large-llt-next/variants/view_fast/kibo')]:
    dest=root/f'.scratch/large-llt-next/variants/{name}/kibo';shutil.copytree(base_folder,dest,dirs_exist_ok=True)
    p=dest/'linalg.hpp';s=p.read_text();assert 'static Result<MatrixView> checked(' in s
    p.write_text(s.replace('static Result<MatrixView> checked(','static __forceinline Result<MatrixView> checked(',1))
    for target,source in [(name,'full-adaptive.cpp'),(name+'_uninitialized','uninitialized-setup.cpp')]:
        if f'add_executable({target} ' not in cm:
            cm+=f'''
add_executable({target} {source})
target_compile_features({target} PRIVATE cxx_std_20)
target_include_directories({target} PRIVATE variants/{name} ../../tests ../../.cache/eigen)
target_compile_definitions({target} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({target} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{target}.asm")
'''
(root/'.scratch/large-llt-next/CMakeLists.txt').write_text(cm)
print('prepared individual store/lifetime controls and view inline factorial')
