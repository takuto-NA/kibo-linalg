"""Public factor+solve comparison with immutable inputs and sequential runs."""
import argparse,hashlib,itertools,json,statistics,subprocess
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--out',default='.scratch/small-llt-paired')
p.add_argument('--n',type=int,nargs='+',default=[2,8,16,31,32,33,64])
p.add_argument('--samples',type=int,default=30)
p.add_argument('--processes',type=int,default=5)
a=p.parse_args();out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
sources=[x for directory in ['include/kibo','tests','tools/diagnostics/small-llt','tools/diagnostics/assembly-gap','tools/diagnostics/solver-locality'] for x in Path(directory).rglob('*') if x.is_file() and '__pycache__' not in str(x)]
manifest={'sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'sourceBaseline':'3c7d2c8b54701e1e5f826bfb171d5a442e14d10a','sourceHashes':{str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in sources},'commands':[],'processes':a.processes,'samples':a.samples}
summary=[]
for n in a.n:
 for m in [n,4*n]:
  for process in range(a.processes):
   for target in (['before_solver','actual_solver'] if process%2==0 else ['actual_solver','before_solver']):
    exe=Path('build/small-llt/Release')/f'{target}.exe'
    path=out/f'{target}-n{n}-m{m}-p{process}.jsonl'
    cmd=[str(exe),str(process),str(a.samples),str(n),str(m)]
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    path.write_bytes(r.stdout)
    rows=[json.loads(x) for x in r.stdout.splitlines()]
    s=next(x for x in rows if x['kind']=='summary')
    assert r.returncode in [0,1] and s['accuracyPassed'] and s['packetWidth']==2 and s['coreType']==64
    assert len([x for x in rows if x['kind']=='sample'])==a.samples
    assert all(x['coreSeconds']*x['calls']>=.020 and x['eigenSeconds']*x['calls']>=.020 for x in rows if x['kind']=='sample')
    s['target']=target;summary.append(s)
    manifest['commands'].append({'command':cmd,'exit':r.returncode,'output':str(path),'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest()})
   pair=[x for x in summary if x['n']==n and x['m']==m and x['process']==process]
   assert len({x['inputHash'] for x in pair})==1
   print('n',n,'m',m,'p',process,'before/after Eigen ratios',*[round(x['ratio'],4) for x in sorted(pair,key=lambda x:x['target'],reverse=True)],flush=True)
  ratios=[x['ratio'] for x in summary if x['n']==n and x['m']==m and x['target']=='actual_solver']
  boot=sorted(statistics.median(v) for v in itertools.product(ratios,repeat=len(ratios)))
  print('SUMMARY',n,m,'after/Eigen',round(statistics.median(ratios),4),'95% empirical interval',round(boot[int(.025*(len(boot)-1))],4),round(boot[int(.975*(len(boot)-1))],4),flush=True)
assert all(hashlib.sha256(Path(x).read_bytes()).hexdigest()==h for x,h in manifest['sourceHashes'].items())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
(out/'summaries.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
