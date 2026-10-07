from pathlib import Path
import json,os,subprocess,time
root=Path.cwd().resolve();out=root/'.scratch/qr-refined-public/native'
env={key.upper():value for key,value in os.environ.items()}
for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
prefix=root/f'build/refined-installed-{int(time.time())}'
relocated=prefix.with_name(prefix.name+'-relocated')
commands=[('common-build',['cmake','--build','build/native','--config','Release','--target','kibo_common_2x2','--parallel','4']),
    ('common-run',['build/native/Release/kibo_common_2x2.exe']),
    ('install',['cmake','--install','build/native','--config','Release','--prefix',str(prefix)])]
records=[]
def run(name,cmd):
    result=subprocess.run(cmd,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{name}.log').write_bytes(result.stdout)
    records.append({'command':cmd,'exitCode':result.returncode});print(name,result.returncode,result.stdout.decode(errors='replace')[-500:],flush=True)
    assert result.returncode==0,result.stdout.decode(errors='replace')[-2000:]
for name,cmd in commands:run(name,cmd)
assert root in prefix.parents and root in relocated.parents and not relocated.exists()
prefix.rename(relocated)
run('consumer-configure',['cmake','-S','tests/installed_consumer','-B','build/refined-consumer-native','-G','Visual Studio 17 2022','-A','x64','-DCMAKE_PREFIX_PATH='+str(relocated)])
run('consumer-build',['cmake','--build','build/refined-consumer-native','--config','Release','--parallel','4'])
run('consumer-run',['ctest','--test-dir','build/refined-consumer-native','-C','Release','--output-on-failure','--no-tests=error'])
(out/'package-commands.json').write_text(json.dumps(records,indent=2)+'\n')
