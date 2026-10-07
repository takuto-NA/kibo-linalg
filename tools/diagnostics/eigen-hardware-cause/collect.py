"""Separate, serial hardware/API ablations. Windows/MSVC diagnostic only."""
import hashlib,json,os,random,statistics,subprocess,tempfile
from pathlib import Path
from datetime import datetime,timezone
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
OUT=ROOT/'docs/validation/performance/eigen-root-cause/hardware'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    if OUT.exists() and any(OUT.iterdir()):raise RuntimeError('Use an empty output directory.')
    OUT.mkdir(parents=True,exist_ok=True)
    sources=[p for d in [HERE,HERE.parent/'eigen-root-cause',HERE.parent/'eigen-gap/include',HERE.parent/'eigen-gap/tests'] for p in sorted(d.rglob('*')) if p.is_file() and '__pycache__' not in str(p)]
    hashes={p.relative_to(ROOT).as_posix():sha(p) for p in sources}
    env={k.upper():v for k,v in os.environ.items()}
    for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
    build=Path(tempfile.mkdtemp(prefix='eigen-hardware-cause-',dir=ROOT/'build'))
    cmds=[['cmake','-S',str(HERE),'-B',str(build),'-G','Visual Studio 17 2022','-A','x64',f'-DEIGEN_SOURCE_DIR={ROOT/".cache/eigen"}','-DCMAKE_CXX_FLAGS_RELEASE=/O2 /Ob2 /DNDEBUG'],['cmake','--build',str(build),'--config','Release']]
    manifest={'startedUtc':datetime.now(timezone.utc).isoformat(),'baseCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'sourceSha256':hashes,'commands':cmds,'buildDirectory':str(build),'records':[]}
    for i,cmd in enumerate(cmds):
        r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=900)
        (OUT/f'build-{i}.log').write_bytes(r.stdout)
        if r.returncode:print(r.stdout.decode(errors='replace'));return r.returncode
    targets=['stride','read_stride','projection','llt_guarded_column','llt_no_symmetry']
    manifest['binarySha256']={t:sha(build/f'Release/{t}.exe') for t in targets}
    manifest['effectiveFlags']=[x for x in (build/'CMakeCache.txt').read_text().splitlines() if x.startswith(('CMAKE_CXX_FLAGS','EIGEN_SOURCE_DIR:'))]
    (OUT/'CMakeCXXCompiler.cmake').write_bytes(next(build.glob('CMakeFiles/*/CMakeCXXCompiler.cmake')).read_bytes())
    for mode in ['cpp','sse']:(OUT/f'column_{mode}.asm').write_bytes((build/f'column_{mode}.asm').read_bytes())
    print(json.dumps({'built':True,'buildDirectory':str(build)}),flush=True)
    valid=True
    for process in range(3):
        order=targets.copy();random.Random(0x43415553+process).shuffle(order)
        for name in order:
            args=[]
            if name=='stride':
                strides=[512,520,528,576,640,768,1024,1032]
                if process%2:strides.reverse()
                args=list(map(str,strides))
            elif name=='read_stride':args=[str(process)]
            elif name.startswith('llt_'):args=[str(process),'30']
            command=[str(build/f'Release/{name}.exe'),*args]
            r=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
            raw=f'{name}-{process}.txt';(OUT/raw).write_bytes(r.stdout)
            rows=[json.loads(x) for x in r.stdout.decode(errors='replace').splitlines() if x.startswith('{')]
            ok=r.returncode in ((0,1) if name.startswith('llt_') else (0,))
            if name=='stride':ok=ok and len([x for x in rows if x.get('kind')=='strideSummary'])==8 and all(x['batchSeconds']>=.020 and x['accuracyPassed'] for x in rows if x.get('kind')=='strideSample')
            elif name=='read_stride':ok=ok and len(rows)==40 and all(x['accuracyPassed'] for x in rows)
            elif name=='projection':ok=ok and bool(rows) and all(x.get('accuracyPassed',True) for x in rows)
            else:ok=ok and len([x for x in rows if x.get('kind')=='sample'])==30 and all(min(x['coreSeconds'],x['eigenSeconds'])*x['calls']>=.020 for x in rows if x.get('kind')=='sample') and any(x.get('kind')=='summary' and x['accuracyPassed'] for x in rows)
            manifest['records'].append({'target':name,'process':process,'raw':raw,'command':command,'exitCode':r.returncode,'valid':bool(ok)})
            valid=valid and ok
            print(json.dumps(manifest['records'][-1]),flush=True)
    for p,digest in hashes.items():
        if sha(ROOT/p)!=digest:raise RuntimeError(f'Source changed: {p}')
    for name,digest in manifest['binarySha256'].items():
        if sha(build/f'Release/{name}.exe')!=digest:raise RuntimeError('Binary changed')
    manifest['finishedUtc']=datetime.now(timezone.utc).isoformat();manifest['valid']=valid
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    (OUT/'raw-checksums.sha256').write_text(''.join(f'{sha(p)}  {p.name}\n' for p in sorted(OUT.iterdir()) if p.is_file() and p.name!='raw-checksums.sha256'),encoding='utf-8',newline='\n')
    return 0 if valid else 2
if __name__=='__main__':raise SystemExit(main())
