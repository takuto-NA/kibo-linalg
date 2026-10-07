from pathlib import Path
import json,os,subprocess
out=Path('.scratch/large-llt-public-validation/native');out.mkdir(parents=True,exist_ok=True)
env={key.upper():value for key,value in os.environ.items()}
for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
records=[]
for config in ['Debug','Release']:
    cmd=['cmake','--build','build/native','--config',config,'--target','kibo_llt_tests','kibo_llt_scalar_tests','kibo_llt_large_tests',
         'kibo_llt_large_scalar_tests','kibo_no_runtime_tests','kibo_allocation_tests','kibo_common_2x2','kibo_numerical_tests','--parallel','4']
    r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{config}-build.log').write_bytes(r.stdout)
    assert r.returncode==0,r.stdout.decode(errors='replace')[-2500:]
    records.append({'command':cmd,'exitCode':r.returncode});print(config,'build pass',flush=True)
    cmd=['ctest','--test-dir','build/native','-C',config,'--output-on-failure','--no-tests=error',
         '-R','^(llt|llt_scalar|llt_large|llt_large_scalar|no_runtime|allocation|common_2x2|numerical|numerical_column)$']
    r=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{config}-ctest.log').write_bytes(r.stdout)
    records.append({'command':cmd,'exitCode':r.returncode});print(config,'ctest',r.returncode,r.stdout.decode(errors='replace')[-800:],flush=True)
(out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
