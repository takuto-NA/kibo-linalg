# Eigen gap diagnosis (2026-10-07)

This directory contains **isolated experimental snapshots**, not installed library
headers or a replacement for the public core. The root CMake build does not include
it. The base core/test source is commit
`83c7a143599cd9e73bc97e6ecae3680daee3418f`; `qr.hpp`, `llt.hpp`, and
`detail/row_kernels.hpp` contain diagnostic clocks and conditional experiments.
Other headers and public test sources are unchanged snapshots from that commit.
No Eigen implementation was copied into these snapshots.

On Windows, install Python, CMake >=3.30, and Visual Studio 2022 C++ tools; obtain
the locked Eigen archive with the repository dependency fetcher. From the repo root:

```powershell
python tools/diagnostics/eigen-gap/measure.py --output .scratch/eigen-gap-repeat --processes 3
```

The collector validates the locked archive and every extracted Eigen header,
builds Release x64 targets in a new build directory, then runs them serially.
The Eigen path and Release flags are explicitly configured; inherited compiler
flag environment variables are removed. Logs, source/binary hashes,
compiler metadata, raw outputs, and process median summaries are saved. Its output
directory must be new and empty. The recorded CPU profile is not imposed
on another machine. The collector exits nonzero for an invalid observation or a
failed contract test. A probe exit 1 only reports its **local diagnostic target**
of core/Eigen <=1.1; it does not mean an accuracy failure or a release speed gate.

QR uses a known-solution 1024x512 fixture, one warmup and three alternating-order
factor+solve samples per process. LLT uses a 512x512 Gram matrix generated from a
2048x512 fixture, two warmups and ten alternating-order samples (upper median,
index 5). Each backend must produce finite solutions within absolute 1e-10 of
the known solution. Prepared buffers, fixture generation, and Eigen input layout
conversion are outside the timer; core factor input copying is inside. Phase
counters include warmups and measure arithmetic subphases, whereas the JSON wall
times are measured-sample medians. Instrumentation overhead is present in the core.
These short probes are for causal diagnosis, **not** the five-process benchmark
protocol in Issue 16, ill-conditioned numerical certification, allocation auditing,
or portability validation.

Important targets:

| Target | Change relative to diagnostic baseline |
| --- | --- |
| `qr_eigen_row` | Eigen row-major instead of column-major; core unchanged |
| `qr_row_unchecked` | Remove checks from factor row updates only; ablation |
| `qr_column_scalar` | Core column-major factor storage, original scalar column loop |
| `qr_column_simd` | Column storage plus contiguous dot/update kernels |
| `qr_column_four` | Above plus shared Householder loads across four projected columns |
| `qr_factor_deferred` | Above plus tiled copy and factor-update checks deferred to subsequent norm/projection checks; solve checks retained |
| `qr_unsafe_all_unchecked` | Tiled/four-column path with all update checks removed, including solve; deliberately unsafe negative control |
| `llt_width64` | Panel width 64 instead of 8 |
| `llt_padded` | Caller factor row stride 513 instead of 512 |
| `llt_column` | Temporary column-oriented blocked factor in transposed caller storage, tiled commit to public lower-triangular layout |
| `llt_column_fast` | Above plus wider update loop and conservative symmetry-check shortcut; prototype only |

Every QR executable also checks a two-row solve whose residual transformation
overflows: it must return `arithmetic_failure` and preserve the caller output.
The unsafe negative control must fail this check and exit 3; the collector records
that as the expected observation, **not as a valid implementation**. A benign
fixture passing accuracy alone cannot justify removing checks.

`qr_contracts`, `llt_contracts`, and `llt_fast_contracts` execute the snapshotted
public tests against their experimental paths. Passing them is evidence for those
tests only. In particular, deferred checking may change an arithmetic failure's
diagnostic index; it has not received full numerical/contract certification.

Unused conditional branches are retained as research scratch within this clearly
marked diagnostic directory. Do not promote these headers into `include/` without
review, full numerical/contract tests, allocation/portability checks, and formal
multi-shape Eigen comparisons. See [the research report](../../../docs/research/eigen-kernel-gap.md).
