from pathlib import Path
import hashlib,json,statistics,subprocess
commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
assert not subprocess.check_output(['git','status','--porcelain','--','include','tests','CMakeLists.txt']).strip()
out=Path('.scratch/llt-store-formal');out.mkdir(exist_ok=True)
cases=[(2,2),(2,8),(8,32),(31,124),(32,128),(33,132),(64,256),(128,128),(128,512),(512,512),(512,2048)]
records=[]
for process in range(5):
    for n,m in cases:
        variants=['before_store','public_large']
        if n==2:variants.append('uninitialized_setup')
        for variant in (variants if process%2==0 else list(reversed(variants))):
            exe=Path(f'build/large-llt-next/Release/{variant}.exe');cmd=[str(exe),str(n),'30',str(m),str(process)]
            r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert r.returncode==0,(cmd,r.returncode,r.stderr)
            dest=out/f'{variant}-n{n}-m{m}-process{process}.jsonl';dest.write_bytes(r.stdout)
            rows=[json.loads(s) for s in r.stdout.splitlines()]
            assert len(rows)==120 and all(s['minBatch']>=.02 and s['coreType']==64 and s['packetWidth']==2 for s in rows)
            record={'command':cmd,'file':dest.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
                    'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
            records.append(record)
            (out/'commands.json').write_text(json.dumps({'publicCodeCommit':commit,'baselineCodeCommit':'2f23d66af38fe4aed42811cdf6438af73de620c5','samples':30,'processes':5,'originalSetupPolicy':'four independent initialized buffers','uninitializedSetupPolicy':'three allocations, disjoint factor/work in one arena, separate answer, fully overwritten buffers uninitialized','commands':records},indent=2)+'\n')
            print('process',process,'n',n,'m',m,variant,'phase ratios',*[round(x,4) for x in record['medianPhaseRatio']],flush=True)
