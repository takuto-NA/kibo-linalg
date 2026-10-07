#!/bin/sh
set -eu
name=$1
cmake=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/cmake
ctest=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/ctest
out=".scratch/large-llt-scan-validation/$name"
mkdir -p "$out"
for config in Debug Release; do
  directory="build/qr-refined-$name/$config"
  "$cmake" -S . -B "$directory" -DCMAKE_BUILD_TYPE="$config" -DKIBO_EIGEN_INCLUDE_DIR=/work/.cache/eigen > "$out/$config-configure.log" 2>&1
  "$cmake" --build "$directory" --target kibo_llt_tests kibo_llt_scalar_tests kibo_llt_large_tests kibo_llt_large_scalar_tests kibo_no_runtime_tests kibo_allocation_tests kibo_common_2x2 kibo_numerical_tests --parallel 4 > "$out/$config-build.log" 2>&1
  if "$ctest" --test-dir "$directory" --output-on-failure --no-tests=error -R '^(llt|llt_scalar|llt_large|llt_large_scalar|no_runtime|allocation|common_2x2|numerical|numerical_column)$' > "$out/$config-ctest.log" 2>&1; then
    printf '%s %s pass\n' "$name" "$config"
  else
    printf '%s %s preserved failures\n' "$name" "$config"
    tail -n 8 "$out/$config-ctest.log"
  fi
done
