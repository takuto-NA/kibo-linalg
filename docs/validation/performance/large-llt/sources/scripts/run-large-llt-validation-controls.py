from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/large-llt-validation-cost');out.mkdir(exist_ok=True)
cases=[(n,n*4,v) for n in [128,512] for v in ['public_large','validation_none','validation_no_sym','validation_no_finite','validation_fused','small_frame_split']]
cases += [(n,n*4,v) for n in [2,8,32,64] for v in ['public_large','small_frame_split']]
cases += [(n,n*4,'packed_setup') for n in [2,8,32]]
records=[]
for n,m,v in cases:
    exe=Path(f'build/large-llt-next/Release/{v}.exe');cmd=[str(exe),str(n),'5',str(m),'0']
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert r.returncode==0,(cmd,r.returncode,r.stderr)
    dest=out/f'{v}-n{n}-m{m}.jsonl';dest.write_bytes(r.stdout)
    rows=[json.loads(s) for s in r.stdout.splitlines()]
    assert len(rows)==20 and all(s['minBatch']>=.02 and s['coreType']==64 and s['packetWidth']==2 for s in rows)
    rec={'command':cmd,'output':dest.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
         'contractPreserved':v not in ['validation_none','validation_no_sym','validation_no_finite'],
         'medianPhaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
         'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
    records.append(rec);(out/'manifest.json').write_text(json.dumps({'publicCodeCommit':'48439196aa80f5c2678e8b7a15c1bf4cfcb438b5','samples':5,'processes':1,'formalAcceptance':False,'commands':records},indent=2)+'\n')
    print(n,v,'us',*[round(x,4) for x in rec['medianPhaseUs']],'EigenRatio',*[round(x,4) for x in rec['medianPhaseRatio']],flush=True)
