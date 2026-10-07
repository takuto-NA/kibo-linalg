from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/llt-final-controls');out.mkdir(exist_ok=True)
cases=[(2,2,['public_large','view_wide_product','uninitialized_setup','view_wide_product_uninitialized']),
       (2,8,['public_large','view_wide_product','uninitialized_setup','view_wide_product_uninitialized']),
       (8,32,['public_large','view_wide_product']),
       (32,128,['public_large','view_wide_product']),
       (128,128,['public_large','panel4','panel4_small']),
       (128,512,['public_large','panel4','panel4_small']),
       (512,2048,['public_large','panel4','panel4_small'])]
records=[]
for process in range(3):
    for n,m,variants in cases:
        for name in (variants if process%2==0 else list(reversed(variants))):
            exe=Path(f'build/large-llt-next/Release/{name}.exe');cmd=[str(exe),str(n),'5',str(m),str(process)]
            result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert result.returncode==0,(cmd,result.returncode,result.stderr)
            rows=[json.loads(s) for s in result.stdout.splitlines()]
            assert len(rows)==20 and all(s['minBatch']>=.02 and s['packetWidth']==2 and s['coreType']==64 for s in rows)
            file=out/f'{name}-n{n}-m{m}-process{process}.jsonl';file.write_bytes(result.stdout)
            record={'command':cmd,'file':file.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
                    'medianPhaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
                    'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
            records.append(record)
            (out/'manifest.json').write_text(json.dumps({'publicCodeCommit':'19e210aeb990e32b25ba5d7639c5d5969a519402','samples':5,'processes':3,'formalAcceptance':False,'commands':records},indent=2)+'\n')
            print(process,n,m,name,'us',*[round(x,4) for x in record['medianPhaseUs']],'ratio',*[round(x,4) for x in record['medianPhaseRatio']],flush=True)
