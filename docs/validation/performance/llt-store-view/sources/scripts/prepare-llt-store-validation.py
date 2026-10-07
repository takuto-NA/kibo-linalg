from pathlib import Path
p=Path('.scratch/large-llt-scan-linux.py')
Path('.scratch/llt-store-linux.py').write_text(p.read_text().replace('large-llt-scan-validation','llt-store-validation').replace('large-llt-scan-linux.sh','llt-store-linux.sh'))
p=Path('.scratch/large-llt-scan-linux.sh')
s=p.read_text().replace('large-llt-scan-validation','llt-store-validation')
s=s.replace('--target kibo_llt_tests kibo_llt_scalar_tests kibo_llt_large_tests kibo_llt_large_scalar_tests kibo_no_runtime_tests kibo_allocation_tests kibo_common_2x2 kibo_numerical_tests ','')
s=s.replace(" -R '^(llt|llt_scalar|llt_large|llt_large_scalar|no_runtime|allocation|common_2x2|numerical|numerical_column)$'",'')
Path('.scratch/llt-store-linux.sh').write_text(s,newline='\n')
