from pathlib import Path
import gzip,hashlib,json,re,shutil,subprocess
root=Path.cwd();out=root/'docs/validation/performance/qr-integrated-controls'
out.mkdir(parents=True,exist_ok=True)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def put(src,dest):
    dest=out/dest;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dest)
variants=set();targets={};executions=0;baseline_hashes={}
for group,count in [('layout',21),('triangular',10),('bounded',17),('final',20)]:
    source=root/f'.scratch/qr-{group}-controls'
    data=json.loads((source/'manifest.json').read_text());assert len(data['commands'])==count
    executions+=count
    for path in source.glob('*'):
        if path.is_file():put(path,Path(group)/'timings'/path.name)
    objects=root/f'.scratch/qr-{group}-objects'
    records=json.loads((objects/'manifest.json').read_text())
    for name,record in records.items():
        variant=re.sub(r'_(column|row_same|row_best)$','',name)
        targets[name]='baseline' if variant=='public_qr' else variant
        if variant!='public_qr':variants.add(variant)
        else:
            baseline_hashes.update({p.replace('\\','/'):d for p,d in record['files'].items() if p.replace('\\','/').startswith('include/')})
        for filename,digest in record['files'].items():
            path=root/filename
            if '/variants/' in path.as_posix() or path.name=='full-adaptive.cpp':assert sha(path)==digest,path
    for path in objects.glob('*'):
        if path.name.endswith('-full.txt'):
            dest=out/group/'objects'/(path.name+'.gz');dest.parent.mkdir(parents=True,exist_ok=True)
            with dest.open('wb') as f:
                with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write(path.read_bytes())
        else:put(path,Path(group)/'objects'/path.name)
    quality=root/f'.scratch/qr-{group}-validation'
    if quality.exists():
        for path in quality.glob('*'):
            if path.is_file():put(path,Path(group)/'quality'/path.name)
commit='19e210aeb990e32b25ba5d7639c5d5969a519402'
for name in variants:shutil.copytree(root/f'.scratch/qr-next/variants/{name}',out/f'sources/variants/{name}',dirs_exist_ok=True)
for path in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include/kibo'],text=True).splitlines():
    dest=out/'sources/variants/baseline'/Path(path).relative_to('include');dest.parent.mkdir(parents=True,exist_ok=True)
    data=subprocess.check_output(['git','show',f'{commit}:{path}'])
    if path in baseline_hashes:
        data=next(x for x in [data,data.replace(b'\n',b'\r\n')] if hashlib.sha256(x).hexdigest()==baseline_hashes[path])
    dest.write_bytes(data)
for name in ['tests/controlled_fixture.hpp','tools/diagnostics/solver-locality/affinity.hpp']:
    put(root/name,Path('sources')/name)
h=(root/'.scratch/qr-next/full-adaptive.cpp').read_text().replace('../../tools/diagnostics/solver-locality/affinity.hpp','tools/diagnostics/solver-locality/affinity.hpp')
(out/'sources/full-adaptive.cpp').write_text(h)
cm='cmake_minimum_required(VERSION 3.30)\nproject(qr_integrated_controls LANGUAGES CXX)\nset(EIGEN_SOURCE_DIR "" CACHE PATH "Pinned Eigen headers")\n'
for name,variant in sorted(targets.items()):
    defs='QR_COLUMN=1' if name.endswith('_column') else ('EIGEN_ROW=1' if name.endswith('_row_same') else '')
    cm+=f'''add_executable({name} full-adaptive.cpp)
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{variant} tests "${{EIGEN_SOURCE_DIR}}")
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1 {defs})
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
(out/'sources/CMakeLists.txt').write_text(cm)
for path in (root/'.scratch').glob('*.py'):
    if re.search(r'(prepare|run|disassemble|check|freeze)-qr-(row-norm-flat|column-work|layout|triangular|bounded|final|restore-packet|integrated)',path.name):put(path,Path('sources/scripts')/path.name)
for name in ['qr-restore-check.cpp','qr-restore-packet.inc','cmake-safe.py']:
    put(root/'.scratch'/name,Path('sources/scripts')/name)
metadata={'baselineCommit':commit,'executions':executions,'processes':1,'samples':5,'formalAcceptance':False,
          'variants':sorted(variants),'targets':targets,
          'limitations':['Private controls precede the public triangular overflow retry and final regressions.',
                         'Diagnostic timing is not final 5-process/30-sample acceptance.',
                         'COFF disassembly is actual compiled object code; hardware counters were not measured.']}
(out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
checksums={p.relative_to(out).as_posix():sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'files;',executions,'executions;',len(variants),'variants')
