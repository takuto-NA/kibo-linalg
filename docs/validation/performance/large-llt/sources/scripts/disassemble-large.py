from pathlib import Path
import hashlib,json,re,subprocess
root=Path.cwd();build=root/'build/large-llt-next';out=root/'.scratch/large-llt-objects'
out.mkdir(parents=True,exist_ok=True)
dumpbin=Path('C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/dumpbin.exe')
manifest={}
for name in ['actual','pair8_divide','quad8_divide','forward4']:
    obj=build/f'{name}.dir/Release/full-adaptive.obj';exe=build/f'Release/{name}.exe';listing=build/f'{name}.asm'
    raw=subprocess.check_output([str(dumpbin),'/disasm',str(obj)])
    (out/f'{name}-full.txt').write_bytes(raw)
    dump=raw.decode(errors='replace').replace('\r\n','\n')
    headers=list(re.finditer(r'(?m)^(\?[^\r\n]+):\r?$',dump))
    selected=[]
    for i,match in enumerate(headers):
        symbol=match.group(1).split(' ',1)[0]
        if not any(s in symbol for s in ['factorize_column_llt@','factorize_llt@','row_update_panel@','update_column_pair@',
                                         'divide_contiguous_checked@','solve_into@','blocked@','gebp_kernel','general_matrix_matrix_product']):continue
        end=headers[i+1].start() if i+1<len(headers) else len(dump)
        tag=re.sub(r'[^A-Za-z0-9_-]','_',symbol.split('@',1)[0].lstrip('?'))
        stem=f'{name}-{tag}-{i}'
        (out/f'{stem}-object.txt').write_text(dump[match.start():end],encoding='utf-8')
        selected.append({'symbol':symbol,'stem':stem})
    manifest[name]={'command':[str(dumpbin),'/disasm',str(obj)],'objectSha256':hashlib.sha256(obj.read_bytes()).hexdigest(),
                    'binarySha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'listingSha256':hashlib.sha256(listing.read_bytes()).hexdigest(),
                    'fullDumpSha256':hashlib.sha256(raw).hexdigest(),'selected':selected}
    print(name,'selected',len(selected),'actual COFF functions')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
