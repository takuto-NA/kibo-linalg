from pathlib import Path
import json,os,subprocess
out=Path('.scratch/llt-tiny-validation/native');out.mkdir(parents=True,exist_ok=True)
env={k.upper():v for k,v in os.environ.items()}
for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
records=[]
for config in ['Release','Debug']:
    for phase,cmd in [('build',['cmake','--build','build/native','--config',config,'--parallel','2']),
                      ('ctest',['ctest','--test-dir','build/native','-C',config,'--output-on-failure','--no-tests=error'])]:
        r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        (out/f'{config}-{phase}.log').write_bytes(r.stdout)
        records.append({'command':cmd,'exitCode':r.returncode});print(config,phase,r.returncode,r.stdout.decode(errors='replace')[-650:],flush=True)
        if phase=='build':assert r.returncode==0
        else:
            lines=[s for s in r.stdout.decode(errors='replace').splitlines() if s.startswith('line ')]
            assert len(lines)==16 and all(s.startswith(('line 85:','line 126:')) for s in lines),(cmd,lines)
(out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
