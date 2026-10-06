#!/bin/sh
set -eu
compiler=${1:-g++}
build_dir=${2:-build/linux-gcc}
cmake=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/cmake
ctest=/work/.cache/tools/cmake-3.30.5-linux-x86_64/bin/ctest
mkdir -p /work/.cache/tools
if [ ! -x "$cmake" ]; then
    printf '%s  %s\n' f747d9b23e1a252a8beafb4ed2bc2ddf78cff7f04a8e4de19f4ff88e9b51dc9d /work/.cache/downloads/cmake-3.30.5-linux-x86_64.tar.gz | sha256sum -c -
    tar -xzf /work/.cache/downloads/cmake-3.30.5-linux-x86_64.tar.gz -C /work/.cache/tools
fi
"$compiler" --version
"$cmake" --version
test_failures=0
for configuration in Debug Release; do
    directory="$build_dir/$configuration"
    "$cmake" -S . -B "$directory" -DCMAKE_BUILD_TYPE="$configuration" -DCMAKE_CXX_COMPILER="$compiler" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ${KIBO_CMAKE_OPTIONS:-}
    "$cmake" --build "$directory" --parallel 4
    if ! "$ctest" --test-dir "$directory" --output-on-failure --no-tests=error; then
        test_failures=$((test_failures+1))
    fi
done
prefix="/work/$build_dir/install-original"
relocated="/work/$build_dir/install-relocated"
"$cmake" --install "$build_dir/Release" --prefix "$prefix"
# Both paths are build products within this workspace; never replace an existing destination.
if [ -e "$relocated" ]; then
    relocated="$relocated-$(date +%s)"
fi
mv "$prefix" "$relocated"
"$cmake" -U kibo_linalg_DIR -S tests/installed_consumer -B "$build_dir/consumer" -DCMAKE_PREFIX_PATH="$relocated" -DCMAKE_CXX_COMPILER="$compiler" ${KIBO_CMAKE_OPTIONS:-}
"$cmake" --build "$build_dir/consumer" --parallel 4
"$ctest" --test-dir "$build_dir/consumer" --output-on-failure --no-tests=error
if [ "$test_failures" -ne 0 ]; then
    printf 'CTest failed in %s configuration(s); all results retained\n' "$test_failures" >&2
    exit 1
fi
