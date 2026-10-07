#!/bin/sh
set -eu
compiler=$1
name=$2
cmake=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/cmake
for scalar in OFF ON; do
  directory="build/qr-accuracy-${name}-${scalar}"
  "$cmake" -S tools/diagnostics/qr-accuracy -B "$directory" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="$compiler" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DKIBO_DIAGNOSTIC_SCALAR="$scalar"
  "$cmake" --build "$directory" --parallel 4
  "$directory/audit" > ".scratch/qr-accuracy-next/${name}-${scalar}.jsonl"
done
