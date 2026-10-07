"""Fixed-core, one-variable Eigen gap diagnosis. Windows/MSVC only."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import random
import statistics
import subprocess
import sys
import tarfile
import tempfile
from datetime import datetime,timezone

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
SOLVERS=['qr_row','qr_cpp','qr_sse','qr_four','qr_copy','qr_tile','qr_defer',
         'llt_row','llt_width64','llt_column','llt_symmetry','llt_wide']
CONTRACTS=['qr_defer_contracts','llt_column_contracts','llt_symmetry_contracts','llt_wide_contracts']
TARGETS=SOLVERS+['rank_update']+CONTRACTS
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--processes',type=int,default=5)
    parser.add_argument('--samples',type=int,default=30)
    parser.add_argument('--build-only',action='store_true')
    parser.add_argument('--reuse-build',type=Path)
    args=parser.parse_args()
    output=args.output.resolve()
    if output.exists() and any(output.iterdir()):parser.error('Use a new empty output directory.')
    if args.processes<1 or args.samples<5:parser.error('Invalid process/sample counts.')
    output.mkdir(parents=True,exist_ok=True)
    env={key.upper():value for key,value in os.environ.items()}
    for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
    lock=json.loads((ROOT/'tools/toolchains.lock.json').read_text())['eigen']
    archive=ROOT/'.cache/downloads/eigen-5.0.1.tar.gz'
    if digest(archive)!=lock['sha256']:raise RuntimeError('Pinned Eigen archive mismatch.')
    with tarfile.open(archive) as contents:
        for member in contents.getmembers():
            relative=Path(*Path(member.name).parts[1:])
            if member.isfile() and relative.parts and relative.parts[0]=='Eigen':
                if (ROOT/'.cache/eigen'/relative).read_bytes()!=contents.extractfile(member).read():
                    raise RuntimeError(f'Eigen header mismatch: {relative}')
    source_files=[p for directory in [HERE,HERE.parent/'eigen-gap/include',HERE.parent/'eigen-gap/tests']
                  for p in sorted(directory.rglob('*')) if p.is_file() and '__pycache__' not in str(p)]
    hashes={p.relative_to(ROOT).as_posix():digest(p) for p in source_files}
    manifest={'baseCommit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
              'eigenCommit':lock['commit'],'sourceSha256':hashes,'processes':args.processes,
              'samples':args.samples,'startedUtc':datetime.now(timezone.utc).isoformat(),'records':[]}
    if args.reuse_build:
        build=args.reuse_build.resolve()
        prior=json.loads((build/'diagnostic-build-manifest.json').read_text())
        if prior['sourceSha256']!=hashes:raise RuntimeError('Build source changed; configure a new build.')
        manifest['commands']=prior['commands']
    else:
        (ROOT/'build').mkdir(exist_ok=True)
        build=Path(tempfile.mkdtemp(prefix='eigen-root-cause-',dir=ROOT/'build'))
        commands=[['cmake','-S',str(HERE),'-B',str(build),'-G','Visual Studio 17 2022','-A','x64',
                   f'-DEIGEN_SOURCE_DIR={ROOT/".cache/eigen"}','-DCMAKE_CXX_FLAGS_RELEASE=/O2 /Ob2 /DNDEBUG'],
                  ['cmake','--build',str(build),'--config','Release','--target',*TARGETS]]
        manifest['commands']=commands
        for index,command in enumerate(commands):
            result=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=900)
            (output/f'build-{index}.log').write_bytes(result.stdout)
            if result.returncode:sys.stdout.buffer.write(result.stdout);return result.returncode
        manifest['binarySha256']={name:digest(build/f'Release/{name}.exe') for name in TARGETS}
        (build/'diagnostic-build-manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
    manifest['buildDirectory']=str(build)
    manifest['effectiveFlags']=[line for line in (build/'CMakeCache.txt').read_text().splitlines()
                               if line.startswith(('CMAKE_CXX_FLAGS','EIGEN_SOURCE_DIR:'))]
    compiler=next(build.glob('CMakeFiles/*/CMakeCXXCompiler.cmake'))
    (output/'CMakeCXXCompiler.cmake').write_bytes(compiler.read_bytes())
    manifest['binarySha256']={name:digest(build/f'Release/{name}.exe') for name in TARGETS}
    if args.build_only:
        (output/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
        print(json.dumps({'built':True,'buildDirectory':str(build)}),flush=True)
        return 0
    valid=True
    def run(name,process):
        command=[str(build/f'Release/{name}.exe')]
        if name in SOLVERS:command += [str(process),str(args.samples)]
        result=subprocess.run(command,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
        raw=f'{name}-{process}.txt';(output/raw).write_bytes(result.stdout)
        lines=result.stdout.decode(errors='replace').splitlines()
        parsed=[json.loads(line) for line in lines if line.startswith('{')]
        if name in SOLVERS:
            summary=next((v for v in parsed if v.get('kind')=='summary'),None)
            samples=[v for v in parsed if v.get('kind')=='sample']
            passed=(result.returncode in (0,1) and summary is not None and len(samples)==args.samples
                    and summary['accuracyPassed'] and summary['logicalCpu']==0 and summary['cpuidCoreType']==64)
            if name.startswith('qr'):passed=passed and any(v.get('kind')=='overflowControl' and v['passed'] for v in parsed)
            record={'target':name,'process':process,'raw':raw,'exitCode':result.returncode,'valid':bool(passed),'summary':summary}
        else:
            passed=result.returncode==0
            record={'target':name,'process':process,'raw':raw,'exitCode':result.returncode,'valid':passed}
        manifest['records'].append(record)
        print(json.dumps(record),flush=True)
        return passed
    for name in CONTRACTS:valid=run(name,0) and valid
    for process in range(args.processes):
        order=SOLVERS.copy();random.Random(0x6b69626f+process).shuffle(order)
        for name in order:valid=run(name,process) and valid
    # Matched rank-update microprobe is a separate diagnostic, not mixed with factor timings.
    for process in range(3):valid=run('rank_update',process) and valid
    for path,expected in hashes.items():
        if digest(ROOT/path)!=expected:raise RuntimeError(f'Source changed during measurement: {path}')
    manifest['finishedUtc']=datetime.now(timezone.utc).isoformat()
    summaries={}
    for name in SOLVERS:
        rows=[r['summary'] for r in manifest['records'] if r['target']==name and r.get('summary')]
        summaries[name]={key:statistics.median(r[key] for r in rows) for key in ['coreSeconds','eigenSeconds','coreP95','eigenP95','ratio']}
        summaries[name]['processRatios']=[r['ratio'] for r in rows]
        summaries[name]['phasesMs']=[statistics.median(r['phasesMs'][i] for r in rows) for i in range(len(rows[0]['phasesMs']))]
        if name.startswith('qr'):
            summaries[name]['qrDetailMs']=[statistics.median(r['qrDetailMs'][i] for r in rows) for i in range(6)]
    (output/'summary.json').write_bytes((json.dumps(summaries,indent=2)+'\n').encode())
    (output/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
    paths=sorted(p for p in output.iterdir() if p.is_file() and p.name!='SHA256SUMS.txt')
    (output/'SHA256SUMS.txt').write_bytes(''.join(f'{digest(p)}  {p.name}\n' for p in paths).encode())
    return 0 if valid else 2
if __name__=='__main__':sys.exit(main())
