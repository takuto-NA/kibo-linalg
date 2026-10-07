# Hardware and API follow-up probes

Windows/MSVC diagnostics only, independent of the public library build/install.
This project uses frozen `../eigen-root-cause` and `../eigen-gap` headers. It
measures LLT stride effects, a read-only stride control, projection loops, and
the public LLT symmetry option. Two compiler assembly listings check the
scalar/packed instruction paths of a diagnostic column-dot wrapper.

From the repository root, after verifying the pinned Eigen archive/headers with
the main collector:

```powershell
python tools/diagnostics/eigen-hardware-cause/collect.py
```

The collector requires a new empty
`docs/validation/performance/eigen-root-cause/hardware` directory. Existing
evidence is never overwritten. Adapt its output path in a separate diagnostic
copy when replaying. It makes a fresh build, clears inherited flags, and runs
all load tests serially on CPU0. On this machine CPUID confirms CPU0 as a P-core.
The manifest records source/binary hashes and exact commands. It owns three
fresh process runs per target. The projection harness defaults to internal
process index 0 when no index is passed, as in the committed commands; method
order is still rotated/reversed for every sample, and external run indices are
distinct in the manifest. This README was added after the measured run.

The symmetry-disabled variant is a workload-cost diagnostic on symmetric input,
not certification of the default symmetric-input checks. Timed phase averages
and total medians must not be subtracted as if they were identical statistics.
Stride changes also affect pages/prefetch/TLB. Read-only timing and cache geometry
support a cache-conflict hypothesis but do not measure L1 miss counts.

`probe-pmu.wprp` defines bounded WPR CSwitch counter profiles. The collector does
not start a recorder. The separate recording attempt was denied by Windows
(`0x80070005`) before a session started; no PMU counts are available. Record only
with an unused recorder/counter state, a unique instance, and cleanup of that
owned instance. Whole-process counts include fixture/setup/verification and
cannot be labeled LLT-only without additional markers. Raw system ETL belongs
in ignored scratch storage, not the published numerical evidence.

See [the report](../../../docs/research/eigen-root-cause.md) and
[recorded measurements](../../../docs/validation/performance/eigen-root-cause/hardware/).
