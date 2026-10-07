from pathlib import Path
import hashlib,json,re,subprocess
root=Path.cwd();build=root/'build/large-llt-next';out=root/'.scratch/large-llt-shared-objects';out.mkdir(exist_ok=True)
dumpbin=Path('C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/dumpbin.exe')
records={}
for name in ['actual','pair8_divide_inline_forward4rows','shared_back2']:
    obj=build/f'{name}.dir/Release/full-adaptive.obj'
    cmd=[str(dumpbin),'/disasm',str(obj)]
    raw=subprocess.check_output(cmd);(out/f'{name}-full.txt').write_bytes(raw)
    dump=raw.decode(errors='replace').replace('\r\n','\n')
    headers=list(re.finditer(r'(?m)^(\?[^\r\n]+):\r?$',dump));selected=[]
    for i,match in enumerate(headers):
        symbol=match.group(1).split(' ',1)[0]
        if not any(s in symbol for s in ['factorize_column_llt@','solve_into@','llt_forward_shared@','row_update_two_ordered@','gebp_kernel','triangular_solve','blocked@']):continue
        end=headers[i+1].start() if i+1<len(headers) else len(dump)
        tag=re.sub(r'[^A-Za-z0-9_-]','_',symbol.split('@',1)[0].lstrip('?'))
        stem=f'{name}-{tag}-{i}';(out/f'{stem}.txt').write_text(dump[match.start():end],encoding='utf-8')
        selected.append({'symbol':symbol,'stem':stem})
    files=[obj,build/f'Release/{name}.exe',build/f'{name}.asm',root/f'.scratch/large-llt-next/variants/{name}/kibo/llt.hpp']
    records[name]={'command':cmd,'files':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
        'dumpSha256':hashlib.sha256(raw).hexdigest(),'selected':selected}
    print(name,len(selected),'COFF functions captured')
(out/'manifest.json').write_text(json.dumps(records,indent=2)+'\n')
