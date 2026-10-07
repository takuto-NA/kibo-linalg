from pathlib import Path
import gzip,hashlib,json,shutil,subprocess
root=Path.cwd();scratch=root/'.scratch/qr-optimized-public';out=root/'docs/validation/numerical/qr-optimized-public'
out.mkdir(parents=True,exist_ok=True)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def put(source,target):
    dest=out/target;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,dest)
checks=json.loads((scratch/'oracle-summary.json').read_text());assert len(checks)==7 and all(s['allPublicGatesPass'] and s['records']==102 for s in checks)
for section,count in [('linux-commands.json',3),('portability/commands.json',5)]:
    commands=json.loads((scratch/section).read_text());assert len(commands)==count and all(c['exitCode']==0 for c in commands),section
assert all(c['exitCode']==0 for c in json.loads((scratch/'native/package-commands.json').read_text()))
audits=[]
for log in sorted(scratch.rglob('*ctest.log')):
    text=log.read_text(errors='replace');failures=[s for s in text.splitlines() if s.startswith('line ')]
    assert len(failures)==16 and all(s.startswith('line 85: (reference-expected)') or s.startswith('line 126: (reference-fixture.truth)') for s in failures),log
    assert '89% tests passed, 2 tests failed out of 19' in text,log
    audits.append({'file':log.relative_to(scratch).as_posix(),'onlyUnchangedEigenChecksFail':True,'failureCount':16,
                   'nativeReleaseAllocationSkipped':'allocation (Skipped)' in text})
assert len(audits)==8
for path in sorted(scratch.rglob('*')):
    if path.is_file():put(path,Path('local')/path.relative_to(scratch))
scripts=['qr-optimized-native.py','qr-optimized-linux.py','qr-optimized-linux.sh','qr-optimized-portable.py','qr-optimized-package.py',
         'check-qr-optimized-oracles.py','freeze-qr-optimized-public.py','disassemble-qr-optimized.py','cmake-safe.py']
for name in scripts:put(root/'.scratch'/name,Path('commands')/name)
for name in ['main.cpp','CMakeLists.txt']:put(root/'.scratch/qr-overflow-repro'/name,Path('overflow-repro')/name)
sources={};commit=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
for base in ['include/kibo','tests','wasm','examples']:
    for path in sorted((root/base).rglob('*')):
        if not path.is_file() or path.suffix not in ['.hpp','.cpp','.py','.txt','.md','.mjs']:continue
        if 'node_modules' in path.parts:continue
        name=path.relative_to(root).as_posix();blob=subprocess.check_output(['git','show',commit+':'+name])
        assert path.read_bytes().replace(b'\r\n',b'\n')==blob.replace(b'\r\n',b'\n'),name
        put(path,Path('sources')/name);sources[name]=sha(path)
for name in ['CMakeLists.txt','tools/toolchains.lock.json','tools/wasm-build.sh','tools/diagnostics/qr-accuracy/audit.cpp','tools/diagnostics/qr-accuracy/oracle.py',
             'tools/diagnostics/qr-accuracy/CMakeLists.txt','tools/diagnostics/qr-accuracy/refine.hpp',
             'tools/diagnostics/solver-locality/affinity.hpp','benchmarks/lm_reference.cpp']:
    put(root/name,Path('sources')/name);sources[name]=sha(root/name)
put(root/'.scratch/qr-next/full-adaptive.cpp','sources/full-adaptive.cpp')
objects=root/'.scratch/qr-optimized-objects';manifest=json.loads((objects/'manifest.json').read_text())
assert len(manifest)==3
for record in manifest.values():
    for filename,digest in record['files'].items():assert sha(root/filename)==digest,filename
for path in objects.glob('*'):
    if path.name.endswith('-full.txt'):
        dest=out/'objects'/(path.name+'.gz');dest.parent.mkdir(exist_ok=True)
        with dest.open('wb') as f:
            with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write(path.read_bytes())
    else:put(path,Path('objects')/path.name)
builds={}
for compiler in ['gcc','clang','clang-sanitized']:
    for scalar in ['OFF','ON']:
        directory=root/f'build/qr-refined-audit-{compiler}-{scalar}';tag=compiler+'-'+scalar
        builds[tag]={'binarySha256':sha(directory/'audit')}
        for file in ['compile_commands.json','CMakeCache.txt']:put(directory/file,Path('builds')/(tag+'-'+file))
    for config in ['Debug','Release']:
        directory=root/f'build/qr-refined-{compiler}/{config}';tag=compiler+'-'+config
        for file in ['compile_commands.json','CMakeCache.txt','Testing/Temporary/LastTestsFailed.log']:
            put(directory/file,Path('builds')/(tag+'-'+Path(file).name))
        failed=(directory/'Testing/Temporary/LastTestsFailed.log').read_text().splitlines()
        assert failed==['2:numerical','3:numerical_column'],(tag,failed)
for name in ['CMakeCache.txt','kibo_qr_tests.vcxproj','kibo_qr_scalar_tests.vcxproj','kibo_no_runtime_tests.vcxproj']:
    put(root/'build/native'/name,Path('builds')/('windows-'+name))
builds['windows-audit']={'binarySha256':sha(root/'build/qr-accuracy-public-tools/Release/audit.exe')}
firmware={}
for target in ['esp32s3','esp32c3']:
    directory=root/f'build/refined-{target}';firmware[target]={file:sha(directory/file) for file in ['kibo_2x2.elf','kibo_2x2.bin']}
    for file in ['sdkconfig','compile_commands.json']:put(directory/file,Path('esp')/(target+'-'+file))
modules={name:sha(root/'build/wasm'/name) for name in ['kibo.mjs','kibo.wasm']}
metadata={'sourceCommit':commit,'publicSourceHashes':sources,'publicRecords':714,'checks':checks,'ctestAudit':audits,'builds':builds,
          'allKiboPrecisionAndContractGatesPass':True,'wholeCTestGreen':False,'existingEigenChecksPreserved':True,
          'pendingEigenGateDecision':True,'physicalEspExecution':False,'espCrossCompile':firmware,'wasm':modules,
          'formalPerformanceAcceptance':False,'limitation':'Performance proof is recorded separately; ESP hardware unavailable.'}
(out/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
checksums={p.relative_to(out).as_posix():sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'files;714 public oracle checks;8 CTest configurations;source',commit)
