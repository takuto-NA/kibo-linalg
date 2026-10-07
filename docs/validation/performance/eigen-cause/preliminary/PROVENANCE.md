# Preliminary diagnostic series

This valid first 3-process series preceded the collector reproducibility fix.
It reused a build cache. Independent review verified that this particular cache
used the expected Eigen path and flags, but found future invocations could inherit
different values. The final series in the parent directory uses a fresh build,
explicit Eigen path/flags, and verified archive headers.

The original measurements and manifest are preserved byte-for-byte, without
selecting the faster series as the final result. The original collector and README
are archived as snapshot-measure.py and snapshot-README.md; their SHA256 matches
the corresponding original manifest source entries. Other snapshotted source
files did not change between series. Original SHA256SUMS.txt remains unchanged;
the parent SHA256SUMS.txt also covers these archive files and this note.

This collector snapshot is evidence, not the recommended reproduction command.
Use tools/diagnostics/eigen-gap/measure.py for a new run.
