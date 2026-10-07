from pathlib import Path
import hashlib,json,statistics,subprocess
out=Path('.scratch/qr-triangular-controls');out.mkdir(exist_ok=True);records=[]
cases=[]
for n in [128,512]:
    for name in ['combo_certified_norm_column','triangular_stream_column','column_work_8_row_best','column_work_triangular_row_best','column_work_packet_row_best']:
        cases.append((n,name))
for n,name in cases:
    exe=Path(f'build/qr-next/Release/{name}.exe');cmd=[str(exe),str(n),'5',str(4*n),'0']
    result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert result.returncode==0,(cmd,result.returncode,result.stderr)
    rows=[json.loads(s) for s in result.stdout.splitlines()]
    assert len(rows)==20 and all(s['minBatch']>=.02 and s['packetWidth']==2 and s['coreType']==64 and s['numericBytesBound']<=64*1024*1024 for s in rows)
    file=out/f'{name}-n{n}-m{4*n}-process0.jsonl';file.write_bytes(result.stdout)
    record={'command':cmd,'file':file.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
            'medianPhaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
            'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
    records.append(record)
    (out/'manifest.json').write_text(json.dumps({'publicCodeCommit':'19e210aeb990e32b25ba5d7639c5d5969a519402','samples':5,'processes':1,'formalAcceptance':False,'commands':records},indent=2)+'\n')
    print(n,name,'us',*[round(x,4) for x in record['medianPhaseUs']],'ratio',*[round(x,4) for x in record['medianPhaseRatio']],flush=True)
