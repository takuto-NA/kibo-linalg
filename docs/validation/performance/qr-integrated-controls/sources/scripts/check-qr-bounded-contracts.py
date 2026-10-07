from pathlib import Path
import hashlib,json,subprocess

out=Path('.scratch/qr-bounded-validation');out.mkdir(exist_ok=True);records=[]
for variant in ['column_work_packet_local','column_work_bounded']:
    for test in ['qr','qr_refined']:
        for mode in ['simd','scalar']:
            name=f'{variant}_{test}_{mode}';exe=Path(f'build/qr-bounded-contracts/Release/{name}.exe')
            r=subprocess.run([str(exe)],stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            (out/f'{name}.log').write_bytes(r.stdout)
            records.append({'command':[str(exe)],'exitCode':r.returncode,'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest()})
            print(name,r.returncode,flush=True);assert r.returncode==0,r.stdout.decode(errors='replace')[-3000:]
    exe=Path(f'build/qr-bounded-contracts/Release/{variant}_audit.exe')
    r=subprocess.run([str(exe)],stdout=subprocess.PIPE,stderr=subprocess.PIPE);assert r.returncode==0,r.stderr
    raw=out/f'{variant}.jsonl';raw.write_bytes(r.stdout)
    subprocess.run(['python','tools/diagnostics/qr-accuracy/oracle.py',str(raw)],check=True)
    rows=[json.loads(s) for s in raw.read_text().splitlines()];oracle=json.loads(raw.with_suffix('.oracle.json').read_text());assert len(rows)==len(oracle)==102
    for r,o in zip(rows,oracle):
        assert r['publicRefinedStatus']==0 and r['status']==0 and r['rank']==r['n']
        bound=1e-8 if r['condition']<=1e4 else 1e-4
        assert o['solutions']['publicRefined']['truthForward']<=bound,(variant,r['id'],o)
        gate=100*2.220446049250313e-16*max(r['m'],r['n'])
        assert o['solutions']['publicRefined']['optimality']<=gate
        if not r['inconsistent']:assert o['solutions']['publicRefined']['backward']<=gate
    record={'variant':variant,'records':len(rows),'allRefinedGatesPass':True,
            'maxOracleForward':max(o['solutions']['publicRefined']['oracleForward'] for o in oracle),
            'maxOptimality':max(o['solutions']['publicRefined']['optimality'] for o in oracle),
            'auditBinarySha256':hashlib.sha256(exe.read_bytes()).hexdigest()}
    records.append(record);print(json.dumps(record),flush=True)
(out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
