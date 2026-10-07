"""Prepare one-change diagnostic snapshots; public headers are not modified."""
import argparse, subprocess
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('--commit',default='3c7d2c8b54701e1e5f826bfb171d5a442e14d10a')
parser.add_argument('--build',default='build/small-llt')
args=parser.parse_args()
root=Path(__file__).resolve().parents[3]
files=subprocess.check_output(['git','ls-tree','-r','--name-only',args.commit,'include/kibo'],cwd=root,text=True).splitlines()
sources={name:subprocess.check_output(['git','show',f'{args.commit}:{name}'],cwd=root).decode() for name in files}
for variant in ['baseline','fused','inline_input','fused_inline','panel16','fused_panel16','all16','dot','fused_dot','width4','width16','leftlooking','left_inline','left_reciprocal','left_vector','left_unroll','left_pair','left_nocopy','left_force','left_small','left_sym','left_backward','left_copy','left_restore','left_combined']:
    for name,original in sources.items():
        text=original
        if name=='include/kibo/llt.hpp':
            if variant in ['fused','fused_inline','fused_panel16','all16','fused_dot','width4','width16'] or variant.startswith('left'):
                text=text.replace('input.col_stride()==1 && n>=32','input.col_stride()==1 && n>=16')
            if variant in ['panel16','fused_panel16','all16','width4','width16'] or variant.startswith('left'):
                text=text.replace('storage.col_stride()==1 && n>=32','storage.col_stride()==1 && n>=16')
            if variant in ['inline_input','fused_inline','all16']:
                text=text.replace('if (!detail::finite(input)) return StatusCode::non_finite_input;',
                    'for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<n;++j)\n'
                    '            if (!detail::llt_is_finite(input(i,j))) return StatusCode::non_finite_input;')
            if variant in ['dot','fused_dot']:
                text=text.replace('for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);',
                    'if (storage.col_stride()==1) value-=detail::contiguous_dot(&storage(i,0),&storage(j,0),j,0);\n'
                    '            else for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);')
            if variant in ['width4','width16']:
                text=text.replace('std::size_t{8},n-first',f'std::size_t{{{4 if variant=="width4" else 16}}},n-first',1)
            if variant.startswith('left'):
                start=text.index('    for (std::size_t first=0;first<n;)')
                end=text.index("    // Restore the caller's lower triangle",start)
                text=text[:start]+'''    for (std::size_t k=0;k<n;++k) {
        double diagonal=working(k,k);
        for (std::size_t j=0;j<k;++j) diagonal-=working(k,j)*working(k,j);
        if (!llt_is_finite(diagonal)) return Status{StatusCode::arithmetic_failure,k};
        if (diagonal<=0) return Status{StatusCode::non_positive_pivot,k};
        working(k,k)=std::sqrt(diagonal);
        if (k+1<n) {
            auto* coefficients=&working(0,n-1);
            for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);
            row_update_panel(&working(k+1,k),&working(k+1,0),working.col_stride(),coefficients,k,n-k-1);
            for (std::size_t i=k+1;i<n;++i) {
                const auto value=working(i,k)/working(k,k);
                if (!llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }
        }
    }
''' + text[end:]
                if variant in ['left_reciprocal','left_vector']:
                    text=text.replace('const auto value=working(i,k)/working(k,k);','const auto value=working(i,k)*(1/working(k,k));')
                if variant=='left_vector':
                    text=text.replace('            for (std::size_t i=k+1;i<n;++i) {\n                const auto value=working(i,k)*(1/working(k,k));\n                if (!llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};\n                working(i,k)=value;\n            }',
                        '''            std::size_t i=k+1;
#if defined(_M_X64) || defined(__SSE2__)
            const auto multiplier=_mm_set1_pd(1/working(k,k));
            const auto sign=_mm_set1_pd(-0.0),limit=_mm_set1_pd(std::numeric_limits<double>::max());
            auto valid=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());
            for (;n-i>=2;i+=2) {
                auto value=_mm_mul_pd(_mm_loadu_pd(&working(i,k)),multiplier);
                valid=_mm_and_pd(valid,_mm_cmple_pd(_mm_andnot_pd(sign,value),limit));
                _mm_storeu_pd(&working(i,k),value);
            }
            if (_mm_movemask_pd(valid)!=3) return Status{StatusCode::arithmetic_failure,k};
#endif
            for (;i<n;++i) {
                const auto value=working(i,k)*(1/working(k,k));
                if (!llt_is_finite(value)) return Status{StatusCode::arithmetic_failure,k};
                working(i,k)=value;
            }''')
                if variant=='left_nocopy':
                    text=text.replace('            row_update_panel(&working(k+1,k),', '            if (k>0) row_update_panel(&working(k+1,k),')
                if variant=='left_sym':
                    start=text.index('            for (std::size_t i=0;i<n;++i)',text.index('        if (scale!=0)'))
                    end=text.index('\n        }',start)
                    text=text[:start]+'''            for (std::size_t i=0;i<n;++i) {
                std::size_t j=0;
#if defined(_M_X64) || defined(__SSE2__)
                if (input.col_stride()==1) for (;i-j>=2;j+=2) {
                    const auto row=_mm_loadu_pd(&input(i,j));
                    const auto column=_mm_set_pd(input(j+1,i),input(j,i));
                    if (_mm_movemask_pd(_mm_cmpeq_pd(row,column))!=3) {
                        for (std::size_t t=j;t<j+2;++t)
                            if (input(i,t)!=input(t,i) && std::abs(input(i,t)/scale-input(t,i)/scale)>options.symmetry_tolerance)
                                return Status{StatusCode::invalid_argument,i};
                    }
                }
#endif
                for (;j<i;++j)
                    if (input(i,j)!=input(j,i) && std::abs(input(i,j)/scale-input(j,i)/scale)>options.symmetry_tolerance)
                        return Status{StatusCode::invalid_argument,i};
            }''' + text[end:]
                if variant in ['left_backward','left_combined']:
                    start=text.index('    for (std::size_t i=n;i-->0;)')
                    end=text.index('    for (std::size_t i=0;i<n;++i) output[i]',start)
                    text=text[:start]+'''    if (lower.col_stride()==1) {
        for (std::size_t i=n;i-->0;) {
            const auto value=candidate[i]/lower(i,i);
            if (!detail::llt_is_finite(value)) return {StatusCode::arithmetic_failure,i};
            candidate[i]=value;
            if (i>0) detail::row_update(candidate.data(),&lower(i,0),i,value);
        }
    } else {
''' + text[start:end]+'''    }
''' + text[end:]
                if variant in ['left_copy','left_combined']:
                    text=text.replace('for (std::size_t j=0;j<n;++j) for (std::size_t i=j;i<n;++i) working(i,j)=input(i,j);',
                        'for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<=i;++j) working(i,j)=input(i,j);')
                if variant in ['left_restore','left_combined']:
                    start=text.index('    for (std::size_t first=0;first<n;)',text.index("    // Restore the caller's lower triangle"))
                    end=text.index('    return LltAccess::create(storage);',start)
                    text=text[:start]+'''    for (std::size_t i=0;i<n;++i) for (std::size_t j=0;j<i;++j) {
        storage(i,j)=storage(j,i);storage(j,i)=0;
    }
''' + text[end:]
        if name=='include/kibo/detail/row_kernels.hpp' and (variant=='all16' or variant.startswith('left_')):
            text=text.replace('if (!std::isfinite(values[i])) return false;',
                'if (!(std::abs(values[i])<=std::numeric_limits<double>::max())) return false;')
            if variant in ['left_unroll','left_pair']:
                start=text.index('inline void row_update_panel')
                end=text.index('inline bool row_update_checked',start)
                part=text[start:end]
                import re
                if variant=='left_unroll':
                    pattern=r'        for \(std::size_t k=0;k<width;\+\+k\) \{\n            const auto multiplier=_mm_set1_pd\(coefficients\[k\]\);\n(.*?)\n        \}'
                    def unroll(match):
                        inner=match.group(1)
                        ops=[]
                        for offset in range(4):
                            ops.append('            { const auto multiplier=_mm_set1_pd(coefficients[k+'+str(offset)+']);\n'+inner.replace('k*stride','(k+'+str(offset)+')*stride')+'\n            }')
                        return '        std::size_t k=0;\n        for (;width-k>=4;k+=4) {\n'+'\n'.join(ops)+'\n        }\n        for (;k<width;++k) {\n            const auto multiplier=_mm_set1_pd(coefficients[k]);\n'+inner+'\n        }'
                    part=re.sub(pattern,unroll,part,flags=re.S)
                else:
                    part=part.replace('count-j>=16','count-j>=64').replace('count-j>=8','count-j>=64').replace('count-j>=4','count-j>=64')
                text=text[:start]+part+text[end:]
            if variant=='left_force':
                text=text.replace('inline void row_update_panel','__forceinline void row_update_panel')
            if variant=='left_small':
                start=text.index('    for(;count-j>=16',text.index('inline void row_update_panel'))
                end=text.index('    for (;count-j>=8',start)
                text=text[:start]+text[end:]
        destination=root/args.build/'variants'/variant/Path(name).relative_to('include')
        destination.parent.mkdir(parents=True,exist_ok=True)
        if not destination.exists() or destination.read_text(encoding='utf-8')!=text:
            destination.write_text(text,encoding='utf-8')
print('Prepared diagnostic snapshots from',args.commit)
