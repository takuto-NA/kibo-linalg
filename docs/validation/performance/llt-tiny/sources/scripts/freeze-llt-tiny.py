from pathlib import Path
import hashlib,json,re,shutil,subprocess
root=Path.cwd();out=root/'docs/validation/performance/llt-tiny'
def put(source,target):
    target=out/target;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,target)
for label,folder in [('wide-panel-controls','llt-final-controls'),('copy-tiny-controls','llt-copy-tiny-controls')]:
    for p in (root/'.scratch'/folder).glob('*'):
        if p.is_file():put(p,Path(label)/p.name)
for label,folder in [('wide-panel-objects','llt-final-controls-objects'),('copy-tiny-objects','llt-copy-tiny-objects')]:
    for p in (root/'.scratch'/folder).glob('*'):
        if p.name=='manifest.json' or p.name.endswith('-full.txt') or any(x in p.name for x in ['-factorize_llt-','-factorize_column_llt-','-solve_into-','-main-']):
            put(p,Path(label)/p.name)
commit='19e210aeb990e32b25ba5d7639c5d5969a519402'
manifest=json.loads((root/'.scratch/llt-copy-tiny-objects/manifest.json').read_text())
for path in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include/kibo'],text=True).splitlines():
    data=subprocess.check_output(['git','show',f'{commit}:{path}'])
    expected=manifest['public_large']['files'].get(path)
    if expected:
        data=next(s for s in [data,data.replace(b'\n',b'\r\n')] if hashlib.sha256(s).hexdigest()==expected)
    dest=out/'sources/baseline'/Path(path).relative_to('include');dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
variants=['view_wide_product','panel4','panel4_small','copy_tile8','tiny_factor','tiny_solve','tiny_both']
for name in variants:shutil.copytree(root/f'.scratch/large-llt-next/variants/{name}',out/f'sources/{name}',dirs_exist_ok=True)
for name in ['run-llt-final-controls.py','run-llt-copy-tiny-controls.py','prepare-view-wide-product-control.py','prepare-llt-panel4-control.py',
             'prepare-llt-copy-and-tiny-controls.py','prepare-wide-product-contract.py','disassemble-llt-final-controls.py','disassemble-llt-copy-tiny.py','llt-tiny-native.py','llt-tiny-linux.py','llt-tiny-linux.sh','cmake-safe.py','freeze-llt-tiny.py']:
    put(root/'.scratch'/name,Path('sources/scripts')/name)
for name in ['full-adaptive.cpp','uninitialized-setup.cpp']:put(root/'.scratch/large-llt-next'/name,Path('sources/scripts')/name)
put(root/'.scratch/large-llt-next/CMakeLists.txt',Path('sources/scripts/CMakeLists-as-built.txt'))
cm='''cmake_minimum_required(VERSION 3.30)
project(llt_tiny_reproduce LANGUAGES CXX)
if(NOT MSVC)
  message(FATAL_ERROR "The assembly comparison uses MSVC on Windows")
endif()
'''
targets={'public_large':('baseline','full-adaptive.cpp'),'uninitialized_setup':('baseline','uninitialized-setup.cpp')}
for name in variants:targets[name]=(name,'full-adaptive.cpp')
targets['view_wide_product_uninitialized']=('view_wide_product','uninitialized-setup.cpp')
targets['tiny_both_uninitialized']=('tiny_both','uninitialized-setup.cpp')
for name,(variant,source) in targets.items():
    cm+=f'''
add_executable({name} {source})
target_compile_features({name} PRIVATE cxx_std_20)
target_include_directories({name} PRIVATE variants/{variant} ../../tests ../../.cache/eigen)
target_compile_definitions({name} PRIVATE EIGEN_DONT_PARALLELIZE=1)
target_compile_options({name} PRIVATE /O2 /fp:precise /FAs "/Fa${{CMAKE_CURRENT_BINARY_DIR}}/{name}.asm")
'''
cm+='''
add_executable(view_wide_product_contract ../../tests/matrix_view_tests.cpp)
target_compile_features(view_wide_product_contract PRIVATE cxx_std_20)
target_include_directories(view_wide_product_contract PRIVATE variants/view_wide_product)
target_compile_options(view_wide_product_contract PRIVATE /W4 /permissive-)
'''
(out/'sources/scripts/CMakeLists.txt').write_text(cm)
exe=root/'build/large-llt-next/Release/view_wide_product_contract.exe'
result=subprocess.run([str(exe)],stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
assert result.returncode==0
(out/'wide-product-contract.json').write_text(json.dumps({'command':[str(exe.relative_to(root))],'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'exitCode':result.returncode,'output':result.stdout.decode()},indent=2)+'\n')
audit=[]
for p in sorted((root/'.scratch/llt-tiny-validation').rglob('*ctest.log')):
    s=p.read_text(errors='replace');failures=[x for x in s.splitlines() if x.startswith('line ')]
    failed=re.findall(r'\d+ - (\w+) \(Failed\)',s)
    assert len(failures)==16 and all(x.startswith(('line 85:','line 126:')) for x in failures),(p,failures)
    assert set(failed)=={'numerical','numerical_column'},(p,failed)
    audit.append({'file':p.relative_to(root/'.scratch/llt-tiny-validation').as_posix(),'failures':16,'eigenOnly':True,'failedTests':failed})
assert len(audit)==8,len(audit)
for p in (root/'.scratch/llt-tiny-validation').rglob('*'):
    if p.is_file():put(p,Path('validation')/p.relative_to(root/'.scratch/llt-tiny-validation'))
(out/'validation/failure-set.json').write_text(json.dumps(audit,indent=2)+'\n')
for folder in ['include','tests']:
    for p in (root/folder).rglob('*'):
        if p.is_file():put(p,Path('public-source')/p.relative_to(root))
put(root/'CMakeLists.txt',Path('public-source/CMakeLists.txt'))
summary=[]
for label in ['wide-panel-controls','copy-tiny-controls']:
    records=json.loads((out/label/'manifest.json').read_text())['commands']
    keys=sorted({(int(r['command'][1]),int(r['command'][3]),Path(r['command'][0]).stem) for r in records})
    for n,m,name in keys:
        selected=[r for r in records if int(r['command'][1])==n and int(r['command'][3])==m and Path(r['command'][0]).stem==name]
        assert len(selected)==3
        summary.append({'series':label,'n':n,'m':m,'variant':name,'medianPhaseUs':[__import__('statistics').median(r['medianPhaseUs'][i] for r in selected) for i in range(4)],
                        'medianPhaseRatio':[__import__('statistics').median(r['medianPhaseRatio'][i] for r in selected) for i in range(4)]})
(out/'summary.json').write_text(json.dumps({'formalAcceptance':False,'processes':3,'samples':5,'rows':summary},indent=2)+'\n')
checksums={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'files; all eight PC sets preserve exactly sixteen Eigen-only CHECKs')
