from pathlib import Path
source=Path('tools/diagnostics/small-llt/full.cpp').read_text()
before='''  for(int sample=0;sample<samples;++sample){double c,e;if((sample+process)%2){e=timed(ref,batch);c=timed(core,batch);}else{c=timed(core,batch);e=timed(ref,batch);}if(c<0||e<0||'''
after='''  for(int sample=0;sample<samples;++sample){double c,e;
  for(;;){if((sample+process)%2){e=timed(ref,batch);c=timed(core,batch);}else{c=timed(core,batch);e=timed(ref,batch);}
  if(c<0||e<0)return 5;if(std::min(c,e)>=.02)break;batch*=2;}
  if(c<0||e<0||'''
assert before in source
output=Path('.scratch/large-llt-next/full-adaptive.cpp')
output.write_text(source.replace(before,after).replace('"../solver-locality/affinity.hpp"','"../../tools/diagnostics/solver-locality/affinity.hpp"'))
cmake=Path('.scratch/large-llt-next/CMakeLists.txt');text=cmake.read_text()
variants=['actual','pair8_divide','symmetry','pair8_divide_sym','pair8_divide_forward_sym','forward4','pair8_divide_forward4_sym']
for variant in variants:text=text.replace(f'add_executable({variant} ../../tools/diagnostics/small-llt/full.cpp)',f'add_executable({variant} full-adaptive.cpp)')
cmake.write_text(text)
print('Added per-sample >=20ms batch calibration for the next diagnostic series')
