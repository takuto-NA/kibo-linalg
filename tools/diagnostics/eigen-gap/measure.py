"""Reproduce isolated Windows/MSVC diagnosis; this is not the release speed gate."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import tarfile
import tempfile
import winreg
from datetime import datetime, timezone

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = "83c7a143599cd9e73bc97e6ecae3680daee3418f"
EIGEN = "bc3b39870ecb690a623a3f49149a358b95c5781d"
TARGETS = [
    "qr_baseline", "qr_eigen_row", "qr_row_unchecked", "qr_column_scalar",
    "qr_column_simd", "qr_column_four", "qr_factor_deferred",
    "qr_unsafe_all_unchecked", "llt_baseline", "llt_width64", "llt_padded",
    "llt_column", "llt_column_fast", "qr_contracts", "llt_contracts",
    "llt_fast_contracts",
]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--processes", type=int, default=3)
    args = parser.parse_args()
    if os.name != "nt" or args.processes < 1:
        parser.error("This recorded profile requires Windows and at least one process.")
    output = args.output.resolve()
    if output.exists() and any(output.iterdir()):
        parser.error('Use a new, empty output directory for each recorded run.')
    output.mkdir(parents=True, exist_ok=True)
    build_parent = ROOT / 'build'
    build_parent.mkdir(exist_ok=True)
    build = Path(tempfile.mkdtemp(prefix='eigen-gap-diagnostics-', dir=build_parent))
    env = {key.upper(): value for key, value in os.environ.items()}
    for key in ['CL', '_CL_', 'CXXFLAGS', 'CFLAGS', 'LDFLAGS']:
        env.pop(key, None)
    lock = json.loads((ROOT / "tools/toolchains.lock.json").read_text())['eigen']
    archive = ROOT / '.cache/downloads/eigen-5.0.1.tar.gz'
    if lock['commit'] != EIGEN or digest(archive) != lock['sha256']:
        raise RuntimeError('Eigen archive does not match the pinned toolchain lock.')
    # The dependency is an extracted archive, not a Git checkout. Verify every Eigen header.
    with tarfile.open(archive) as contents:
        for member in contents.getmembers():
            relative = Path(*Path(member.name).parts[1:])
            if member.isfile() and relative.parts and relative.parts[0] == 'Eigen':
                if (ROOT / '.cache/eigen' / relative).read_bytes() != contents.extractfile(member).read():
                    raise RuntimeError(f'Eigen header differs from the pinned archive: {relative}')
    actual_eigen = lock['commit']
    commands = [
        ["cmake", "-S", str(HERE), "-B", str(build), "-G", "Visual Studio 17 2022", "-A", "x64",
         f"-DEIGEN_SOURCE_DIR={ROOT / '.cache/eigen'}", "-DCMAKE_CXX_FLAGS_RELEASE=/O2 /Ob2 /DNDEBUG"],
        ["cmake", "--build", str(build), "--config", "Release", "--target", *TARGETS],
    ]
    for index, command in enumerate(commands):
        result = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (output / f"build-{index}.log").write_bytes(result.stdout)
        if result.returncode:
            sys.stdout.buffer.write(result.stdout)
            return result.returncode
    compiler = next(build.glob("CMakeFiles/*/CMakeCXXCompiler.cmake"))
    (output / "CMakeCXXCompiler.cmake").write_bytes(compiler.read_bytes())
    with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r'HARDWARE\DESCRIPTION\System\CentralProcessor\0') as key:
        cpu_name = winreg.QueryValueEx(key, 'ProcessorNameString')[0].strip()
    cpu = {'name': cpu_name, 'logicalProcessors': os.cpu_count(),
           'nameSource': 'Windows processor registry'}
    manifest = {
        "startedUtc": datetime.now(timezone.utc).isoformat(),
        "baseSourceCommit": BASE, "eigenCommit": actual_eigen, "cpu": cpu,
        "windowsVersion": list(sys.getwindowsversion()),
        "cmakeEffectiveFlags": [line for line in (build / 'CMakeCache.txt').read_text().splitlines()
                                if line.startswith(('CMAKE_CXX_FLAGS', 'EIGEN_SOURCE_DIR:'))],
        "processesPerProbe": args.processes, "commands": commands,
        "sourceSha256": {str(p.relative_to(ROOT)).replace('\\', '/'): digest(p)
                         for p in sorted(HERE.rglob('*')) if p.is_file() and '__pycache__' not in str(p)},
        "binarySha256": {name: digest(build / f"Release/{name}.exe") for name in TARGETS},
        "profile": "MSVC x64 Release /O2 /fp:precise; C++20; EIGEN_DONT_PARALLELIZE=1; no /arch override",
        "records": [],
    }
    failed = False
    # All builds finish first. Each executable then runs serially, with no concurrent build.
    for process in range(args.processes):
        for name in TARGETS:
            if name.endswith("contracts") and process > 0:
                continue
            result = subprocess.run([str(build / f"Release/{name}.exe")], env=env,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            raw = f"{name}-{process}.txt"
            (output / raw).write_bytes(result.stdout)
            lines = result.stdout.decode(errors="replace").splitlines()
            metric = next((json.loads(line) for line in lines if line.startswith('{')), None)
            unsafe = name == "qr_unsafe_all_unchecked"
            if name.endswith("contracts"):
                valid = result.returncode == 0
            else:
                valid = metric is not None and metric.get("accuracyPassed") is True
                valid = valid and (result.returncode == 3 if unsafe else result.returncode in (0, 1))
                if name.startswith("qr"):
                    expected = "residual-overflow-output-preserved=" + ("0" if unsafe else "1")
                    valid = valid and any(expected in line for line in lines)
            failed = failed or not valid
            record = {"target": name, "process": process, "raw": raw,
                      "exitCode": result.returncode, "observationValid": valid, "metric": metric}
            manifest["records"].append(record)
            print(json.dumps(record), flush=True)
    manifest["finishedUtc"] = datetime.now(timezone.utc).isoformat()
    (output / "manifest.json").write_bytes((json.dumps(manifest, indent=2) + '\n').encode())
    summaries = {}
    for name in TARGETS:
        metrics = [r['metric'] for r in manifest['records'] if r['target'] == name and r['metric']]
        if metrics:
            summaries[name] = {
                'coreMs': statistics.median(m['coreSeconds'] * 1000 for m in metrics),
                'eigenMs': statistics.median(m['eigenSeconds'] * 1000 for m in metrics),
                'medianProcessRatio': statistics.median(m.get('coreOverEigen', m.get('ratio')) for m in metrics),
            }
    (output / "summary.json").write_bytes((json.dumps(summaries, indent=2) + '\n').encode())
    paths = sorted(p for p in output.iterdir() if p.is_file() and p.name != "SHA256SUMS.txt")
    (output / "SHA256SUMS.txt").write_bytes(''.join(f'{digest(p)}  {p.name}\n' for p in paths).encode())
    return 2 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
