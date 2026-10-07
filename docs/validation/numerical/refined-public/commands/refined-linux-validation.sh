#!/bin/sh
set -eu
compiler=$1
name=$2
cmake=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/cmake
ctest=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/ctest
out=".scratch/qr-refined-public/linux-$name"
mkdir -p "$out"
"$compiler" --version > "$out/compiler.txt"
for scalar in OFF ON; do
  directory="build/qr-refined-audit-$name-$scalar"
  "$cmake" -S tools/diagnostics/qr-accuracy -B "$directory" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="$compiler" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DKIBO_DIAGNOSTIC_SCALAR="$scalar" > "$out/audit-$scalar-configure.log" 2>&1
  "$cmake" --build "$directory" --target audit --parallel 4 > "$out/audit-$scalar-build.log" 2>&1
  "$directory/audit" > "$out/audit-$scalar.jsonl"
  printf '%s audit %s complete\n' "$name" "$scalar"
done
for config in Debug Release; do
  directory="build/qr-refined-$name/$config"
  "$cmake" -S . -B "$directory" -DCMAKE_BUILD_TYPE="$config" -DCMAKE_CXX_COMPILER="$compiler" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DKIBO_EIGEN_INCLUDE_DIR=/work/.cache/eigen > "$out/$config-configure.log" 2>&1
  "$cmake" --build "$directory" --parallel 4 > "$out/$config-build.log" 2>&1
  if "$ctest" --test-dir "$directory" --output-on-failure --no-tests=error > "$out/$config-ctest.log" 2>&1; then
    printf '%s %s CTest pass\n' "$name" "$config"
  else
    printf '%s %s CTest has failures; preserved\n' "$name" "$config"
    tail -n 8 "$out/$config-ctest.log"
  fi
done
