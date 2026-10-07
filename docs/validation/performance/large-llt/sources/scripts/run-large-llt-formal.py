from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/large-llt-formal');out.mkdir(exist_ok=True)
cases=[(2,2),(2,8),(32,128),(64,256),(128,128),(128,512),(512,512),(512,2048)]
records=[]
for process in range(5):
    order=['actual','public_large'] if process%2==0 else ['public_large','actual']
    for n,m in cases:
        for variant in order:
            exe=Path(f'build/large-llt-next/Release/{variant}.exe')
            cmd=[str(exe),str(n),'30',str(m),str(process)]
            r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert r.returncode==0,(cmd,r.returncode,r.stderr)
            dest=out/f'{variant}-n{n}-m{m}-process{process}.jsonl';dest.write_bytes(r.stdout)
            rows=[json.loads(s) for s in r.stdout.splitlines()]
            assert len(rows)==120 and all(s['minBatch']>=.02 and s['coreType']==64 and s['packetWidth']==2 for s in rows)
            record={'command':cmd,'file':dest.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
                'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==phase) for phase in range(4)]}
            records.append(record)
            (out/'commands.json').write_text(json.dumps({'publicCodeCommit':'48439196aa80f5c2678e8b7a15c1bf4cfcb438b5',
                'baselineCodeCommit':'8fe28e552bfc485c4744a193cc9e677b3e2ce309','processes':5,'samples':30,
                'commands':records},indent=2)+'\n')
            print('process',process,'n',n,'m',m,variant,'phase ratios',*[round(x,3) for x in record['medianPhaseRatio']],flush=True)
