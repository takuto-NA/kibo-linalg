from pathlib import Path
import gzip,hashlib,json,shutil,statistics,subprocess

root=Path.cwd();source=root/'.scratch/qr-combined-controls';out=root/'docs/validation/performance/qr-combined-controls'
out.mkdir(parents=True,exist_ok=True)
manifest=json.loads((source/'manifest.json').read_text());records=manifest['commands'];assert len(records)==240
def put(path,dest):
    dest=out/dest;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,dest)
for path in source.glob('*'):
    if path.is_file():put(path,Path('timings')/path.name)
summaries=[]
keys=sorted({(int(r['command'][1]),Path(r['command'][0]).stem) for r in records})
for n,name in keys:
    group=[r for r in records if int(r['command'][1])==n and Path(r['command'][0]).stem==name];assert len(group)==3
    hashes=set()
    for r in group:
        rows=[json.loads(s) for s in (source/r['file']).read_text().splitlines()]
        assert len(rows)==20 and all(s['minBatch']>=.02 and s['packetWidth']==2 and s['coreType']==64 and s['numericBytesBound']<=64*1024*1024 for s in rows)
        hashes.update(s['inputHash'] for s in rows)
    assert len(hashes)==1
    summaries.append({'n':n,'m':4*n,'variant':name,'inputHash':next(iter(hashes)),
                      'medianPhaseUs':[statistics.median(r['medianPhaseUs'][i] for r in group) for i in range(4)],
                      'medianPhaseRatio':[statistics.median(r['medianPhaseRatio'][i] for r in group) for i in range(4)]})
for n in [2,8,32,128,512]:assert len({s['inputHash'] for s in summaries if s['n']==n})==1
(out/'summary.json').write_text(json.dumps({'formalAcceptance':False,'processes':3,'samples':5,'statistics':'median of process medians; paired sample ratio then process median','rows':summaries},indent=2)+'\n')
for path in (root/'.scratch/qr-combined-objects').glob('*'):
    if path.name.endswith('-full.txt'):
        dest=out/'objects'/(path.name+'.gz');dest.parent.mkdir(exist_ok=True)
        with dest.open('wb') as f:
            with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as compressed:compressed.write(path.read_bytes())
    else:put(path,Path('objects')/path.name)
commit=manifest['publicCodeCommit']
public=json.loads((root/'.scratch/qr-combined-objects/manifest.json').read_text())['public_qr_column']['files']
for path in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include/kibo'],text=True).splitlines():
    data=subprocess.check_output(['git','show',f'{commit}:{path}'])
    if path in public:data=next(s for s in [data,data.replace(b'\n',b'\r\n')] if hashlib.sha256(s).hexdigest()==public[path])
    dest=out/'sources/variants/baseline'/Path(path).relative_to('include');dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
variants=['adaptive_vector','certified_norm','force_project','combo_scalar_norm','combo_vector_norm','combo_certified_norm','combo_force_project']
for name in variants:shutil.copytree(root/f'.scratch/qr-next/variants/{name}',out/f'sources/variants/{name}',dirs_exist_ok=True)
for name in ['full-adaptive.cpp']:put(root/'.scratch/qr-next'/name,Path('sources')/name)
for name in ['tests/controlled_fixture.hpp','tools/diagnostics/solver-locality/affinity.hpp','build/qr-next/CMakeCache.txt']:
    put(root/name,Path('sources')/name)
cm='cmake_minimum_required(VERSION 3.30)\nproject(qr_combined_controls LANGUAGES CXX)\n'
for name in sorted({Path(r['command'][0]).stem for r in records}):
    variant=name.rsplit('_column',1)[0] if name.endswith('_column') else name.rsplit('_row_best',1)[0]
    folder='baseline' if variant=='public_qr' else variant;defs='QR_COLUMN=1' if name.endswith('_column') else ''
    cm+=f'''add_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{folder} tests "${{EIGEN_SOURCE_DIR}}")
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
cm=cm.replace('project(qr_combined_controls LANGUAGES CXX)\n','project(qr_combined_controls LANGUAGES CXX)\nset(EIGEN_SOURCE_DIR "" CACHE PATH "Pinned Eigen headers")\n')
# The archived harness's affinity include expects ../../tools from its build-source location.
h=(out/'sources/full-adaptive.cpp').read_text().replace('../../tools/diagnostics/solver-locality/affinity.hpp','tools/diagnostics/solver-locality/affinity.hpp')
(out/'sources/full-adaptive-repro.cpp').write_text(h)
(out/'sources/CMakeLists.txt').write_text(cm.replace(' full-adaptive.cpp)',' full-adaptive-repro.cpp)'))
for name in ['run-qr-combined-controls.py','prepare-qr-combined-controls.py','prepare-qr-adaptive-norm-control.py','prepare-qr-exponent-check-control.py','prepare-qr-strided-solve-controls.py','disassemble-qr-combined.py','freeze-qr-combined-controls.py','cmake-safe.py']:
    put(root/'.scratch'/name,Path('sources/scripts')/name)
checksums={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'files,240 executions')
for s in summaries:print(s['n'],s['variant'],'us',*[round(x,4) for x in s['medianPhaseUs']],'ratio',*[round(x,4) for x in s['medianPhaseRatio']])
