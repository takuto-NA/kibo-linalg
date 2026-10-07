from pathlib import Path
import itertools,json,math,statistics
p=Path('.scratch/llt-store-formal');manifest=json.loads((p/'commands.json').read_text())
assert len(manifest['commands'])==120,len(manifest['commands'])
cases=sorted({(int(c['command'][1]),int(c['command'][3])) for c in manifest['commands']})
def ci(values):
    dist=sorted(statistics.median(xs) for xs in itertools.product(values,repeat=len(values)))
    return [dist[int(q*(len(dist)-1))] for q in [.025,.975]]
def p95(values):
    xs=sorted(values);return xs[math.ceil(.95*len(xs))-1]
records=[]
for n,m in cases:
    hashes=set()
    for phase in range(4):
        data={}
        variants=['before_store','public_large']+(['uninitialized_setup'] if n==2 else [])
        for variant in variants:
            ps=[]
            for process in range(5):
                rows=[json.loads(s) for s in (p/f'{variant}-n{n}-m{m}-process{process}.jsonl').read_text().splitlines()]
                assert len(rows)==120 and all(r['minBatch']>=.02 and r['coreType']==64 and r['packetWidth']==2 for r in rows)
                hashes.update(r['inputHash'] for r in rows)
                selected=[r for r in rows if r['phase']==phase]
                ps.append({'core':statistics.median(r['core'] for r in selected),'eigen':statistics.median(r['eigen'] for r in selected),
                           'coreP95':p95([r['core'] for r in selected]),'eigenP95':p95([r['eigen'] for r in selected]),
                           'pairedRatio':statistics.median(r['core']/r['eigen'] for r in selected)})
            ratios=[v['pairedRatio'] for v in ps]
            data[variant]={'medianUs':statistics.median(v['core'] for v in ps)*1e6,'eigenMedianUs':statistics.median(v['eigen'] for v in ps)*1e6,
                           'p95Us':statistics.median(v['coreP95'] for v in ps)*1e6,'eigenP95Us':statistics.median(v['eigenP95'] for v in ps)*1e6,
                           'pairedEigenRatio':statistics.median(ratios),'ratio95':ci(ratios),'processes':ps}
        before_after=[a['core']/b['core'] for a,b in zip(data['public_large']['processes'],data['before_store']['processes'])]
        rec={'n':n,'m':m,'phase':phase,**data,'afterBeforeRatio':statistics.median(before_after),'afterBefore95':ci(before_after)}
        records.append(rec);v=data['public_large']
        print(n,m,phase,'us',round(v['medianUs'],4),'p95',round(v['p95Us'],4),'ratio',round(v['pairedEigenRatio'],4),'CI',*[round(x,4) for x in v['ratio95']],flush=True)
        if n==2 and phase==3:
            v=data['uninitialized_setup'];print('three-allocation uninitialized',n,m,'us',round(v['medianUs'],4),'p95',round(v['p95Us'],4),'ratio',round(v['pairedEigenRatio'],4),'CI',*[round(x,4) for x in v['ratio95']])
    assert len(hashes)==1,(n,m,hashes)
manifest['summaries']=records;manifest['statistics']='median of 5 process medians; median process nearest-rank p95; paired sample ratio then process median; exact 5^5 process bootstrap 95%'
(p/'summary.json').write_text(json.dumps(manifest,indent=2)+'\n')
