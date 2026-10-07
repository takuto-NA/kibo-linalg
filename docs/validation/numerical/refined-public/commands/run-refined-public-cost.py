from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/qr-refined-public');exe=Path('build/qr-accuracy-public-tools/Release/public-cost.exe')
cmd=[str(exe)];r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=True)
(out/'public-cost.jsonl').write_bytes(r.stdout);(out/'public-cost.stderr').write_bytes(r.stderr)
rows=[json.loads(s) for s in r.stdout.splitlines()]
assert len(rows)==200 and all(s['elapsed']>=.02 for s in rows)
summary=[]
for n in [2,8,32,128,512]:
    for condition in [2,100000000]:
        values=[statistics.median(r['seconds'] for r in rows if r['n']==n and r['condition']==condition and r['phase']==phase) for phase in range(4)]
        record={'n':n,'condition':condition,'phaseMedianSeconds':values,'factorRefinedOverFactorFast':values[3]/values[2]}
        summary.append(record);print(json.dumps(record),flush=True)
(out/'public-cost-summary.json').write_text(json.dumps({'diagnosticOnly':True,'singleProcess':True,'samples':5,
    'cpu':0,'coreType':64,'command':cmd,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
    'sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'rows':summary},indent=2)+'\n')
