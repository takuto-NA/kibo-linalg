"""Save real COFF disassembly and selected matching compiler functions."""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--variants', nargs='+', default=['baseline', 'actual'])
p.add_argument('--out', default='.scratch/small-llt-object')
p.add_argument('--dumpbin', default='C:/Program Files (x86)/Microsoft Visual Studio/2022/BuildTools/VC/Tools/MSVC/14.44.35207/bin/Hostx64/x64/dumpbin.exe')
a = p.parse_args()
out = Path(a.out)
out.mkdir(parents=True, exist_ok=True)
manifest = {}
for variant in a.variants:
    obj = Path(f'build/small-llt/{variant}.dir/Release/phases.obj')
    exe = Path(f'build/small-llt/Release/{variant}.exe')
    listing = Path(f'build/small-llt/{variant}.asm')
    command = [a.dumpbin, '/disasm', str(obj)]
    result = subprocess.run(command, stdout=subprocess.PIPE, check=True)
    dump = result.stdout.decode(errors='replace').replace('\r\n', '\n')
    # Full byte-for-byte output is retained separately; selected functions
    # keep actual offsets/opcodes/relocated call names, never regenerated text.
    (out / f'{variant}-full.txt').write_bytes(result.stdout)
    headers = list(re.finditer(r'(?m)^(\?[^\r\n]+):\r?$', dump))
    sections = {}
    for i, match in enumerate(headers):
        symbol = match.group(1).split(' ', 1)[0]
        end = headers[i+1].start() if i+1 < len(headers) else len(dump)
        sections[symbol] = dump[match.start():end]
    assembly = listing.read_text(errors='replace')
    selected = []
    for i, match in enumerate(re.finditer(r'(?m)^(\?[^\r\n]+?) PROC[^\r\n]*\r?\n(.*?)^\1 ENDP[^\r\n]*', assembly, re.S)):
        symbol = match.group(1)
        if not any(x in symbol for x in ['factorize_llt@', 'factorize_column_llt@', 'solve_into@',
                                         'row_update_panel@', 'unblocked@', 'general_matrix_vector_product']):
            continue
        assert symbol in sections, symbol
        tag = symbol.split('@', 1)[0].lstrip('?').replace('$', '_')
        stem = f'{variant}-{tag}-{i}'
        (out / f'{stem}.asm').write_text(match.group(0), encoding='utf-8')
        (out / f'{stem}-object.txt').write_text('\n'.join(dump.splitlines()[:7])+'\n\n'+sections[symbol], encoding='utf-8')
        selected.append({'stem': stem, 'symbol': symbol})
    manifest[variant] = {'command': command, 'objectSha256': hashlib.sha256(obj.read_bytes()).hexdigest(),
                         'binarySha256': hashlib.sha256(exe.read_bytes()).hexdigest(),
                         'listingSha256': hashlib.sha256(listing.read_bytes()).hexdigest(),
                         'fullDumpSha256': hashlib.sha256(result.stdout).hexdigest(), 'selected': selected}
    print(variant, 'selected', len(selected), 'real object functions')
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
