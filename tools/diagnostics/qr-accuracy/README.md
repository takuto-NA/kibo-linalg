# Rounded-input QR accuracy diagnosis

This is an opt-in diagnostic. The frozen original prototype has no public
range/status/workspace contract. The audit now also calls the separately
approved public API in `<kibo/qr_refined.hpp>` and emits `publicRefinedStatus`
and `publicRefined`; the oracle checks that output against the same actual A/b.
It retains the actual original A/b and current double QR R/permutation.
Eigen and mpmath are diagnostic dependencies only.

```powershell
cmake -S tools/diagnostics/qr-accuracy -B build/qr-accuracy -G "Visual Studio 17 2022" -A x64
cmake --build build/qr-accuracy --config Release
build/qr-accuracy/Release/audit.exe > build/qr-accuracy/rounded.jsonl
python tools/diagnostics/qr-accuracy/oracle.py build/qr-accuracy/rounded.jsonl
build/qr-accuracy/Release/cost.exe > build/qr-accuracy/cost.jsonl
build/qr-accuracy/Release/public-cost.exe > build/qr-accuracy/public-cost.jsonl
```

Clear inherited compiler flags and normalize Windows environment key case.
Pinned compiler/Eigen versions match the repository's dependency lock.
The oracle uses mpmath 1.3.0 at 100 decimal digits, after reconstructing each
17-digit number as its exact IEEE double. Its power-of-two normalization is
performed in high precision; it does not replace the input with rounded
double A/scale or b/scale.

Small inputs use independent high-precision QR. For n>8, the audit checks
EVERY actual matrix entry has the same bits as firstRow[(i mod n) xor j].
The oracle then diagonalizes that actual rounded XOR-circulant matrix with
an exact Hadamard transform and averages the actual repeated-row RHS.
The requested pre-generation singular spectrum is not used to solve it.
No native SVD implementation or library-generated solution is the oracle.

The diagnostic compares raw core/Eigen, normalized Eigen, ordinary double
refinement, and double-double residual/gradient refinement. It preserves
original matrix/RHS hashes, forward/backward/optimality errors and residual
angles. Normality alone does not imply small forward error in these cases.

The cost probe runs sequentially on CPU0/P-core, warms up five times, and
uses five samples with >=20ms batch durations. It measures prepared column
QR factor+solve and the additional two-step prototype refinement separately.
Prototype allocations ARE included; these costs are not final public API
benchmarks. Do not run while building or running other test/benchmark work.
The public API uses 2m+3n doubles. `public-cost` excludes setup, runs the
allocation-free public API, and distinguishes ordinary solve (phase 0),
refined solve including its initial ordinary solve (1), factor+ordinary solve
(2), and factor+refined solve (3). It retains the original matrix during each
call. These five-sample single-process costs are diagnostics; they do not
replace the formal repeated-process Eigen performance comparison.
