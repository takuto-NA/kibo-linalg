from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/llt-fixed8-controls');out.mkdir(exist_ok=True)
hashes={name:hashlib.sha256(Path(f'build/large-llt-next/Release/{name}.exe').read_bytes()).hexdigest() for name in ['public_large','fixed8']}
records=[]
for process in range(3):
    for n,m in [(31,124),(32,128),(33,132),(128,128),(128,512),(512,2048)]:
        for name in (['public_large','fixed8'] if process%2==0 else ['fixed8','public_large']):
            cmd=[f'build/large-llt-next/Release/{name}.exe',str(n),'5',str(m),str(process)]
            r=subprocess.run(cmd,capture_output=True);assert r.returncode==0,(cmd,r.stderr)
            rows=[json.loads(s) for s in r.stdout.splitlines()];assert len(rows)==20 and all(s['minBatch']>=.02 and s['coreType']==64 and s['packetWidth']==2 for s in rows)
            file=out/f'{name}-n{n}-m{m}-process{process}.jsonl';file.write_bytes(r.stdout)
            record={'command':cmd,'file':file.name,'binarySha256':hashes[name],
                    'phaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
                    'phaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
            records.append(record)
            (out/'commands.json').write_text(json.dumps({'processes':3,'samples':5,'formalAcceptance':False,'commands':records},indent=2)+'\n')
            print(process,n,m,name,'us',*[round(x,4) for x in record['phaseUs']],'ratios',*[round(x,4) for x in record['phaseRatio']],flush=True)
