from pathlib import Path
import json,subprocess,sys
out=Path('.scratch/qr-refined-public/portability');out.mkdir(parents=True,exist_ok=True)
root=str(Path.cwd())
commands=[
('wasm-build',['docker','run','--rm','-v',root+':/work','-w','/work','emscripten/emsdk:6.0.10@sha256:e077d54e2b8970575ebc4f185ac1de0b95c05f2b266134d4ba27449af7aebf65','sh','tools/wasm-build.sh']),
('wasm-node',['docker','run','--rm','-v',root+':/work','-w','/work','node:24.21.0@sha256:22f6fe5f59fb7fed238b19623506d573dffaa932ce33b84ce541a9a2e0eade28','node','wasm/node-test.mjs']),
('wasm-browsers',['docker','run','--rm','-v',root+':/work','-w','/work/wasm','mcr.microsoft.com/playwright:v1.63.0-noble@sha256:eff16c30e6f3f4af0a03fa4b706120d5e9b0891c344a27d64559aff5900a4a27','node','browser-test.mjs'])]
for target in ['esp32s3','esp32c3']:
    commands.append((target,['docker','run','--rm','-v',root+':/work','-w','/work/examples/esp32',
        'espressif/idf:v6.1@sha256:81893c71bb5e570088901f21def8684c25cd2a9020281bd01b843a7655edb18c','idf.py','-B',f'/work/build/refined-{target}',
        '-D',f'SDKCONFIG=/work/build/refined-{target}/sdkconfig','-D',f'IDF_TARGET={target}','build']))
records=[]
for name,cmd in commands:
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (out/f'{name}.log').write_bytes(r.stdout)
    records.append({'name':name,'command':cmd,'exitCode':r.returncode})
    (out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
    print(name,r.returncode,r.stdout.decode(errors='replace')[-1800:],flush=True)
    if r.returncode:sys.exit(r.returncode)
