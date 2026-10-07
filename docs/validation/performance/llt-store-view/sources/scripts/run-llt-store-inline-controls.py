from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/llt-store-inline-controls');out.mkdir(exist_ok=True)
records=[]
cases=[(128,512,['public_large','diagonal_register','scalar_pair_register','panel_short_lifetime','diagonal_pair_register']),
       (512,2048,['public_large','diagonal_register','scalar_pair_register','panel_short_lifetime','diagonal_pair_register']),
       (2,8,['public_large','view_fast','view_inline','view_fast_inline','uninitialized_setup','view_fast_uninitialized','view_inline_uninitialized','view_fast_inline_uninitialized']),
       (8,32,['public_large','view_inline','view_fast_inline']),
       (32,128,['public_large','view_inline','view_fast_inline'])]
for process in range(3):
    for n,m,variants in cases:
        for v in (variants if process%2==0 else list(reversed(variants))):
            exe=Path(f'build/large-llt-next/Release/{v}.exe');cmd=[str(exe),str(n),'5',str(m),str(process)]
            r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert r.returncode==0,(cmd,r.returncode,r.stderr)
            dest=out/f'{v}-n{n}-m{m}-process{process}.jsonl';dest.write_bytes(r.stdout)
            rows=[json.loads(s) for s in r.stdout.splitlines()]
            assert len(rows)==20 and all(s['minBatch']>=.02 and s['coreType']==64 and s['packetWidth']==2 for s in rows)
            rec={'command':cmd,'output':dest.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
                 'medianPhaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
                 'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
            records.append(rec);(out/'manifest.json').write_text(json.dumps({'publicCodeCommit':'2f23d66af38fe4aed42811cdf6438af73de620c5','samples':5,'processes':3,'formalAcceptance':False,'commands':records},indent=2)+'\n')
            print(process,n,v,'us',*[round(x,4) for x in rec['medianPhaseUs']],'EigenRatio',*[round(x,4) for x in rec['medianPhaseRatio']],flush=True)
