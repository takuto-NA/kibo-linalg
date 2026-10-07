#!/bin/sh
set -eu
emcc --version | head -1
mkdir -p build/wasm
em++ wasm/adapter.cpp -Iinclude -std=c++20 -O3 -DNDEBUG -fno-exceptions -fno-rtti \
    -sMODULARIZE=1 -sEXPORT_ES6=1 -sENVIRONMENT=web,node \
    -sINITIAL_MEMORY=16777216 -sMAXIMUM_MEMORY=134217728 -sSTACK_SIZE=65536 -sALLOW_MEMORY_GROWTH=1 -sABORTING_MALLOC=0 \
    -Wl,--wrap=malloc,--wrap=calloc,--wrap=realloc,--wrap=aligned_alloc \
  '-sEXPORTED_FUNCTIONS=["_kibo_allocate","_kibo_release","_kibo_abi_version","_kibo_allocation_count","_kibo_calibrate_allocation_probe","_kibo_matvec","_kibo_llt","_kibo_qr","_kibo_qr_refined"]' \
    '-sEXPORTED_RUNTIME_METHODS=["HEAPF64","HEAPU8"]' -o build/wasm/kibo.mjs
