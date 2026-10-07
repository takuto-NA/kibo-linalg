"""Repeat a whole rejected timing process; preserve its original evidence."""
from pathlib import Path
from datetime import datetime,timezone
import argparse,hashlib,json,subprocess
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('directory',type=Path)
    args=parser.parse_args();directory=args.directory.resolve();root=Path(__file__).resolve().parents[3]
    if (directory/'accepted-manifest.json').exists():raise RuntimeError('Accepted manifest already exists.')
    original=json.loads((directory/'manifest.json').read_text());accepted=json.loads(json.dumps(original))
    accepted['originalManifest']='manifest.json';accepted['retryPolicy']='Repeat whole process only after duration/validity rejection; never select by speed.'
    accepted['rejectedRecords']=[];accepted['retryToolSha256']=sha(Path(__file__))
    assert all(sha(root/p)==digest for p,digest in original['sourceSha256'].items())
    build=root/'build/solver-locality'
    assert all(sha(build/f'Release/{t}.exe')==digest for t,digest in original['binarySha256'].items())
    for i,record in enumerate(original['records']):
        if record['valid']:continue
        # Only time-duration failures may be repeated automatically. Numerical
        # failures require diagnosis and are not statistical exclusions.
        assert record['exitCode'] in (0,1) and record['summary'] and record['summary']['accuracyPassed']
        original_rows=[json.loads(x) for x in (directory/record['raw']).read_text().splitlines() if x.startswith('{')]
        original_samples=[s for s in original_rows if s.get('kind')=='sample']
        assert len(original_samples)==30 and record['summary']['coreType']==64
        assert any(min(s['coreSeconds'],s['eigenSeconds'])*s['calls']<.020 for s in original_samples)
        if 'qr' in record['target']:assert any(s.get('kind')=='overflowControl' and s['passed'] for s in original_rows)
        accepted['rejectedRecords'].append(record)
        for attempt in range(1,4):
            name=f"retry{attempt}-{record['raw']}";path=directory/name
            if path.exists():raise RuntimeError('Do not overwrite a retry.')
            command=[str(build/f"Release/{record['target']}.exe"),str(record['process']),'30',str(record['n']),str(record['m'])]
            start=datetime.now(timezone.utc).isoformat()
            result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
            path.write_bytes(result.stdout)
            rows=[json.loads(x) for x in result.stdout.decode().splitlines() if x.startswith('{')]
            samples=[s for s in rows if s.get('kind')=='sample'];s=next((v for v in rows if v.get('kind')=='summary'),None)
            assert result.returncode in (0,1) and s and s['accuracyPassed'] and len(samples)==30
            assert s['inputHash']==record['summary']['inputHash'] and s['coreType']==64
            if 'qr' in record['target']:assert any(v.get('kind')=='overflowControl' and v['passed'] for v in rows)
            ok=all(min(v['coreSeconds'],v['eigenSeconds'])*v['calls']>=.020 for v in samples)
            replacement={**record,'raw':name,'valid':ok,'summary':s,'exitCode':result.returncode,'retryOf':record['raw'],'startedUtc':start,'finishedUtc':datetime.now(timezone.utc).isoformat(),'command':command}
            print(json.dumps(replacement),flush=True)
            if ok:accepted['records'][i]=replacement;break
            accepted['rejectedRecords'].append(replacement)
        else:raise RuntimeError('No valid whole-process retry; investigate timing stability.')
    accepted['valid']=all(v['valid'] for v in accepted['records'])
    (directory/'accepted-manifest.json').write_text(json.dumps(accepted,indent=2)+'\n',encoding='utf-8',newline='\n')
if __name__=='__main__':main()
