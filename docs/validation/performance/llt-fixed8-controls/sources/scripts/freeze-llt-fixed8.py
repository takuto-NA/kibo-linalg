from pathlib import Path
import gzip,hashlib,json,shutil,statistics,subprocess
root=Path.cwd();out=root/'docs/validation/performance/llt-fixed8-controls';out.mkdir(parents=True,exist_ok=True)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def put(path,dest):
    dest=out/dest;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(path,dest)
data=json.loads((root/'.scratch/llt-fixed8-controls/commands.json').read_text());assert len(data['commands'])==36
for path in (root/'.scratch/llt-fixed8-controls').glob('*'):put(path,Path('timings')/path.name)
rows=[]
for n,m in [(31,124),(32,128),(33,132),(128,128),(128,512),(512,2048)]:
    group={name:[r for r in data['commands'] if int(r['command'][1])==n and int(r['command'][3])==m and Path(r['command'][0]).stem==name] for name in ['public_large','fixed8']}
    for name,records in group.items():assert len(records)==3
    rec={'n':n,'m':m,**{name:[statistics.median(r['phaseUs'][i] for r in records) for i in range(4)] for name,records in group.items()}}
    rec['factorRatioFixedToPublic']=rec['fixed8'][0]/rec['public_large'][0];rows.append(rec)
(out/'summary.json').write_text(json.dumps({'formalAcceptance':False,'adopted':False,'reason':'No stable improvement of 128-variable factor time; retained public runtime-width helper.','rows':rows},indent=2)+'\n')
objects=root/'.scratch/llt-fixed8-objects'
for path in objects.glob('*'):
    if path.name.endswith('-full.txt'):
        dest=out/'objects'/(path.name+'.gz');dest.parent.mkdir(exist_ok=True)
        with dest.open('wb') as f:
            with gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as z:z.write(path.read_bytes())
    else:put(path,Path('objects')/path.name)
for variant,folder in [('fixed8',root/'.scratch/large-llt-next/variants/fixed8'),('public',root/'include')]:
    shutil.copytree(folder/'kibo',out/f'sources/variants/{variant}/kibo',dirs_exist_ok=True)
for name in ['full-adaptive.cpp','uninitialized-setup.cpp']:put(root/'.scratch/large-llt-next'/name,Path('sources')/name)
for name in ['tests/controlled_fixture.hpp','tests/llt_tests.cpp','tests/llt_large_tests.cpp','tests/test_check.hpp','tools/diagnostics/solver-locality/affinity.hpp']:
    put(root/name,Path('sources')/name)
for name in ['prepare-llt-fixed8.py','prepare-llt-fixed8-contracts.py','run-llt-fixed8-controls.py','disassemble-llt-fixed8.py','freeze-llt-fixed8.py','cmake-safe.py']:
    put(root/'.scratch'/name,Path('sources/scripts')/name)
contracts=[]
for name in ['fixed8_llt_simd','fixed8_llt_scalar','fixed8_llt_large_simd','fixed8_llt_large_scalar']:
    exe=root/f'build/large-llt-next/Release/{name}.exe';r=subprocess.run([str(exe)],capture_output=True)
    assert r.returncode==0;putlog=out/'contracts'/(name+'.log');putlog.parent.mkdir(exist_ok=True);putlog.write_bytes(r.stdout)
    contracts.append({'command':[str(exe)],'binarySha256':sha(exe),'exitCode':r.returncode})
(out/'contracts/commands.json').write_text(json.dumps(contracts,indent=2)+'\n')
checksums={p.relative_to(out).as_posix():sha(p) for p in out.rglob('*') if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
for r in rows:print(r['n'],r['m'],'factor public/fixed',r['public_large'][0],r['fixed8'][0],r['factorRatioFixedToPublic'])
print('frozen',len(checksums),'files;36 executions;4 contract suites')
