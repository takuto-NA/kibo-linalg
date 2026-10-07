from pathlib import Path
code=Path('.scratch/run-qr-layout-controls.py').read_text()
code=code.replace('qr-layout-controls','qr-bounded-controls')
start=code.index('cases=[]');end=code.index('for n,name in cases:',start)
cases='''cases=[]
for n in [8,32,128]:
    for name in ['combo_certified_norm_column','column_work_bounded_column','column_work_packet_row_best','column_work_bounded_row_best']:
        cases.append((n,name))
for name in ['triangular_stream_column','column_work_bounded_column','column_work_packet_row_best','column_work_packet_local_row_best','column_work_bounded_row_best']:
    cases.append((512,name))
'''
Path('.scratch/run-qr-bounded-controls.py').write_text(code[:start]+cases+code[end:])
