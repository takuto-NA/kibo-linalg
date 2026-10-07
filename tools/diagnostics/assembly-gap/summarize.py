"""Verify recorded observations and print process-median comparisons."""
from pathlib import Path
import json,statistics
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'docs/validation/performance/assembly-gap'
def median(xs):return statistics.median(xs)
def load(name):return [json.loads(x) for x in (OUT/name).read_text().splitlines()]
for variant in ['baseline','dot','panel32','forward','fused32','fused_panel32','no_validation','inline_finite','fused_panel_inline']:
 cores=[];ratios=[]
 for p in range(3):
  rows=load(f'{variant}-p{p}.jsonl');assert len(rows)==45 and min(r['minBatch'] for r in rows)>=.02
  c=median(r['core'] for r in rows if r['phase']==2);e=median(r['eigen'] for r in rows if r['phase']==2);cores.append(c*1e6);ratios.append(c/e)
 print(variant,'us',median(cores),'Eigen ratio',median(ratios))
for p in range(3):
 rows=load(f'micro-p{p}.jsonl');assert len(rows)==540 and min(r['batchSeconds'] for r in rows)>=.02
 print('micro',p,'valid')
manifest=json.loads((OUT/'public/manifest.json').read_text());assert manifest['valid'] and len(manifest['records'])==52
for n in [2,8,31,32,33,64,128,512]:
 for variant in ['before_actual','public_solver']:
  medians=[];ratios=[]
  for rec in manifest['records']:
   if rec['n']!=n or rec['target']!=variant:continue
   rows=load('public/'+rec['file']);ss=[r for r in rows if r.get('kind')=='sample'];s=rec['summary']
   assert len(ss)==(30 if n==32 else 15) and s['accuracyPassed'] and s['coreType']==64
   assert all(min(r['coreSeconds'],r['eigenSeconds'])*r['calls']>=.02 for r in ss)
   assert median(r['coreSeconds'] for r in ss)==s['coreSeconds']
   medians.append(s['coreSeconds']*1e6);ratios.append(s['ratio'])
  print(n,variant,'us',median(medians),'Eigen ratio',median(ratios))
