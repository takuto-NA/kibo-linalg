from pathlib import Path
import json,subprocess,sys
root=str(Path.cwd());out=Path('.scratch/qr-optimized-public')
image='gcc:15.3@sha256:ead103e6d03b69232962d467f3520c3f70b6718c69ff71efcc08efe9011fadb6'
compiler='/work/.cache/tools/LLVM-20.1.8-Linux-X64/bin/clang++'
link='-L/work/.cache/tools/LLVM-20.1.8-Linux-X64/lib/x86_64-unknown-linux-gnu -Wl,-rpath,/work/.cache/tools/LLVM-20.1.8-Linux-X64/lib/x86_64-unknown-linux-gnu'
records=[]
for name in ['gcc','clang','clang-sanitized']:
    cmd=['docker','run','--rm','-v',root+':/work','-w','/work']
    if name!='gcc':
        flags='-stdlib=libc++'
        linker=link
        if name=='clang-sanitized':
            flags+=' -fsanitize=address,undefined -fno-omit-frame-pointer';linker+=' -fsanitize=address,undefined'
        cmd+=['-e','CXXFLAGS='+flags,'-e','LDFLAGS='+linker]
    cmd += [image,'sh','.scratch/qr-optimized-linux.sh','g++' if name=='gcc' else compiler,name]
    result=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{name}-driver.log').write_bytes(result.stdout)
    print(name,result.returncode,result.stdout.decode(errors='replace')[-2000:],flush=True)
    records.append({'name':name,'command':cmd,'exitCode':result.returncode})
    (out/'linux-commands.json').write_text(json.dumps(records,indent=2)+'\n')
    if result.returncode:sys.exit(result.returncode)
