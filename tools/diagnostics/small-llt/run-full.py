import argparse,hashlib,itertools,json,statistics,subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--out',default='.scratch/small-llt-full')
p.add_argument('--n',type=int,nargs='+',default=[31])
p.add_argument('--samples',type=int,default=30)
p.add_argument('--processes',type=int,default=5)
a=p.parse_args();out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
sources=[x for directory in ['include/kibo','tests','tools/diagnostics/small-llt','tools/diagnostics/assembly-gap','tools/diagnostics/solver-locality'] for x in Path(directory).rglob('*') if x.is_file() and '__pycache__' not in str(x)]
manifest={'sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'sourceBaseline':'3c7d2c8b54701e1e5f826bfb171d5a442e14d10a','sourceHashes':{str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in sources},'commands':[],'summaries':[]}
for n in a.n:
 for m in [n,4*n]:
  collected={}
  for process in range(a.processes):
   for target in (['before_full','after_full'] if process%2==0 else ['after_full','before_full']):
    exe=Path('build/small-llt/Release')/f'{target}.exe'
    cmd=[str(exe),str(n),str(a.samples),str(m),str(process)]
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    path=out/f'{target}-n{n}-m{m}-p{process}.jsonl';path.write_bytes(r.stdout)
    assert not r.returncode,(cmd,r.returncode,r.stderr)
    rows=[json.loads(x) for x in r.stdout.splitlines()]
    assert len(rows)==4*a.samples and all(x['minBatch']>=.020 for x in rows)
    assert all(x['coreType']==64 and x['packetWidth']==2 for x in rows)
    phases={i:{field:statistics.median(x[field] for x in rows if x['phase']==i) for field in ['core','eigen']} for i in range(4)}
    collected[target,process]=phases
    manifest['commands'].append({'command':cmd,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'output':str(path)})
    print(n,m,process,target,'phase ratios',*[round(phases[i]['core']/phases[i]['eigen'],4) for i in range(4)],flush=True)
  for phase in range(4):
   ratios=[collected['after_full',i][phase]['core']/collected['after_full',i][phase]['eigen'] for i in range(a.processes)]
   boot=sorted(statistics.median(v) for v in itertools.product(ratios,repeat=len(ratios)))
   record={'n':n,'m':m,'phase':phase,'afterEigenRatio':statistics.median(ratios),'interval':[boot[int(.025*(len(boot)-1))],boot[int(.975*(len(boot)-1))]]}
   manifest['summaries'].append(record);print('SUMMARY',record,flush=True)
  assert len({x['inputHash'] for path in out.glob(f'*-n{n}-m{m}-p*.jsonl') for x in map(json.loads,path.read_text().splitlines())})==1
assert all(hashlib.sha256(Path(x).read_bytes()).hexdigest()==h for x,h in manifest['sourceHashes'].items())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
