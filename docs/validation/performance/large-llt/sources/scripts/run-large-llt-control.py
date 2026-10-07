import hashlib
import json
import statistics
import subprocess
import sys
from pathlib import Path

quad_series='--quad' in sys.argv
sym_series='--sym' in sys.argv
next_series='--next' in sys.argv
out=Path('.scratch/large-llt-fourth' if quad_series else '.scratch/large-llt-third' if sym_series else '.scratch/large-llt-second' if next_series else '.scratch/large-llt-first');out.mkdir(exist_ok=True)
if '--out' in sys.argv:
    out=Path(sys.argv[sys.argv.index('--out')+1]);out.mkdir(exist_ok=True)
variants=(['actual','pair8_divide']+json.loads(Path('.scratch/large-llt-next/quad-variants.json').read_text()) if quad_series else
          ['actual','pair8_divide']+json.loads(Path('.scratch/large-llt-next/sym-variants.json').read_text()) if sym_series else
          ['actual','pair8']+json.loads(Path('.scratch/large-llt-next/next-variants.json').read_text())
          if next_series else json.loads(Path('.scratch/large-llt-next/provenance.json').read_text())['variants'])
records=[]
if '--variants' in sys.argv:
    variants=sys.argv[sys.argv.index('--variants')+1].split(',')
sizes=[int(s) for s in sys.argv[sys.argv.index('--n')+1].split(',')] if '--n' in sys.argv else [128,512]
for n in sizes:
    for variant in variants:
        exe=Path('build/large-llt-next/Release')/(variant+'.exe')
        command=[str(exe),str(n),'3',str(4*n),'0']
        result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert not result.returncode,(command,result.returncode,result.stderr)
        output=out/f'{variant}-n{n}.jsonl';output.write_bytes(result.stdout)
        rows=list(map(json.loads,result.stdout.splitlines()))
        assert len(rows)==12 and all(r['minBatch']>=.02 and r['coreType']==64 and r['packetWidth']==2 for r in rows)
        summary={p:{key:statistics.median(r[key] for r in rows if r['phase']==p) for key in ['core','eigen']} for p in range(4)}
        print(n,variant,'core us',*[round(1e6*summary[p]['core'],2) for p in range(4)],'Eigen ratios',*[round(summary[p]['core']/summary[p]['eigen'],3) for p in range(4)],flush=True)
        records.append({'command':command,'output':str(output),'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'summary':summary})
(out/'manifest.json').write_text(json.dumps({'sourceCommit':'8fe28e552bfc485c4744a193cc9e677b3e2ce309','diagnosisOnly':True,'commands':records},indent=2))
