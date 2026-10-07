from pathlib import Path
import json,os,subprocess,sys
out=Path('.scratch/qr-refined-public/native');out.mkdir(parents=True,exist_ok=True)
env={key.upper():value for key,value in os.environ.items()}
for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
commands=[]
for config in ['Debug','Release']:
    cmd=['cmake','--build','build/native','--config',config,'--parallel','4']
    r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{config}-build.log').write_bytes(r.stdout)
    print(config,'build',r.returncode,flush=True)
    assert r.returncode==0,r.stdout.decode(errors='replace')[-2500:]
    commands.append({'command':cmd,'exitCode':r.returncode})
    cmd=['ctest','--test-dir','build/native','-C',config,'--output-on-failure','--no-tests=error',
         '--output-log',str(out/f'{config}-ctest.log')]
    r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    print(config,'ctest',r.returncode,r.stdout.decode(errors='replace')[-1800:],flush=True)
    commands.append({'command':cmd,'exitCode':r.returncode})
(out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
