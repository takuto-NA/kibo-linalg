# Public solver locality comparison

Windows/MSVC-only diagnostic harness, independent of the library build/install.
Run from the repository root:

```powershell
python tools/diagnostics/solver-locality/collect.py --output .scratch/locality-replay --processes 5
```

The output directory must be empty. The collector verifies the locked Eigen
archive and header bytes, extracts the **uninstrumented** public headers from
commit `83c7a143599cd9e73bc97e6ecae3680daee3418f`, rebuilds both versions from the
same harness, and checks source/binary hashes before and after measurement.
CPU0 must be a P-core, as verified by CPUID on the measured i9-14900K.

For n=2/8/32/128/512 and m=n/4n, it measures LLT row factor storage and QR row and
column factor storage. Eigen uses column-major native input/factor storage in
all cases. Inputs are the same damped normal system or augmented QR system.
External preparation and Eigen input conversion are outside timing; each
library's internal copy, validation, factorization and solve are inside.
This comparison does not replace the separate setup/allocation/capacity gate.

Five warmups precede calibration to a common batch of at least 25 ms per backend.
Thirty samples alternate backend order; the collector rejects observations with
a measured batch under 20 ms. Targets/shapes are shuffled per external process
index; executions are serial. Each solution is checked against an independent
LDLT oracle on the well-conditioned benchmark input. Every QR run also checks
the residual-overflow/output-preservation negative case.

Solver exit 1 means the local Eigen-ratio target of 1.1 was missed, not a failed
accuracy check; collection records it without claiming parity. A successful
collection means all observations passed their validity checks. `summary.json`
uses medians of process medians, and medians of process-level ratios of medians.
Retain all raw samples, including slow cases. This README was added after the
initial measurement began and is not an input to the numerical build.

If a whole timing process is rejected because any batch is shorter than 20 ms,
`python tools/diagnostics/solver-locality/retry.py <output-directory>` repeats
that complete process with the same executable and input. It preserves the
original manifest/raw, records the reason and selects only complete valid
processes in `accepted-manifest.json`. It never retries a numerical failure or
selects a result because it is faster. A run with no rejected observations also
uses this command to create the accepted manifest without new measurements.

Verify and aggregate accepted observations with:

```powershell
python tools/diagnostics/solver-locality/summarize.py <output-directory>
```

`comparisons.json` uses the accepted manifest, includes median and per-process
nearest-rank p95 (then median over five processes), and exact empirical-bootstrap
intervals. The collector's original `summary.json` remains an unfiltered record
of the first pass; it is not the accepted result when retries occurred.
