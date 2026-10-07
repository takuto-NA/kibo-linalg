import os
import subprocess
import sys
from pathlib import Path
env={key.upper():value for key,value in os.environ.items()}
for key in ['CL','_CL_','CXXFLAGS','CFLAGS','LDFLAGS']:env.pop(key,None)
result=subprocess.run(['cmake',*sys.argv[1:]],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
Path('.scratch/cmake-next-last.log').write_bytes(result.stdout)
print(result.stdout.decode(errors='replace')[-2000:])
raise SystemExit(result.returncode)
