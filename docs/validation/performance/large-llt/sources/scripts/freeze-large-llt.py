from pathlib import Path
import hashlib,json,shutil,subprocess
root=Path.cwd();out=root/'docs/validation/performance/large-llt'
assert json.loads((root/'.scratch/large-llt-formal/commands.json').read_text())['publicCodeCommit']=='48439196aa80f5c2678e8b7a15c1bf4cfcb438b5'
for dest,source in [('formal','.scratch/large-llt-formal'),('initial-objects','.scratch/large-llt-objects'),
                    ('shared-objects','.scratch/large-llt-shared-objects'),('public-objects','.scratch/large-llt-current-objects'),
                    ('validation/local','.scratch/large-llt-public-validation')]:
    for p in (root/source).rglob('*'):
        if p.is_file() and p.suffix in ['.json','.jsonl','.txt','.log','.asm']:
            target=out/dest/p.relative_to(root/source);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
for series in ['first','second','third','third-adaptive','fourth','transfer','fixed','forward','backward','reciprocal','validation-cost']:
    source=root/f'.scratch/large-llt-{series}'
    if not source.exists():continue
    for p in source.rglob('*'):
        if p.is_file() and p.suffix in ['.json','.jsonl','.log']:
            target=out/'controls'/series/p.relative_to(source);target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
variant_hashes={}
for folder in (root/'.scratch/large-llt-next/variants').iterdir():
    if not folder.is_dir():continue
    hashes={}
    for p in folder.rglob('*.hpp'):
        relative=p.relative_to(folder);hashes[relative.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
        if p.name in ['llt.hpp','row_kernels.hpp']:
            target=out/'sources/variants'/folder.name/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
    variant_hashes[folder.name]=hashes
(out/'sources/variant-hashes.json').write_text(json.dumps(variant_hashes,indent=2)+'\n')
canonical={};commit='48439196aa80f5c2678e8b7a15c1bf4cfcb438b5'
for name in subprocess.check_output(['git','ls-tree','-r','--name-only',commit,'include','tests'],text=True).splitlines():
    raw=(root/name).read_bytes();committed=subprocess.check_output(['git','show',f'{commit}:{name}'])
    assert raw.replace(b'\r\n',b'\n')==committed,name
    canonical[name]={'workingTreeSha256':hashlib.sha256(raw).hexdigest(),'gitLfSha256':hashlib.sha256(committed).hexdigest()}
(out/'sources/public-commit-hashes.json').write_text(json.dumps({'commit':commit,'files':canonical},indent=2)+'\n')
for p in (root/'.scratch/large-llt-next').glob('*'):
    if p.is_file() and p.suffix in ['.cpp','.txt']:
        target=out/'sources/harness'/p.name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
for p in (root/'.scratch').glob('*large*.py'):
    if p.name.startswith(('prepare','run','freeze','large','disassemble','summarize')):
        target=out/'sources/scripts'/p.name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
checksums={p.relative_to(out).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(out.rglob('*')) if p.is_file() and p.name!='SHA256SUMS.json'}
(out/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print('frozen',len(checksums),'raw/source/assembly/validation files; binary hashes retained, binaries excluded')
