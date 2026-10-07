"""Sequential, pinned diagnostics. Timings are never run concurrently."""
import argparse,hashlib,json,statistics,subprocess
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--build',default='build/small-llt')
p.add_argument('--out',default='.scratch/small-llt-first')
p.add_argument('--n',type=int,nargs='+',default=[31])
p.add_argument('--samples',type=int,default=5)
p.add_argument('--processes',type=int,default=1)
p.add_argument('--variants',nargs='+',default=['baseline','fused','inline_input','fused_inline','panel16','fused_panel16','all16','dot'])
a=p.parse_args();out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
for n in a.n:
 for process in range(a.processes):
  order=a.variants if process%2==0 else list(reversed(a.variants))
  for variant in order:
   exe=Path(a.build)/'Release'/f'{variant}.exe'
   cmd=[str(exe),str(n),str(a.samples)]
   result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
   (out/f'{variant}-n{n}-p{process}.jsonl').write_bytes(result.stdout)
   if result.returncode:raise RuntimeError((cmd,result.returncode,result.stderr.decode()))
   data=[json.loads(l) for l in result.stdout.splitlines()]
   assert len(data)==3*a.samples and all(x['minBatch']>=.02 for x in data)
   values={phase:{k:statistics.median(x[k] for x in data if x['phase']==phase) for k in ['core','eigen']} for phase in range(3)}
   print(n,process,variant,{phase:round(values[phase]['core']*1e6,3) for phase in range(3)},'both ratio',round(values[2]['core']/values[2]['eigen'],3),flush=True)
   (out/f'{variant}-n{n}-p{process}-meta.json').write_text(json.dumps({'command':cmd,'binaryHash':hashlib.sha256(exe.read_bytes()).hexdigest(),'summary':values},indent=2),encoding='utf-8')
