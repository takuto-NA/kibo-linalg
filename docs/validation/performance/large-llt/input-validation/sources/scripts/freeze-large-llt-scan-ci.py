from pathlib import Path
import hashlib,json,re,shutil
root=Path.cwd();source=root/'.scratch/large-llt-scan-hosted'
out=root/'docs/validation/performance/large-llt/input-validation/hosted';out.mkdir(parents=True,exist_ok=True)
hashes={};copied=[];failures={}
for path in sorted(source.rglob('*')):
    if not path.is_file():continue
    name=path.relative_to(source).as_posix();hashes[name]=hashlib.sha256(path.read_bytes()).hexdigest()
    if path.suffix not in ['.json','.log','.txt','.yaml','.cmake','.vcxproj','.mjs','.tlog'] and path.name!='sdkconfig':continue
    dest=out/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,dest);copied.append(name)
for path in sorted(source.rglob('*ctest.log')):
    lines=[s for s in path.read_text(errors='replace').splitlines() if s.startswith('line ')]
    if lines:
        assert len(lines)==16 and all(s.startswith('line 85:') or s.startswith('line 126:') for s in lines),(path,lines)
        failures[path.relative_to(source).as_posix()]={'checks':16,'perLayout':8,'eigenOnly':True}
for directory in sorted(source.glob('linux-*-evidence')):
    logs=list(directory.rglob('LastTest.log'))
    numerical=[p for p in logs if p.parent.parent.parent.name in ['Debug','Release']]
    for path in numerical:
        lines=[s for s in path.read_text(errors='replace').splitlines() if s.startswith('line ')]
        assert len(lines)==16 and all(s.startswith('line 85:') or s.startswith('line 126:') for s in lines),(path,lines)
        failures[path.relative_to(source).as_posix()]={'checks':16,'perLayout':8,'eigenOnly':True}
assert len(failures)>=8,len(failures)
for path in source.rglob('LastTestsFailed.log'):
    assert {s.split(':',1)[1] for s in path.read_text().splitlines()}=={'numerical','numerical_column'},path
node=json.loads((source/'wasm-evidence/node-results.json').read_text())
browsers=json.loads((source/'wasm-evidence/browser-results.json').read_text())
assert node['passed'] and node['refinedQr']
assert {s['engine'] for s in browsers}=={'chromium','firefox','webkit'} and all(s['passed'] and s['refinedQr'] for s in browsers)
results={'runId':37629654886,'sourceCommit':'2f23d66af38fe4aed42811cdf6438af73de620c5',
    'url':'https://github.com/takuto-NA/kibo-linalg/actions/runs/37629654886','status':'completed','conclusion':'failure',
    'ownPrecisionAndContractGatesPass':True,'eigenAccuracyChecksUnchanged':True,'numericalFailures':failures,
    'jobConclusions':{'windows':'failure','linux-gcc':'failure','linux-clang':'failure','linux-clang-sanitized':'failure',
    'wasm':'success','esp32s3-cross':'success','esp32c3-cross':'success'},'physicalEspExecution':False,
    'wasmNode':node,'wasmBrowsers':browsers,
    'allDownloadedArtifactSha256':hashes,'retainedFiles':copied}
(out/'evidence.json').write_text(json.dumps(results,indent=2)+'\n')
base=out.parent
checksums={p.relative_to(base).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(base.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(base/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('CI failure maps',len(failures),'retained',len(copied),'artifact hashes',len(hashes))
