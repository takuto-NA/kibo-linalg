# Assembly-level diagnosis of the remaining LLT gap

This directory is a Windows/MSVC diagnostic, not part of the library install.
`prepare.py` extracts immutable public headers from `c3c10df` into
`build/assembly-gap/variants/` and creates narrowly scoped variants. It never
edits the public headers. `no_validation` intentionally violates the public
contract and is a cost-isolation control only.

From the repository root, with the locked Eigen cache present:

```powershell
python tools/diagnostics/assembly-gap/prepare.py
cmake -S tools/diagnostics/assembly-gap -B build/assembly-gap -G "Visual Studio 17 2022" -A x64 -DEIGEN_SOURCE_DIR="<absolute .cache/eigen path>"
cmake --build build/assembly-gap --config Release --parallel 4
build/assembly-gap/Release/micro.exe
build/assembly-gap/Release/baseline.exe 32 15
build/assembly-gap/Release/fused_panel_inline.exe 32 15
build/assembly-gap/Release/public_solver.exe 0 30 32 128
```

`micro` uses separate-translation-unit noinline kernels and rotating order. It
checks scalar/packet/Eigen results before timing. Its input contains only finite
numbers; it does not replace public invalid-input tests. `kernels.asm` is the
compiler's source-interleaved listing; `kernels-disassembly.txt` in the recorded
evidence is a dumpbin disassembly of the actual object file. `public_finite.asm`
shows the promoted inline scalar classifier.

`phases.cpp` uses the same fixed well-conditioned fixture, single P-core, fixed
SSE2, no fast-math, normal system with damping 1e-3, and checks against an
independent LDLT solution. It measures factor, solve and factor+solve separately.
Its Eigen solve timing includes `allFinite()`; the separate public API comparison
uses the existing solver-locality probe, with accuracy checking outside timing.

`collect.py` runs the 9 variants at n32/m128, 3 fresh processes and 15 alternating
samples per phase, with >=20 ms measured batches. This is a diagnostic series,
not the full performance acceptance matrix. It refuses to overwrite its output.
`public_compare.py` compares the actual public implementation with the immutable
baseline using the existing public-API probe. The target n32/m128 uses 5 processes
and 30 samples. The surrounding sizes use 3 processes and 15 samples. It records
failures as well as successes and verifies source/binary hashes after measurement.
Do not run builds or other CPU work concurrently with either collector.

The historical evidence's `sources/` directory preserves the exact diagnostic
sources at the first collection. Afterwards the CMake project gained targets for
the promoted public implementation and pinned the microkernel include to the
same baseline. Original source/binary hashes and raw observations are preserved;
later additions must not be confused with the earlier executable's provenance.
