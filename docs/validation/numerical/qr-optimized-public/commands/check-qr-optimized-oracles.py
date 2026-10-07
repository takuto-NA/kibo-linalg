from pathlib import Path
import json,subprocess,sys
records=[]
for path in [Path('.scratch/qr-optimized-public/windows.jsonl'),*sorted(Path('.scratch/qr-optimized-public').glob('linux-*/audit-*.jsonl'))]:
    subprocess.run([sys.executable,'tools/diagnostics/qr-accuracy/oracle.py',str(path)],check=True,stdout=subprocess.DEVNULL)
    rows=[json.loads(s) for s in path.read_text().splitlines()]
    oracle=json.loads(path.with_suffix('.oracle.json').read_text())
    assert len(rows)==len(oracle)==102,path
    for r,o in zip(rows,oracle):
        assert r['publicRefinedStatus']==0 and r['status']==0 and r['rank']==r['n'],(path,r['n'])
        x=o['solutions']['publicRefined'];bound=1e-8 if r['condition']<=1e4 else 1e-4
        gate=100*2.220446049250313e-16*max(r['m'],r['n'])
        assert x['truthForward']<=bound and x['oracleForward']<=bound and x['optimality']<=gate,(path,r['n'],x)
        if not r['inconsistent']:assert x['backward']<=gate,(path,r['n'],x)
    result={'path':str(path),'records':len(rows),'allPublicGatesPass':True,
        'maxOracleForward':max(o['solutions']['publicRefined']['oracleForward'] for o in oracle),
        'maxOptimality':max(o['solutions']['publicRefined']['optimality'] for o in oracle)}
    records.append(result);print(json.dumps(result),flush=True)
Path('.scratch/qr-optimized-public/oracle-summary.json').write_text(json.dumps(records,indent=2)+'\n')
