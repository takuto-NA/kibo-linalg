from pathlib import Path
import hashlib,json,re,subprocess,sys
root=Path.cwd();build=root/'build/large-llt-next';out=root/'.scratch/large-llt-current-objects';out.mkdir(exist_ok=True)
dumpbin=Path('C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/dumpbin.exe')
records={}
for name in (sys.argv[1:] or ['actual','public_large']):
    obj=build/f'{name}.dir/Release/full-adaptive.obj'
    cmd=[str(dumpbin),'/disasm',str(obj)]
    raw=subprocess.check_output(cmd);(out/f'{name}-full.txt').write_bytes(raw)
    dump=raw.decode(errors='replace').replace('\r\n','\n')
    headers=list(re.finditer(r'(?m)^(\?[^\r\n]+):\r?$',dump));selected=[]
    for i,match in enumerate(headers):
        symbol=match.group(1).split(' ',1)[0]
        if not any(s in symbol for s in ['factorize_column_llt','factorize_llt@','solve_into@','llt_forward_shared@','row_update_two_ordered@','gebp_kernel','triangular_solve','blocked@','finite_exact_symmetric','finite_max_abs','symmetric_rows','row_update_panel']):continue
        end=headers[i+1].start() if i+1<len(headers) else len(dump)
        tag=re.sub(r'[^A-Za-z0-9_-]','_',symbol.split('@',1)[0].lstrip('?'))
        stem=f'{name}-{tag}-{i}';(out/f'{stem}.txt').write_text(dump[match.start():end],encoding='utf-8')
        selected.append({'symbol':symbol,'stem':stem})
    source=root/'include/kibo/llt.hpp' if name=='public_large' else root/f'.scratch/large-llt-next/variants/{name}/kibo/llt.hpp'
    files=[obj,build/f'Release/{name}.exe',build/f'{name}.asm',source,root/'.scratch/large-llt-next/full-adaptive.cpp']
    records[name]={'command':cmd,'files':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
        'dumpSha256':hashlib.sha256(raw).hexdigest(),'selected':selected}
    print(name,len(selected),'COFF functions captured')
(out/'manifest.json').write_text(json.dumps(records,indent=2)+'\n')
