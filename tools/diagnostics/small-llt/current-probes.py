"""Generate assembly-driven LLT controls from the recorded header snapshot."""
import argparse
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[3]
parser = argparse.ArgumentParser()
parser.add_argument('--include', default='docs/validation/performance/small-llt/sources/pre-validation')
args = parser.parse_args()
source_root = root / args.include
sources = {p.relative_to(source_root): p.read_text(encoding='utf-8')
           for p in (source_root / 'kibo').rglob('*.hpp')}


def panel_kernel(summed=False, six=False):
    chunks = [16, 8, 6, 4, 2] if six else [16, 8, 4, 2]
    lines = ['inline void row_update_panel(double* row, const double* panel, std::size_t stride,',
             ' const double* coefficients, std::size_t width, std::size_t count) noexcept {',
             ' std::size_t j=0;', '#if defined(KIBO_DETAIL_ROW_SSE2)']
    for count in chunks:
        lines.append(f' for (;count-j>={count};j+={count}) {{')
        for p in range(count // 2):
            init = '_mm_setzero_pd()' if summed else f'_mm_loadu_pd(row+j+{2*p})'
            lines.append(f'  auto p{p}={init};')
        lines.extend(['  for (std::size_t k=0;k<width;++k) {',
                      '   const auto multiplier=_mm_set1_pd(coefficients[k]);'])
        for p in range(count // 2):
            op = '_mm_add_pd' if summed else '_mm_sub_pd'
            lines.append(f'   p{p}={op}(p{p},_mm_mul_pd(multiplier,_mm_loadu_pd(panel+k*stride+j+{2*p})));')
        lines.append('  }')
        for p in range(count // 2):
            value = f'_mm_sub_pd(_mm_loadu_pd(row+j+{2*p}),p{p})' if summed else f'p{p}'
            lines.append(f'  _mm_storeu_pd(row+j+{2*p},{value});')
        lines.append(' }')
    lines.append('#endif')
    if summed:
        lines.extend([' for (;j<count;++j) { double sum=0;',
                      '  for (std::size_t k=0;k<width;++k) sum+=coefficients[k]*panel[k*stride+j];',
                      '  row[j]-=sum;', ' }'])
    else:
        lines.append(' for (;j<count;++j) for (std::size_t k=0;k<width;++k) row[j]-=coefficients[k]*panel[k*stride+j];')
    return '\n'.join(lines) + '\n}\n'


variants = ['c_current', 'c_sum', 'c_six', 'c_sum_six', 'c_diagsum', 'c_diagpair', 'c_diagcopy', 'c_sum_diagcopy',
            'c_flat', 'c_no_finite', 'c_no_symmetry', 'c_no_validation', 'c_symtile', 'c_flat_symtile']
variants += ['c_scan2', 'c_scan4', 'c_flat_scan2', 'c_flat_scan4']
variants += ['c_toltile', 'c_flat_toltile']
variants += ['c_combined_scan4_tol']
hashes = {}
for variant in variants:
    hashes[variant] = {}
    for name, original in sources.items():
        text = original
        if name.as_posix() == 'kibo/detail/row_kernels.hpp' and 'scan' in variant:
            packets = 4 if variant.endswith('4') or variant == 'c_combined_scan4_tol' else 2
            begin = text.index('    auto largest=_mm_set1_pd(maximum);')
            end = text.index('\n#endif', begin)
            lines = []
            for p in range(packets):
                lines += [f'    auto largest{p}=_mm_set1_pd(maximum);', f'    auto valid{p}=_mm_cmpeq_pd(_mm_setzero_pd(),_mm_setzero_pd());']
            lines += [f'    for (;count-i>={2*packets};i+={2*packets}) {{']
            for p in range(packets):
                lines += [f'        const auto absolute{p}=_mm_andnot_pd(sign,_mm_loadu_pd(values+i+{2*p}));',
                          f'        valid{p}=_mm_and_pd(valid{p},_mm_cmple_pd(absolute{p},limit));',
                          f'        largest{p}=_mm_max_pd(largest{p},absolute{p});']
            lines += ['    }', '    for (;count-i>=2;i+=2) {',
                      '        const auto absolute=_mm_andnot_pd(sign,_mm_loadu_pd(values+i));',
                      '        valid0=_mm_and_pd(valid0,_mm_cmple_pd(absolute,limit));',
                      '        largest0=_mm_max_pd(largest0,absolute);', '    }']
            for p in range(1, packets):
                lines += [f'    valid0=_mm_and_pd(valid0,valid{p});', f'    largest0=_mm_max_pd(largest0,largest{p});']
            lines += ['    if (_mm_movemask_pd(valid0)!=3) return false;',
                      '    maximum=std::max(_mm_cvtsd_f64(largest0),_mm_cvtsd_f64(_mm_unpackhi_pd(largest0,largest0)));']
            text = text[:begin] + '\n'.join(lines) + text[end:]
        if name.as_posix() == 'kibo/detail/row_kernels.hpp' and variant in ['c_symtile', 'c_flat_symtile', 'c_toltile', 'c_flat_toltile', 'c_combined_scan4_tol']:
            helper = '''inline bool exact_symmetric_rows(MatrixView<const double> input) noexcept {
    const auto n=input.rows();
    std::size_t i=0;
#if defined(KIBO_DETAIL_ROW_SSE2)
    for (;n-i>=2;i+=2) {
        for (std::size_t j=0;j<i;j+=2) {
            const auto a=_mm_loadu_pd(&input(i,j)), b=_mm_loadu_pd(&input(i+1,j));
            const auto c=_mm_loadu_pd(&input(j,i)), d=_mm_loadu_pd(&input(j+1,i));
            const auto equal=_mm_and_pd(_mm_cmpeq_pd(a,_mm_unpacklo_pd(c,d)),_mm_cmpeq_pd(b,_mm_unpackhi_pd(c,d)));
            if (_mm_movemask_pd(equal)!=3) return false;
        }
        if (input(i+1,i)!=input(i,i+1)) return false;
    }
#endif
    for (;i<n;++i) for (std::size_t j=0;j<i;++j) if (input(i,j)!=input(j,i)) return false;
    return true;
}
'''
            if 'toltile' in variant or variant == 'c_combined_scan4_tol':
                helper = helper.replace('MatrixView<const double> input)', 'MatrixView<const double> input, double scale, double tolerance)')
                helper = helper.replace('    for (;n-i>=2;i+=2)', '    const auto divisor=_mm_set1_pd(scale), limit=_mm_set1_pd(tolerance), sign=_mm_set1_pd(-0.0);\n    for (;n-i>=2;i+=2)')
                helper = helper.replace('            if (_mm_movemask_pd(equal)!=3) return false;', '''            if (_mm_movemask_pd(equal)!=3) {
                const auto da=_mm_sub_pd(_mm_div_pd(a,divisor),_mm_div_pd(_mm_unpacklo_pd(c,d),divisor));
                const auto db=_mm_sub_pd(_mm_div_pd(b,divisor),_mm_div_pd(_mm_unpackhi_pd(c,d),divisor));
                const auto near=_mm_and_pd(_mm_cmple_pd(_mm_andnot_pd(sign,da),limit),_mm_cmple_pd(_mm_andnot_pd(sign,db),limit));
                if (_mm_movemask_pd(near)!=3) return false;
            }''')
                helper = helper.replace('if (input(i+1,i)!=input(i,i+1)) return false;', 'if (input(i+1,i)!=input(i,i+1) && std::abs(input(i+1,i)/scale-input(i,i+1)/scale)>tolerance) return false;')
                helper = helper.replace('if (input(i,j)!=input(j,i)) return false;', 'if (input(i,j)!=input(j,i) && std::abs(input(i,j)/scale-input(j,i)/scale)>tolerance) return false;')
            text = text.replace('inline void row_update(double*', helper+'inline void row_update(double*', 1)
        if name.as_posix() == 'kibo/detail/row_kernels.hpp' and variant in ['c_sum', 'c_six', 'c_sum_six', 'c_sum_diagcopy']:
            start = text.index('inline void row_update_panel')
            end = text.index('inline bool row_update_checked', start)
            text = text[:start] + panel_kernel(summed=variant != 'c_six', six=variant == 'c_sum_six' or variant == 'c_six') + text[end:]
        if name.as_posix() == 'kibo/llt.hpp':
            scan = '''        for (std::size_t i=0;i<n;++i)
            if (!detail::finite_max_abs(&input(i,0),n,scale)) return StatusCode::non_finite_input;'''
            if variant in ['c_flat', 'c_flat_symtile', 'c_flat_scan2', 'c_flat_scan4', 'c_flat_toltile', 'c_combined_scan4_tol']:
                text = text.replace(scan, '''        if (input.row_stride()==n) {
            if (!detail::finite_max_abs(&input(0,0),n*n,scale)) return StatusCode::non_finite_input;
        } else {
''' + scan + '\n        }')
            if variant in ['c_no_finite', 'c_no_validation']:
                # Contract-breaking cause controls only, never a public candidate.
                text = text.replace(scan, '        scale=1;')
            if variant in ['c_no_symmetry', 'c_no_validation']:
                text = text.replace('    if (options.check_symmetry) {\n        if (scale!=0)', '    if (false) {\n        if (scale!=0)')
            if variant in ['c_symtile', 'c_flat_symtile']:
                text = text.replace('        if (scale!=0) {', '        if (scale!=0 && !(input.col_stride()==1 && detail::exact_symmetric_rows(input))) {')
            if variant in ['c_toltile', 'c_flat_toltile', 'c_combined_scan4_tol']:
                text = text.replace('        if (scale!=0) {', '        if (scale!=0 && !(input.col_stride()==1 && detail::exact_symmetric_rows(input,scale,options.symmetry_tolerance))) {')
            old = '            for (std::size_t j=0;j<k;++j) diagonal-=working(k,j)*working(k,j);'
            if variant == 'c_diagsum':
                text = text.replace(old, '            double sum=0;\n            for (std::size_t j=0;j<k;++j) sum+=working(k,j)*working(k,j);\n            diagonal-=sum;')
            if variant == 'c_diagpair':
                text = text.replace(old, '            double sum0=0,sum1=0; std::size_t j=0;\n            for (;k-j>=2;j+=2) { sum0+=working(k,j)*working(k,j);sum1+=working(k,j+1)*working(k,j+1); }\n            if(j<k) sum0+=working(k,j)*working(k,j);\n            diagonal-=sum0+sum1;')
            if variant in ['c_diagcopy', 'c_sum_diagcopy']:
                text = text.replace(old, '            auto* coefficients=&working(0,n-1);\n            for (std::size_t j=0;j<k;++j) { auto value=working(k,j); coefficients[j]=value; diagonal-=value*value; }')
                text = text.replace('                auto* coefficients=&working(0,n-1); // unused upper entries\n                for (std::size_t j=0;j<k;++j) coefficients[j]=working(k,j);\n', '')
        dest = root / 'build/small-llt/variants' / variant / name
        dest.parent.mkdir(parents=True, exist_ok=True)
        if not dest.exists() or dest.read_text(encoding='utf-8') != text:
            dest.write_text(text, encoding='utf-8')
        hashes[variant][name.as_posix()] = hashlib.sha256(dest.read_bytes()).hexdigest()
(root / 'build/small-llt/current-probes.json').write_text(json.dumps(hashes, indent=2), encoding='utf-8')
print('Prepared current-header controls:', ', '.join(variants))
