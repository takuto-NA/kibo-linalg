from pathlib import Path
import argparse,hashlib,itertools,json,statistics
parser=argparse.ArgumentParser(description='Verify accepted raw timing data and compute process-level comparisons.')
parser.add_argument('directory',type=Path)
parser.add_argument('--report',type=Path)
args=parser.parse_args()
root=Path(__file__).resolve().parents[3];out=args.directory.resolve()
manifest=json.loads((out/'accepted-manifest.json').read_text())
assert manifest['valid'] and len(manifest['records'])==300
groups={};paired={};input_hashes={};sample_count=0;p95s={}
for record in manifest['records']:
    assert record['valid'],record['raw']
    rows=[json.loads(x) for x in (out/record['raw']).read_text().splitlines() if x.startswith('{')]
    samples=[r for r in rows if r.get('kind')=='sample'];sample_count+=len(samples)
    assert len(samples)==30 and len({s['sample'] for s in samples})==30
    assert all(min(s['coreSeconds'],s['eigenSeconds'])*s['calls']>=.020 for s in samples)
    s=next(r for r in rows if r.get('kind')=='summary')
    assert s['accuracyPassed'] and s['coreType']==64 and s['packetWidth']==2 and s['coreSIMD']==1
    assert statistics.median(r['coreSeconds'] for r in samples)==s['coreSeconds']
    assert statistics.median(r['eigenSeconds'] for r in samples)==s['eigenSeconds']
    name=(record['target'],record['n'],record['m'])
    groups.setdefault(name,[]).append(s)
    p95s.setdefault(name,[]).append({k:sorted(r[k] for r in samples)[28] for k in ['coreSeconds','eigenSeconds']})
    paired[(*name,record['process'])]=s
    input_hashes.setdefault((s['solver'],s['n'],s['m']),set()).add(s['inputHash'])
assert all(len(v)==1 for v in input_hashes.values())
for path,digest in manifest['sourceSha256'].items():assert hashlib.sha256((root/path).read_bytes()).hexdigest()==digest,path
def interval(values):
    # Exact enumeration of the 5^5 empirical-bootstrap resamples; no sampling noise.
    medians=sorted(statistics.median(v) for v in itertools.product(values,repeat=len(values)))
    return [medians[int(.025*len(medians))],medians[int(.975*len(medians))]]
comparisons=[]
for n in [2,8,32,128,512]:
    for m in [n,4*n]:
        for solver in ['llt','qr_row','qr_column']:
            old=groups[('before_'+solver,n,m)];new=groups[('after_'+solver,n,m)]
            ratios=[paired[('after_'+solver,n,m,p)]['coreSeconds']/paired[('before_'+solver,n,m,p)]['coreSeconds'] for p in range(5)]
            comparisons.append({'oldP95Ms':statistics.median(v['coreSeconds']*1000 for v in p95s[('before_'+solver,n,m)]),'newP95Ms':statistics.median(v['coreSeconds']*1000 for v in p95s[('after_'+solver,n,m)]),'eigenP95Ms':statistics.median(v['eigenSeconds']*1000 for v in p95s[('after_'+solver,n,m)]),'solver':solver,'n':n,'m':m,'oldMs':statistics.median(v['coreSeconds']*1000 for v in old),'newMs':statistics.median(v['coreSeconds']*1000 for v in new),'eigenMs':statistics.median(v['eigenSeconds']*1000 for v in new),'newOldRatio':statistics.median(ratios),'newOld95':interval(ratios),'eigenRatio':statistics.median(v['ratio'] for v in new),'eigen95':interval([v['ratio'] for v in new])})
(out/'comparisons.json').write_text(json.dumps(comparisons,indent=2)+'\n',encoding='utf-8',newline='\n')
print('PASS:',len(manifest['records']),'observations;',sample_count,'paired samples; inputs, oracles, durations and source hashes')
print('Largest:',json.dumps([v for v in comparisons if v['n']==512 and v['m']==2048]))
print('Regressions >20%:',json.dumps([v for v in comparisons if v['newOldRatio']>=1.2 and v['newOld95'][0]>=1.2]))
sections={}
for solver in ['llt','qr_row','qr_column']:
    table='| n | m | 旧版 ms | 修正版 ms | Eigen ms | 新/旧 [95%] | 修正版/Eigen [95%] |\n| ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n'
    for row in comparisons:
        if row['solver']!=solver:continue
        a,b=row['newOld95'];c,d=row['eigen95']
        table+=f"| {row['n']} | {row['m']} | {row['oldMs']:.6f} | {row['newMs']:.6f} | {row['eigenMs']:.6f} | {row['newOldRatio']:.3f} [{a:.3f}, {b:.3f}] | {row['eigenRatio']:.3f} [{c:.3f}, {d:.3f}] |\n"
    sections[solver]=table
if args.report:
    report=args.report
    text=report.read_text()
    for name,table in sections.items():text=text.replace('<!-- '+name+' -->',table)
    report.write_text(text,encoding='utf-8',newline='\n')
(out/'SHA256SUMS.txt').write_text(''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n' for p in sorted(out.iterdir()) if p.is_file() and p.name!='SHA256SUMS.txt'),encoding='utf-8',newline='\n')
