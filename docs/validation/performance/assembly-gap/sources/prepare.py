from pathlib import Path
import subprocess
BASE='c3c10dfd60c0b666ec59dec9e8855dd0d3f0b464'
ROOT=Path(__file__).resolve().parents[3]
VARIANTS=['baseline','dot','panel32','forward','fused32','fused_panel32','no_validation','inline_finite','fused_panel_inline']
def prepare():
 paths=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','include'],cwd=ROOT,text=True).splitlines()
 for variant in VARIANTS:
  for path in paths:
   data=subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT)
   if path=='include/kibo/llt.hpp':
    s=data.decode()
    if variant=='dot':s=s.replace('for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);','if (storage.col_stride()==1 && j>=16) value-=detail::contiguous_dot(&storage(i,0),&storage(j,0),j,0);\n            else for (std::size_t k=0;k<j;++k) value-=storage(i,k)*storage(j,k);')
    if variant=='forward':s=s.replace('for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];','if (lower.col_stride()==1 && i>=16) value-=detail::contiguous_dot(&lower(i,0),candidate.data(),i,0);\n        else for (std::size_t j=0;j<i;++j) value-=lower(i,j)*candidate[j];')
    if variant in ['panel32','fused_panel32','fused_panel_inline']:s=s.replace('storage.col_stride()==1 && n>=64','storage.col_stride()==1 && n>=32')
    if variant in ['fused32','fused_panel32','fused_panel_inline']:s=s.replace('input.col_stride()==1 && n>=64','input.col_stride()==1 && n>=32')
    if variant in ['inline_finite','fused_panel_inline']:
     s=s.replace('namespace kibo::linalg {','namespace kibo::linalg {\ninline bool diag_isfinite(double value) noexcept { return std::abs(value)<=std::numeric_limits<double>::max(); }',1).replace('std::isfinite','diag_isfinite')
    if variant=='no_validation':
     start=s.index('    double scale=0;');end=s.index('    if constexpr (detail::row_simd_available)',start);s=s[:start]+s[end:]
    data=s.encode()
   target=ROOT/'build/assembly-gap/variants'/variant/Path(path).relative_to('include');target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
if __name__=='__main__':prepare()
