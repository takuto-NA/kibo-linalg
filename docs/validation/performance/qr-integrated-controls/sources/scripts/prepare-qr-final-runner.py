from pathlib import Path
code=Path('.scratch/run-qr-layout-controls.py').read_text().replace('qr-layout-controls','qr-final-controls')
start=code.index('cases=[]');end=code.index('for n,name in cases:',start)
cases='''cases=[]
for n in [8,32,128]:
    for name in ['column_work_packet_local_column','column_work_fast_column','column_work_fast_row_best','column_work_restore_row_best','column_work_final_row_best']:
        cases.append((n,name))
for name in ['column_work_fast_column','column_work_checked8_column','column_work_fast_row_best','column_work_restore_row_best','column_work_final_row_best']:
    cases.append((512,name))
'''
# The private packet-local column target was intentionally not built earlier;
# the already-built triangular column target has exactly the same active path.
cases=cases.replace('column_work_packet_local_column','triangular_stream_column')
Path('.scratch/run-qr-final-controls.py').write_text(code[:start]+cases+code[end:])
