"""Process-level medians/p95, paired ratios, and empirical bootstrap intervals."""
import argparse
import itertools
import json
import math
import statistics as st
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('directory',type=Path)
p.add_argument('--full',action='store_true')
a=p.parse_args()
manifest=json.loads((a.directory/'manifest.json').read_text())
groups={}
for record in manifest['commands']:
    raw=Path(record['output'])
    # A copied evidence directory is usable without the original scratch path.
    if not raw.exists():raw=a.directory/raw.name
    rows=list(map(json.loads,raw.read_text().splitlines()))
    full=a.full
    target=Path(record['command'][0]).stem
    if full:
        n,m,process=map(int,[record['command'][1],record['command'][3],record['command'][4]])
        phases=range(4)
    else:
        summary=next(x for x in rows if x['kind']=='summary')
        n,m,process=summary['n'],summary['m'],summary['process'];phases=[2]
        rows=[x for x in rows if x['kind']=='sample']
    for phase in phases:
        samples=[x for x in rows if not full or x['phase']==phase]
        core='core' if full else 'coreSeconds';eigen='eigen' if full else 'eigenSeconds'
        assert len(samples)==30
        assert all(min(x[core],x[eigen])*x['calls']>=.02 for x in samples)
        c=[x[core] for x in samples];e=[x[eigen] for x in samples]
        groups[target,n,m,phase,process]={'core':st.median(c),'eigen':st.median(e),
            'coreP95':sorted(c)[math.ceil(.95*len(c))-1], 'eigenP95':sorted(e)[math.ceil(.95*len(e))-1],
            'ratio':st.median(c)/st.median(e),'samplePairedRatio':st.median(x/y for x,y in zip(c,e))}

def interval(v):
    b=sorted(st.median(x) for x in itertools.product(v,repeat=len(v)))
    return [b[int(.025*(len(b)-1))],b[int(.975*(len(b)-1))]]

result=[]
before='before_full' if a.full else 'before_solver'
after='after_full' if a.full else 'actual_solver'
for n,m,phase in sorted({(n,m,phase) for target,n,m,phase,process in groups}):
    old=[groups[before,n,m,phase,p] for p in range(5)]
    new=[groups[after,n,m,phase,p] for p in range(5)]
    ratios=[x['ratio'] for x in new];paired=[x['core']/y['core'] for x,y in zip(new,old)]
    record={'n':n,'m':m,'phase':phase,'oldUs':1e6*st.median(x['core'] for x in old),
        'newUs':1e6*st.median(x['core'] for x in new),'eigenUs':1e6*st.median(x['eigen'] for x in new),
        'oldP95Us':1e6*st.median(x['coreP95'] for x in old),'newP95Us':1e6*st.median(x['coreP95'] for x in new),
        'eigenP95Us':1e6*st.median(x['eigenP95'] for x in new),
        'newOldRatio':st.median(paired),'newOld95':interval(paired),
        'newEigenRatio':st.median(ratios),'newEigen95':interval(ratios),
        'samplePairedRatio':st.median(x['samplePairedRatio'] for x in new)}
    result.append(record)
(a.directory/'comparisons.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print('Saved',len(result),'shape/phase comparisons')
