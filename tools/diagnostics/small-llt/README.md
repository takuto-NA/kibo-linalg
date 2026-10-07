# Small LLT diagnosis

This is an opt-in Windows/MSVC diagnostic, outside the portable core build.
Eigen is pinned by the repository's dependency lock. All timed processes run
sequentially on logical CPU0; the probe requires a P-core and records SSE2.

```powershell
python tools/diagnostics/small-llt/prepare.py
python tools/diagnostics/small-llt/current-probes.py
python tools/diagnostics/small-llt/prepare-full.py
cmake -S tools/diagnostics/small-llt -B build/small-llt -G "Visual Studio 17 2022" -A x64 -DEIGEN_SOURCE_DIR="$PWD/.cache/eigen"
cmake --build build/small-llt --config Release --parallel 4
python tools/diagnostics/small-llt/run.py --n 31
python tools/diagnostics/small-llt/paired.py
python tools/diagnostics/small-llt/run-full.py
```

Clear inherited CL, _CL_, CFLAGS, CXXFLAGS, and LDFLAGS and normalize Windows
environment key case before building. Compiler flags are /O2 /fp:precise, with
no fast-math or AVX override. Baseline headers are extracted from the recorded
Git commit. Each alternative changes one operation or an explicitly named
combination; it never edits the public headers.

`run.py` is a short diagnosis, not release acceptance. `paired.py` uses five
fresh processes and 30 alternating samples per process by default, checks
answers and input hashes, and verifies both batch durations are >=20 ms.
The underlying public probe's exit 1 is its historical >1.1 diagnostic signal;
it is not an agreed Eigen-equivalence allowance. Raw ratios and intervals are
the evidence, and no tolerance is silently added.

The full probe has phases factor, solve, factor+solve, and setup/copy/factor/
solve. Setup owns temporary input/factor/work/output and transfers the result
to the existing output owner for validation outside the timed batch. Both
implementations consume the result and check answers after every sample.

Do not benchmark while compiling or running another benchmark/test workload.
Keep rejected runs and compiler/object/binary/source hashes. Compare the
actual selected branch and its object-code disassembly; static instruction
counts over inactive branches are not dynamic operation counts.

`current-probes.py` reads the saved pre-validation header snapshot and generates independent controls
for accumulated products, SIMD remainder width, diagonal summation, and flat
input scanning. The `c_no_*` controls deliberately violate input validation
contracts; their only purpose is measuring the remaining validation cost.
They cannot be adopted as public implementations.
The snapshot predates the four-accumulator scan and tiled symmetry validation;
`actual` and `after_full` always compile the public headers. An explicit
`--include` can select another snapshot with the same starting structure.

`disassemble.py` saves dumpbin output from the actual COFF objects. Its selected
files retain machine offsets, opcodes, and relocated call names; the matching
compiler listing and hashes identify the exact functions and objects.
