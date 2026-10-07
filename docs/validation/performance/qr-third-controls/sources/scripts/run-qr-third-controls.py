from pathlib import Path
import hashlib,json,statistics,subprocess

out=Path('.scratch/qr-third-controls');out.mkdir(exist_ok=True);records=[]
for process in range(3):
    for n in [8,32,128,512]:
        for layout in ['column','row_best']:
            variants=['public_qr','householder_divide','householder_recip']
            if layout=='row_best':
                variants+=['project_four_4','update_four_4','both_four_4']
                if n>=32:variants+=['panel_solve_4','panel_solve_8']
                if n==512:variants+=['padded_1','padded_8','padded_16']
            for variant in (variants if process%2==0 else list(reversed(variants))):
                name=f'{variant}_{layout}';exe=Path(f'build/qr-next/Release/{name}.exe');cmd=[str(exe),str(n),'5',str(4*n),str(process)]
                result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
                assert result.returncode==0,(cmd,result.returncode,result.stderr)
                rows=[json.loads(s) for s in result.stdout.splitlines()]
                assert len(rows)==20 and all(s['minBatch']>=.02 and s['packetWidth']==2 and s['coreType']==64 and s['numericBytesBound']<=64*1024*1024 for s in rows)
                file=out/f'{name}-n{n}-m{4*n}-process{process}.jsonl';file.write_bytes(result.stdout)
                record={'command':cmd,'file':file.name,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
                        'packedRowStride':n+int(variant.split('_')[1]) if variant.startswith('padded_') else (1 if layout=='column' else n),
                        'medianPhaseUs':[statistics.median(s['core'] for s in rows if s['phase']==i)*1e6 for i in range(4)],
                        'medianPhaseRatio':[statistics.median(s['core']/s['eigen'] for s in rows if s['phase']==i) for i in range(4)]}
                records.append(record)
                (out/'manifest.json').write_text(json.dumps({'publicCodeCommit':'19e210aeb990e32b25ba5d7639c5d5969a519402','samples':5,'processes':3,'formalAcceptance':False,'commands':records},indent=2)+'\n')
                print(process,n,layout,variant,'us',*[round(x,4) for x in record['medianPhaseUs']],'ratio',*[round(x,4) for x in record['medianPhaseRatio']],flush=True)
