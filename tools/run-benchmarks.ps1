param([string]$Executable='build/native/Release/kibo_dense_benchmark.exe',[string]$OutputDirectory='build/benchmarks-primary',
      [string]$Configuration='Release /O2 /fp:precise; fast-math off; Eigen single-thread; default x64 SIMD',
      [switch]$LinuxScalar)
$ErrorActionPreference='Stop'
$taskLock=Get-Content (Join-Path $PSScriptRoot 'toolchains.lock.json') -Raw | ConvertFrom-Json
$taskRoot=(Get-Location).Path
if(Test-Path -LiteralPath $OutputDirectory) {
    if(!(Test-Path -LiteralPath $OutputDirectory -PathType Container) -or
       @(Get-ChildItem -LiteralPath $OutputDirectory -Force).Count -ne 0) {
        throw 'Benchmark output directory must be empty; choose a fresh directory to preserve existing evidence'
    }
}
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$taskMetadata=@{
    measuredAt=[DateTimeOffset]::UtcNow.ToString('o')
    sourceCommit=(& git rev-parse HEAD)
    cpu=(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores,NumberOfLogicalProcessors)
    os=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber)
    compiler='MSVC 19.44.35222.0, toolset14.44.35207'
    configuration=$Configuration
    fixtureSeed='0x6b69626f'; minimumSampleMilliseconds=20; samples=30; warmup=5; processRuns=5
    layout='kibo row-major; Eigen column-major; input conversion reported separately'
    executableSha256=(Get-FileHash -LiteralPath $Executable -Algorithm SHA256).Hash.ToLowerInvariant()
    solver='lambda=1e-3, D=I; normal-LLT and augmented-QR; rank tolerance=max(m_aug,n)*epsilon'
    timing='fixed batches; start/end clock reads; rejected batches shorter than 20ms are repeated with doubled iteration count'
    sourceHashes=@(Get-FileHash -Algorithm SHA256 -LiteralPath benchmarks/dense.cpp,tests/controlled_fixture.hpp,include/kibo/linalg.hpp,include/kibo/workspace.hpp,include/kibo/llt.hpp,include/kibo/qr.hpp,include/kibo/detail/row_kernels.hpp,CMakeLists.txt |
        Select-Object Hash,@{Name='File';Expression={ [IO.Path]::GetRelativePath((Get-Location).Path,$_.Path) }})
}
$taskMetadata | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputDirectory 'metadata.json') -Encoding utf8
if($LinuxScalar) {
    $taskMetadata.compiler='Clang20.1.8/libc++20.1.8'
    $taskMetadata.configuration='Release -O3 -DNDEBUG -stdlib=libc++; EIGEN_DONT_VECTORIZE; KIBO_DISABLE_SIMD; -fno-vectorize -fno-slp-vectorize -ffp-contract=off; single-thread'
    $taskMetadata.targetOs='Linux Debian13 in Docker; host OS recorded separately'
    $taskMetadata.image=$taskLock.gcc.image
    $taskMetadata.llvmArchiveSha256=$taskLock.llvm.sha256
    $taskMetadata.kernel=(& docker run --rm $taskLock.gcc.image uname -a)
    if($LASTEXITCODE -ne 0){throw 'Cannot capture Linux metadata'}
    $taskMetadata | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $OutputDirectory 'metadata.json') -Encoding utf8
}
for($taskRun=1;$taskRun -le 5;$taskRun++) {
    Write-Output "benchmark process run $taskRun/5"
    if($LinuxScalar) {
        & docker run --rm --mount "type=bind,source=$taskRoot,target=/work" -w /work $taskLock.gcc.image "/work/$Executable" $taskRun > (Join-Path $OutputDirectory "run-$taskRun.csv") 2> (Join-Path $OutputDirectory "run-$taskRun.stderr.log")
    } else {
        & $Executable $taskRun > (Join-Path $OutputDirectory "run-$taskRun.csv") 2> (Join-Path $OutputDirectory "run-$taskRun.stderr.log")
    }
    if($LASTEXITCODE -ne 0) { throw "Benchmark run $taskRun failed; inspect its stderr log" }
}
Get-ChildItem -LiteralPath $OutputDirectory -File | Get-FileHash -Algorithm SHA256 |
    Select-Object Hash,@{Name='File';Expression={Split-Path $_.Path -Leaf}} |
    ConvertTo-Json | Set-Content (Join-Path $OutputDirectory 'checksums.json') -Encoding utf8
