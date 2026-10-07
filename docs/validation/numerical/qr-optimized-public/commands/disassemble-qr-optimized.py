from pathlib import Path
import hashlib,json,re,subprocess,sys
root=Path.cwd();build=root/'build/qr-next';out=root/'.scratch/qr-optimized-objects';out.mkdir(exist_ok=True)
dumpbin=Path('C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/dumpbin.exe')
records={}
for name in sys.argv[1:]:
    obj=build/f'{name}.dir/Release/full-adaptive.obj';cmd=[str(dumpbin),'/disasm',str(obj)]
    raw=subprocess.check_output(cmd);(out/f'{name}-full.txt').write_bytes(raw);dump=raw.decode(errors='replace').replace('\r\n','\n')
    headers=list(re.finditer(r'(?m)^(\?[^\r\n]+|main):\r?$',dump));selected=[]
    for i,match in enumerate(headers):
        symbol=match.group(1).split(' ',1)[0]
        if not any(s in symbol for s in ['factorize_qr@','solve_into@','column_norm@','finite@','qr_input_finite@','qr_is_finite@','column_project_four','column_update_four','row_update_checked','qr_restore_row_blocks','qr_initial_norms','qr_apply_packet_panels','qr_swap_transpose_pair','qr_strided_dot','qr_strided_update_checked','row_project_four','householder','applyHouseholder','computeInPlace','ColPivHouseholderQR','main','lambda_']):continue
        end=headers[i+1].start() if i+1<len(headers) else len(dump);tag=re.sub(r'[^A-Za-z0-9_-]','_',symbol.split('@',1)[0].lstrip('?'))
        stem=f'{name}-{tag}-{i}';fragment=dump[match.start():end];(out/f'{stem}.txt').write_text(fragment,encoding='utf-8')
        selected.append({'symbol':symbol,'stem':stem,'staticDclassCallSites':len(re.findall(r'call.*_dclass',fragment))})
    variant=re.sub(r'_(column|row_same|row_best)$','',name)
    source=root/'include/kibo' if variant=='public_qr' else root/f'.scratch/qr-next/variants/{variant}/kibo'
    files=[obj,build/f'Release/{name}.exe',build/f'{name}.asm',root/'.scratch/qr-next/full-adaptive.cpp',source/'qr.hpp',source/'linalg.hpp',source/'detail/row_kernels.hpp',source/'detail/qr_kernels.hpp']
    records[name]={'command':cmd,'files':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},'dumpSha256':hashlib.sha256(raw).hexdigest(),'selected':selected}
    print(name,len(selected),'functions;',sum(s['staticDclassCallSites'] for s in selected),'static dclass call sites (not dynamic counts)')
(out/'manifest.json').write_text(json.dumps(records,indent=2)+'\n')
