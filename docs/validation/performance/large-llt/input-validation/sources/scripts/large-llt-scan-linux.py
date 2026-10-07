from pathlib import Path
import json,subprocess
root=str(Path.cwd());out=Path('.scratch/large-llt-scan-validation');out.mkdir(exist_ok=True)
image='gcc:15.3@sha256:ead103e6d03b69232962d467f3520c3f70b6718c69ff71efcc08efe9011fadb6'
link='-L/work/.cache/tools/LLVM-20.1.8-Linux-X64/lib/x86_64-unknown-linux-gnu -Wl,-rpath,/work/.cache/tools/LLVM-20.1.8-Linux-X64/lib/x86_64-unknown-linux-gnu'
records=[]
for name in ['gcc','clang','clang-sanitized']:
    cmd=['docker','run','--rm','-v',root+':/work','-w','/work']
    if name!='gcc':
        flags='-stdlib=libc++';ldflags=link
        if name=='clang-sanitized':flags+=' -fsanitize=address,undefined -fno-omit-frame-pointer';ldflags+=' -fsanitize=address,undefined'
        cmd+=['-e','CXXFLAGS='+flags,'-e','LDFLAGS='+ldflags]
    cmd += [image,'sh','.scratch/large-llt-scan-linux.sh',name]
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{name}-driver.log').write_bytes(r.stdout)
    records.append({'command':cmd,'exitCode':r.returncode});print(name,r.returncode,r.stdout.decode(errors='replace')[-800:],flush=True)
    assert r.returncode==0
(out/'linux-commands.json').write_text(json.dumps(records,indent=2)+'\n')
