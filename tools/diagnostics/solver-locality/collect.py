"""Serial public before/after factor+solve comparison, fixed Windows CPU0."""
from pathlib import Path
from datetime import datetime,timezone
import argparse,hashlib,json,os,random,statistics,subprocess,tarfile
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--processes',type=int,default=5)
    args=parser.parse_args();out=args.output.resolve()
    if out.exists() and any(out.iterdir()):parser.error('Choose an empty output directory.')
    out.mkdir(parents=True,exist_ok=True)
    env={k.upper():v for k,v in os.environ.items()}
    for k in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(k,None)
    lock=json.loads((ROOT/'tools/toolchains.lock.json').read_text())['eigen']
    archive=ROOT/'.cache/downloads/eigen-5.0.1.tar.gz'
    assert sha(archive)==lock['sha256']
    with tarfile.open(archive) as tar:
        for member in tar.getmembers():
            relative=Path(*Path(member.name).parts[1:])
            if member.isfile() and relative.parts and relative.parts[0]=='Eigen':
                assert (ROOT/'.cache/eigen'/relative).read_bytes()==tar.extractfile(member).read()
    sources=[p for directory in [ROOT/'include',ROOT/'tests',HERE] for p in sorted(directory.rglob('*')) if p.is_file() and '__pycache__' not in str(p)]
    hashes={p.relative_to(ROOT).as_posix():sha(p) for p in sources}
    build=ROOT/'build/solver-locality'
    baseline='83c7a143599cd9e73bc97e6ecae3680daee3418f'
    baseline_hashes={}
    for path in subprocess.check_output(['git','ls-tree','-r','--name-only',baseline,'--','include'],text=True).splitlines():
        data=subprocess.check_output(['git','show',f'{baseline}:{path}'])
        destination=build/'before-include'/Path(path).relative_to('include')
        destination.parent.mkdir(parents=True,exist_ok=True);destination.write_bytes(data)
        baseline_hashes[path]=hashlib.sha256(data).hexdigest()
    commands=[['cmake','-S',str(HERE),'-B',str(build),'-G','Visual Studio 17 2022','-A','x64',f'-DEIGEN_SOURCE_DIR={ROOT/".cache/eigen"}','-DCMAKE_CXX_FLAGS_RELEASE=/O2 /Ob2 /DNDEBUG'],['cmake','--build',str(build),'--config','Release','--parallel','4']]
    manifest={'startedUtc':datetime.now(timezone.utc).isoformat(),'sourceBaseCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'beforeSourceCommit':'83c7a143599cd9e73bc97e6ecae3680daee3418f','sourceSha256':hashes,'commands':commands,'eigen':lock,'processes':args.processes,'samples':30,'records':[]}
    manifest['beforeSourceSha256']=baseline_hashes
    (out/'public.patch').write_bytes(subprocess.check_output(['git','diff','HEAD','--','include','tests','CMakeLists.txt']))
    for i,command in enumerate(commands):
        r=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        (out/f'build-{i}.log').write_bytes(r.stdout)
        if r.returncode:raise RuntimeError(f'Build failed: {i}')
    targets=['before_llt','after_llt','before_qr_row','after_qr_row','before_qr_column','after_qr_column']
    manifest['binarySha256']={t:sha(build/f'Release/{t}.exe') for t in targets}
    manifest['effectiveFlags']=[x for x in (build/'CMakeCache.txt').read_text().splitlines() if x.startswith(('CMAKE_CXX_FLAGS','EIGEN_SOURCE_DIR:'))]
    (out/'CMakeCXXCompiler.cmake').write_bytes(next(build.glob('CMakeFiles/*/CMakeCXXCompiler.cmake')).read_bytes())
    print('Build verified; starting serial measurements',flush=True)
    groups={};valid=True
    for process in range(args.processes):
        cases=[(n,m,t) for n in [2,8,32,128,512] for m in [n,4*n] for t in targets]
        random.Random(0x4c4f4341+process).shuffle(cases)
        for n,m,target in cases:
            command=[str(build/f'Release/{target}.exe'),str(process),'30',str(n),str(m)]
            r=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
            name=f'{target}-n{n}-m{m}-p{process}.jsonl';(out/name).write_bytes(r.stdout)
            rows=[json.loads(x) for x in r.stdout.decode(errors='replace').splitlines() if x.startswith('{')]
            samples=[x for x in rows if x.get('kind')=='sample'];summary=next((x for x in rows if x.get('kind')=='summary'),None)
            ok=r.returncode in (0,1) and len(samples)==30 and summary is not None and summary['accuracyPassed'] and summary['coreType']==64
            ok=ok and all(min(x['coreSeconds'],x['eigenSeconds'])*x['calls']>=.020 for x in samples)
            if 'qr' in target:ok=ok and any(x.get('kind')=='overflowControl' and x['passed'] for x in rows)
            valid=valid and ok
            record={'target':target,'process':process,'n':n,'m':m,'raw':name,'exitCode':r.returncode,'valid':ok,'summary':summary}
            manifest['records'].append(record);groups.setdefault(f'{target}/n{n}/m{m}',[]).append(summary)
            print(json.dumps({'target':target,'process':process,'n':n,'m':m,'valid':ok,'ratio':summary['ratio'] if summary else None}),flush=True)
    assert all(sha(ROOT/p)==digest for p,digest in hashes.items()),'Source changed during measurement'
    assert all(sha(build/'before-include'/Path(p).relative_to('include'))==digest for p,digest in baseline_hashes.items())
    assert all(sha(build/f'Release/{t}.exe')==digest for t,digest in manifest['binarySha256'].items())
    manifest['finishedUtc']=datetime.now(timezone.utc).isoformat();manifest['valid']=valid
    summary={name:{k:statistics.median(s[k] for s in values) for k in ['coreSeconds','eigenSeconds','ratio']} for name,values in groups.items() if all(values)}
    for name,obj in [('manifest',manifest),('summary',summary)]:
        (out/f'{name}.json').write_text(json.dumps(obj,indent=2)+'\n',encoding='utf-8',newline='\n')
    (out/'SHA256SUMS.txt').write_text(''.join(f'{sha(p)}  {p.name}\n' for p in sorted(out.iterdir()) if p.is_file() and p.name!='SHA256SUMS.txt'),encoding='utf-8',newline='\n')
    return 0 if valid else 2
if __name__=='__main__':raise SystemExit(main())
