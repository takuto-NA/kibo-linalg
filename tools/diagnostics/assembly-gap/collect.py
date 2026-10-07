from pathlib import Path
import hashlib,json,os,random,subprocess
from datetime import datetime,timezone
from prepare import ROOT,BASE,VARIANTS,prepare
HERE=Path(__file__).resolve().parent
OUT=ROOT/'docs/validation/performance/assembly-gap'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 if OUT.exists() and any(OUT.iterdir()):raise RuntimeError('Do not overwrite evidence')
 OUT.mkdir(parents=True,exist_ok=True)
 prepare()
 env={k.upper():v for k,v in os.environ.items()}
 for k in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(k,None)
 commands=[['cmake','-S',str(HERE),'-B',str(ROOT/'build/assembly-gap'),'-G','Visual Studio 17 2022','-A','x64',f'-DEIGEN_SOURCE_DIR={ROOT/".cache/eigen"}'],['cmake','--build',str(ROOT/'build/assembly-gap'),'--config','Release','--parallel','4']]
 for i,cmd in enumerate(commands):
  r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(OUT/f'build-{i}.log').write_bytes(r.stdout);assert r.returncode==0
 files=[p for parent in [HERE,ROOT/'build/assembly-gap/variants',ROOT/'tests',ROOT/'include'] for p in parent.rglob('*') if p.is_file() and '__pycache__' not in str(p)]
 manifest={'sourceBaseCommit':BASE,'startedUtc':datetime.now(timezone.utc).isoformat(),'commands':commands,'diagnosticOnly':True,'processes':3,'samplesPerPhase':15,'sourceSha256':{str(p.relative_to(ROOT)):sha(p) for p in files},'binarySha256':{v:sha(ROOT/f'build/assembly-gap/Release/{v}.exe') for v in VARIANTS+['micro']},'records':[]}
 for process in range(3):
  variants=VARIANTS.copy();random.Random(0x41534d+process).shuffle(variants)
  for v in variants:
   cmd=[str(ROOT/f'build/assembly-gap/Release/{v}.exe'),'32','15'];r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);name=f'{v}-p{process}.jsonl';(OUT/name).write_bytes(r.stdout);assert r.returncode==0
   rows=[json.loads(x) for x in r.stdout.splitlines()];assert len(rows)==45 and min(x['minBatch'] for x in rows)>=.02
   manifest['records'].append({'variant':v,'process':process,'file':name,'command':cmd,'exitCode':r.returncode});print(v,process,'passed',flush=True)
 assert all(sha(ROOT/p)==h for p,h in manifest['sourceSha256'].items())
 assert all(sha(ROOT/f'build/assembly-gap/Release/{v}.exe')==h for v,h in manifest['binarySha256'].items())
 manifest['finishedUtc']=datetime.now(timezone.utc).isoformat();manifest['valid']=True
 (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
 (OUT/'kernels.asm').write_bytes((ROOT/'build/assembly-gap/kernels.asm').read_bytes())
 print('VALID',len(manifest['records']),flush=True)
if __name__=='__main__':main()
