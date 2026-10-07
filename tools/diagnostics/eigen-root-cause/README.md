# Eigen gap ablation snapshot

This Windows/MSVC-only project is independent of the public build/install. The
copied QR/LLT headers add timing and experimental branches; they are not an API
or portability guarantee. Other headers/tests come from the unchanged
`../eigen-gap` snapshot, based on public source commit
`83c7a143599cd9e73bc97e6ecae3680daee3418f`.

From the repository root, with CMake, Python and VS 2022 available:

```powershell
python tools/diagnostics/eigen-root-cause/collect.py --output .scratch/root-cause-replay --processes 5 --samples 30
```

Use a new empty output directory. The collector verifies the pinned Eigen
archive and headers, clears inherited compiler flags, makes a fresh build,
pins each process to CPU0, and runs variants serially. CPU0 is a verified P-core
on the recorded i9-14900K; this is machine-specific. CPU assumptions must be
reviewed before running on another machine. Exit 1 from a solver means its local
speed target was missed, while other exit values identify diagnostic failures.

`--build-only` and `--reuse-build` support separating preparation and timing.
Reuse checks source hashes; an independent comparison with the original build's
binary hashes is additionally required. Fresh builds are the default.

The committed measurement records contain the source/binary hashes of files
present during measurement, compiler flags, commands, process order, all raw
samples, oracle/control outcomes and checksums. This README was added after
measurement. Keep those recorded files unchanged when interpreting that run.

See [the causal report](../../../docs/research/eigen-root-cause.md) for results,
one-variable boundaries, and the distinction between normal-fixture checks and
full public-contract acceptance. The separate
[`eigen-hardware-cause`](../eigen-hardware-cause/) project holds follow-up probes.
