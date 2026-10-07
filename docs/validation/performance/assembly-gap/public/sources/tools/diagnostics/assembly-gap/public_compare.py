from pathlib import Path
import hashlib,json,subprocess,random
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'docs/validation/performance/assembly-gap/public'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 if OUT.exists() and any(OUT.iterdir()):raise RuntimeError('Do not overwrite')
 OUT.mkdir(parents=True,exist_ok=True)
 sources=[p for directory in ['include','tests','tools/diagnostics/assembly-gap','tools/diagnostics/solver-locality'] for p in (ROOT/directory).rglob('*') if p.is_file() and '__pycache__' not in str(p)]
 manifest={'startedUtc':datetime.now(timezone.utc).isoformat(),'sourceCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'baselineCommit':'c3c10dfd60c0b666ec59dec9e8855dd0d3f0b464','sourceSha256':{str(p.relative_to(ROOT)):sha(p) for p in sources},'binarySha256':{t:sha(ROOT/f'build/assembly-gap/Release/{t}.exe') for t in ['before_actual','public_solver']},'records':[]}
 cases=[(n,p,30 if n==32 else 15,t) for n in [2,8,31,32,33,64,128,512] for p in range(5 if n==32 else 3) for t in ['before_actual','public_solver']]
 random.Random(0x41534d).shuffle(cases)
 for n,p,samples,t in cases:
  cmd=[str(ROOT/f'build/assembly-gap/Release/{t}.exe'),str(p),str(samples),str(n),str(n*4)]
  r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);name=f'{t}-n{n}-p{p}.jsonl';(OUT/name).write_bytes(r.stdout)
  rows=[json.loads(x) for x in r.stdout.splitlines()];s=next(x for x in rows if x.get('kind')=='summary');ss=[x for x in rows if x.get('kind')=='sample']
  ok=r.returncode in (0,1) and s['accuracyPassed'] and s['coreType']==64 and len(ss)==samples and all(min(x['coreSeconds'],x['eigenSeconds'])*x['calls']>=.02 for x in ss)
  manifest['records'].append({'n':n,'process':p,'target':t,'command':cmd,'file':name,'valid':ok,'summary':s,'exitCode':r.returncode});print(t,n,p,ok,s['ratio'],flush=True)
 assert all(sha(ROOT/p)==h for p,h in manifest['sourceSha256'].items())
 assert all(sha(ROOT/f'build/assembly-gap/Release/{t}.exe')==h for t,h in manifest['binarySha256'].items())
 manifest['finishedUtc']=datetime.now(timezone.utc).isoformat();manifest['valid']=all(x['valid'] for x in manifest['records']);(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
 print('VALID',manifest['valid'],len(manifest['records']))
if __name__=='__main__':main()
