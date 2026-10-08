#!/bin/sh
set -eu
cmake=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/cmake
llvm=/work/.cache/tools/LLVM-20.1.8-Linux-X64
export CXXFLAGS=-stdlib=libc++
export LDFLAGS="-L$llvm/lib/x86_64-unknown-linux-gnu -Wl,-rpath,$llvm/lib/x86_64-unknown-linux-gnu"
"$cmake" -S . -B build/linux-scalar -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="$llvm/bin/clang++" \
    -DBUILD_TESTING=OFF -DKIBO_BUILD_EXAMPLES=OFF -DKIBO_SCALAR_EIGEN=ON -DKIBO_EIGEN_INCLUDE_DIR=/work/.cache/eigen \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
"$cmake" --build build/linux-scalar --target kibo_dense_benchmark --parallel 4
"$llvm/bin/clang++" --version
