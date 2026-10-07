"""New one-change controls from the actual 8fe public algorithm."""
import json
import subprocess
from pathlib import Path

commit = '8fe28e552bfc485c4744a193cc9e677b3e2ce309'
root = Path.cwd()
out = root/'.scratch/large-llt-next'
files = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', commit, 'include/kibo'], text=True).splitlines()
sources = {name: subprocess.check_output(['git', 'show', f'{commit}:{name}']).decode() for name in files}
helper = '''
inline void update_column_pair(double* first, double* second, const double* panel,
                               std::size_t stride, const double* coefficients,
                               std::size_t width, std::size_t count) noexcept {
    std::size_t i=0;
#if !defined(KIBO_DISABLE_SIMD) && !defined(__wasm__) && (defined(_M_X64) || defined(__SSE2__))
    for (;count-i>=8;i+=8) {
        auto a0=_mm_loadu_pd(first+i),a1=_mm_loadu_pd(first+i+2);
        auto a2=_mm_loadu_pd(first+i+4),a3=_mm_loadu_pd(first+i+6);
        auto b0=_mm_loadu_pd(second+i),b1=_mm_loadu_pd(second+i+2);
        auto b2=_mm_loadu_pd(second+i+4),b3=_mm_loadu_pd(second+i+6);
        for (std::size_t k=0;k<width;++k) {
            const auto pair=_mm_loadu_pd(coefficients+k*stride);
            const auto a=_mm_unpacklo_pd(pair,pair),b=_mm_unpackhi_pd(pair,pair);
            const auto p0=_mm_loadu_pd(panel+k*stride+i),p1=_mm_loadu_pd(panel+k*stride+i+2);
            const auto p2=_mm_loadu_pd(panel+k*stride+i+4),p3=_mm_loadu_pd(panel+k*stride+i+6);
            a0=_mm_sub_pd(a0,_mm_mul_pd(a,p0));b0=_mm_sub_pd(b0,_mm_mul_pd(b,p0));
            a1=_mm_sub_pd(a1,_mm_mul_pd(a,p1));b1=_mm_sub_pd(b1,_mm_mul_pd(b,p1));
            a2=_mm_sub_pd(a2,_mm_mul_pd(a,p2));b2=_mm_sub_pd(b2,_mm_mul_pd(b,p2));
            a3=_mm_sub_pd(a3,_mm_mul_pd(a,p3));b3=_mm_sub_pd(b3,_mm_mul_pd(b,p3));
        }
        _mm_storeu_pd(first+i,a0);_mm_storeu_pd(first+i+2,a1);
        _mm_storeu_pd(first+i+4,a2);_mm_storeu_pd(first+i+6,a3);
        _mm_storeu_pd(second+i,b0);_mm_storeu_pd(second+i+2,b1);
        _mm_storeu_pd(second+i+4,b2);_mm_storeu_pd(second+i+6,b3);
    }
    for (;count-i>=2;i+=2) {
        auto a0=_mm_loadu_pd(first+i),b0=_mm_loadu_pd(second+i);
        for (std::size_t k=0;k<width;++k) {
            const auto pair=_mm_loadu_pd(coefficients+k*stride);
            const auto p=_mm_loadu_pd(panel+k*stride+i);
            a0=_mm_sub_pd(a0,_mm_mul_pd(_mm_unpacklo_pd(pair,pair),p));
            b0=_mm_sub_pd(b0,_mm_mul_pd(_mm_unpackhi_pd(pair,pair),p));
        }
        _mm_storeu_pd(first+i,a0);_mm_storeu_pd(second+i,b0);
    }
#endif
    for (;i<count;++i) for (std::size_t k=0;k<width;++k) {
        first[i]-=coefficients[k*stride]*panel[k*stride+i];
        second[i]-=coefficients[k*stride+1]*panel[k*stride+i];
    }
}
'''
old = '''                auto* coefficients=&working(0,n-1); // unused upper column, width<=n-1
                for (std::size_t j=end;j<n;++j) {
                    for (std::size_t k=first;k<end;++k) coefficients[k-first]=working(j,k);
                    row_update_panel(&working(j,j),&working(j,first),working.col_stride(),coefficients,end-first,n-j);
                }'''
new = '''                std::size_t j=end;
                for (;n-j>=2;j+=2) {
                    for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);
                    update_column_pair(&working(j+1,j),&working(j+1,j+1),&working(j+1,first),
                                       working.col_stride(),&working(j,first),end-first,n-j-1);
                }
                if (j<n) for (std::size_t k=first;k<end;++k) working(j,j)-=working(j,k)*working(j,k);'''
variants = ['actual', 'width16', 'width32', 'width64', 'adaptive', 'pair8', 'pair16', 'pair32', 'pair64', 'pair_adaptive']
for variant in variants:
    for name, original in sources.items():
        text = original
        if name=='include/kibo/llt.hpp':
            if variant.startswith('pair'):
                assert old in text
                text = text.replace(old, new).replace('inline Result<LltFactorView> factorize_column_llt', helper+'\ninline Result<LltFactorView> factorize_column_llt')
            if variant!='actual':
                width = variant.removeprefix('width').removeprefix('pair')
                value = 'std::min(std::max((n/8/16)*16,std::size_t{8}),std::size_t{128})' if 'adaptive' in width else f'std::size_t{{{width}}}'
                text = text.replace('std::size_t{8},n-first', value+',n-first', 1)
        target = out/'variants'/variant/Path(name).relative_to('include')
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding='utf-8')
cmake = '''cmake_minimum_required(VERSION 3.30)
project(large_llt LANGUAGES CXX)
'''
for variant in variants:
    cmake += f'''add_executable({variant} ../../tools/diagnostics/small-llt/full.cpp)
target_compile_features({variant} PRIVATE cxx_std_20)
target_include_directories({variant} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({variant} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({variant} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{variant}.asm")
'''
(out/'CMakeLists.txt').write_text(cmake)
(out/'provenance.json').write_text(json.dumps({'commit':commit,'variants':variants},indent=2))
print('Prepared',len(variants),'diagnostic variants only; not built or measured.')
