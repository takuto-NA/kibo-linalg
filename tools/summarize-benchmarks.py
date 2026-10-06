"""Summarize five independent process runs; no CI speed gate."""
import argparse
import csv
import hashlib
import json
import math
import random
import statistics
from collections import defaultdict
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('directory',type=Path)
args=parser.parse_args()
recorded=json.loads((args.directory/'checksums.json').read_text(encoding='utf-8-sig'))
expected_files={'metadata.json'}|{f'run-{run}.{suffix}' for run in range(1,6) for suffix in ['csv','stderr.log']}
if len(recorded)!=len(expected_files) or {item['File'] for item in recorded}!=expected_files:
    raise RuntimeError('missing or unexpected raw evidence checksums')
for item in recorded:
    with (args.directory/item['File']).open('rb') as stream:
        if hashlib.file_digest(stream,'sha256').hexdigest()!=item['Hash'].lower():
            raise RuntimeError(f"checksum mismatch: {item['File']}")
groups=defaultdict(dict)
fixture_hashes={}
for run in range(1,6):
    path=args.directory/f'run-{run}.csv'
    with path.open(newline='',encoding='utf-8-sig') as stream:
        rows=list(csv.DictReader(stream))
    if len(rows)!=160: raise RuntimeError(f'{path}: expected 160 records, got {len(rows)}')
    for row in rows:
        if int(row['run']) != run:
            raise RuntimeError(f'{path}: incorrect process run number')
        key=tuple(row[name] for name in ['m','n','solver','phase'])
        pair=groups[key].setdefault(run,{})
        if row['backend'] in pair:
            raise RuntimeError(f'{path}: duplicate case/backend record')
        for name in ['median_seconds','p95_seconds']:
            value=float(row[name])
            if not math.isfinite(value) or value<=0:
                raise RuntimeError(f'{path}: invalid {name}')
        if float(row['p95_seconds'])<float(row['median_seconds']) or int(row['calls'])<=0:
            raise RuntimeError(f'{path}: invalid timing distribution or call count')
        condition=float(row['condition'])
        if not math.isfinite(condition) or not 1<=condition<=100:
            raise RuntimeError(f'{path}: fixture outside well-conditioned performance range')
        if not 0<int(row['numeric_bytes'])<=64*1024*1024:
            raise RuntimeError(f'{path}: numeric capacity exceeds 64 MiB')
        pair[row['backend']]=row
        shape=(row['m'],row['n'])
        value=row['fixture_fnv1a64']
        if shape in fixture_hashes and fixture_hashes[shape]!=value: raise RuntimeError('fixture hash changed')
        fixture_hashes[shape]=value

expected_shapes={(str(m),str(n)) for n in [2,8,32,128,512] for m in [n,4*n]}
expected_cases={(*shape,solver,phase) for shape in expected_shapes
    for solver in ['normal-LLT','augmented-QR']
    for phase in ['factor','solve','factor_solve','setup_copy_factor_solve']}
if set(groups)!=expected_cases:
    raise RuntimeError('missing or unexpected comparison cases')
for runs in groups.values():
    if set(runs)!=set(range(1,6)) or any(set(pair)!={'kibo-row-major','Eigen-column-major'} for pair in runs.values()):
        raise RuntimeError('missing process run or comparison backend')

generator=random.Random(0x6b69626f)
summary=[]
for key,runs in sorted(groups.items(),key=lambda item:(int(item[0][1]),int(item[0][0]),item[0][2],item[0][3])):
    core=[]; eigen=[]; ratios=[]; p95_core=[]; p95_eigen=[]; capacities=[]
    for run in range(1,6):
        a=runs[run]['kibo-row-major']; b=runs[run]['Eigen-column-major']
        core.append(float(a['median_seconds'])); eigen.append(float(b['median_seconds']))
        ratios.append(core[-1]/eigen[-1]); p95_core.append(float(a['p95_seconds'])); p95_eigen.append(float(b['p95_seconds']))
        capacities.extend([int(a['numeric_bytes']),int(b['numeric_bytes'])])
    bootstrap=sorted(statistics.median(generator.choices(ratios,k=5)) for _ in range(10000))
    summary.append(dict(m=int(key[0]),n=int(key[1]),solver=key[2],phase=key[3],
        kibo_median_seconds=statistics.median(core),eigen_median_seconds=statistics.median(eigen),
        kibo_p95_seconds=statistics.median(p95_core),eigen_p95_seconds=statistics.median(p95_eigen),
        kibo_over_eigen_ratio=statistics.median(ratios),ratio_95_low=bootstrap[249],ratio_95_high=bootstrap[9749],
        numeric_bytes=max(capacities),fixture_fnv1a64=fixture_hashes[(key[0],key[1])]))
with (args.directory/'summary.csv').open('w',newline='',encoding='utf-8') as stream:
    writer=csv.DictWriter(stream,fieldnames=summary[0].keys());writer.writeheader();writer.writerows(summary)
(args.directory/'summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
checksums={}
for path in args.directory.iterdir():
    if path.is_file() and path.name!='summary-checksums.json':
        with path.open('rb') as stream:
            checksums[path.name]=hashlib.file_digest(stream,'sha256').hexdigest()
(args.directory/'summary-checksums.json').write_text(json.dumps(checksums,indent=2)+'\n',encoding='utf-8')
print('verified five runs:',len(summary),'comparison groups; peak numeric bytes:',max(row['numeric_bytes'] for row in summary))
