from pathlib import Path
import hashlib,json,shutil,statistics,subprocess
root=Path.cwd();out=root/'docs/validation/performance/qr-first-controls'
def put(source,dest):
    dest=out/dest;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest)
summaries=[]
for label,folder,expected in [('baseline','qr-next-baseline',30),('controls','qr-next-controls',129)]:
    source=root/'.scratch'/folder;manifest=json.loads((source/'manifest.json').read_text());records=manifest['commands'];assert len(records)==expected
    for p in source.glob('*'):
        if p.is_file():put(p,Path(label)/p.name)
    keys=sorted({(int(r['command'][1]),int(r['command'][3]),Path(r['command'][0]).stem) for r in records})
    for n,m,name in keys:
        group=[r for r in records if int(r['command'][1])==n and int(r['command'][3])==m and Path(r['command'][0]).stem==name]
        assert len(group)==(1 if label=='baseline' else 3)
        hashes=set()
        for r in group:
            rows=[json.loads(s) for s in (source/r['file']).read_text().splitlines()]
            assert len(rows)==20 and all(s['minBatch']>=.02 and s['packetWidth']==2 and s['coreType']==64 and s['numericBytesBound']<=64*1024*1024 for s in rows)
            hashes.update(s['inputHash'] for s in rows)
        assert len(hashes)==1
        summaries.append({'series':label,'n':n,'m':m,'variant':name,'inputHash':next(iter(hashes)),
                          'medianPhaseUs':[statistics.median(r['medianPhaseUs'][i] for r in group) for i in range(4)],
                          'medianPhaseRatio':[statistics.median(r['medianPhaseRatio'][i] for r in group) for i in range(4)]})
for n,m in {(s['n'],s['m']) for s in summaries}:assert len({s['inputHash'] for s in summaries if (s['n'],s['m'])==(n,m)})==1
(out/'summary.json').write_text(json.dumps({'formalAcceptance':False,'baselineProcesses':1,'controlProcesses':3,'samples':5,'statistics':'median of process medians; paired sample ratio then process median','rows':summaries},indent=2)+'\n')
for label,folder in [('finite-objects','qr-next-objects'),('norm-row-objects','qr-norm-row-objects')]:
    for p in (root/'.scratch'/folder).glob('*'):
        if p.name=='manifest.json' or p.name.endswith('-full.txt') or any(x in p.name for x in ['-factorize_qr-','-solve_into-','-column_norm-','-qr_input_finite-','-row_update_checked-','-row_update_four_checked-','-column_project_four-','-computeInPlace-']):
            put(p,Path(label)/p.name)
commit='19e210aeb990e32b25ba5d7639c5d5969a519402'
manifest=json.loads((root/'.scratch/qr-next-objects/manifest.json').read_text())
for path in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include/kibo'],text=True).splitlines():
    data=subprocess.check_output(['git','show',f'{commit}:{path}']);expected=manifest['public_qr_column']['files'].get(path)
    if expected:data=next(s for s in [data,data.replace(b'\n',b'\r\n')] if hashlib.sha256(s).hexdigest()==expected)
    dest=out/'sources/baseline'/Path(path).relative_to('include');dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
for name in ['point_finite','packet_input','both_finite','norm_column','norm_all','row_update_four']:
    shutil.copytree(root/f'.scratch/qr-next/variants/{name}',out/f'sources/{name}',dirs_exist_ok=True)
for name in ['full-adaptive.cpp','CMakeLists.txt']:put(root/'.scratch/qr-next'/name,Path('sources/scripts')/('CMakeLists-as-built.txt' if name=='CMakeLists.txt' else name))
cm=(root/'.scratch/qr-next/CMakeLists.txt').read_text().replace('PRIVATE ../../include ../../tests','PRIVATE variants/baseline ../../tests')
(out/'sources/scripts/CMakeLists.txt').write_text(cm)
for name in ['run-qr-next-baseline.py','run-qr-next-controls.py','prepare-qr-input-control.py','prepare-qr-norm-row-controls.py','disassemble-qr-next.py','disassemble-qr-norm-row.py','cmake-safe.py','freeze-qr-first-controls.py']:
    put(root/'.scratch'/name,Path('sources/scripts')/name)
for name in ['tests/controlled_fixture.hpp','tools/diagnostics/solver-locality/affinity.hpp','build/qr-next/CMakeCache.txt']:
    put(root/name,Path('sources')/name)
checksums={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'files,159 executions,matching input hashes and <=64MiB capacity')
for s in summaries:
    if s['series']=='controls':print(s['n'],s['variant'],'us',*[round(x,4) for x in s['medianPhaseUs']],'ratio',*[round(x,4) for x in s['medianPhaseRatio']])
