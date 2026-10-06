param([switch]$AllowToolchainInstall)
$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $PSScriptRoot
$taskLock=Get-Content (Join-Path $PSScriptRoot 'toolchains.lock.json') -Raw | ConvertFrom-Json
$taskVswhere=Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
function Find-FixedInstance {
    @(& $taskVswhere -products '*' -format json | ConvertFrom-Json) |
        Where-Object { $_.installationVersion -eq $taskLock.msvc.installation_version } |
        Select-Object -First 1
}
$taskInstance=Find-FixedInstance
if (!$taskInstance -and $AllowToolchainInstall) {
    $taskInstaller=Join-Path $taskRoot '.cache/downloads/vs_BuildTools-17.14.25.exe'
    $taskSignature=Get-AuthenticodeSignature -LiteralPath $taskInstaller
    if ($taskSignature.Status -ne 'Valid') { throw 'Microsoft installer signature invalid' }
    $taskInstallProcess=Start-Process -FilePath $taskInstaller -ArgumentList @('--quiet','--wait','--norestart','--nocache','--installPath','C:\kibo-vs17.14.25','--add','Microsoft.VisualStudio.Component.VC.Tools.x86.x64','--add','Microsoft.VisualStudio.Component.Windows11SDK.26100') -WindowStyle Hidden -PassThru -Wait
    if ($taskInstallProcess.ExitCode -notin @(0,3010)) { throw "VS installation failed: $($taskInstallProcess.ExitCode)" }
    $taskInstance=Find-FixedInstance
}
if (!$taskInstance) { throw 'Fixed VS2022 17.14.25 unavailable; newer hosted tools do not count as this baseline' }
$taskCompiler=Join-Path $taskInstance.installationPath "VC/Tools/MSVC/$($taskLock.msvc.toolset)/bin/Hostx64/x64/cl.exe"
if (!(Test-Path -LiteralPath $taskCompiler)) { throw 'Fixed MSVC toolset unavailable' }
if ((Get-FileHash -LiteralPath $taskCompiler -Algorithm SHA256).Hash.ToLowerInvariant() -ne $taskLock.msvc.cl_sha256) { throw 'cl.exe checksum mismatch' }
New-Item -ItemType Directory -Force (Join-Path $taskRoot 'build') | Out-Null
$taskInstance | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $taskRoot 'build/windows-toolchain.json') -Encoding utf8
$env:Path=(Join-Path $taskRoot '.cache/tools/cmake-3.30.5-windows-x86_64/bin')+';'+$env:Path
function Invoke-CMake {
    & (Join-Path $PSScriptRoot 'windows-cmake.ps1') @args
    if ($LASTEXITCODE -ne 0) { throw "CMake failed: $LASTEXITCODE" }
}
Invoke-CMake -S . -B build/ci-windows -G 'Visual Studio 17 2022' -A x64 -T "version=$($taskLock.msvc.toolset)" "-DCMAKE_GENERATOR_INSTANCE=$($taskInstance.installationPath)" "-DKIBO_EIGEN_INCLUDE_DIR=$taskRoot/.cache/eigen"
foreach($taskConfiguration in @('Debug','Release')) {
    Invoke-CMake --build build/ci-windows --config $taskConfiguration --parallel 4
}
Invoke-CMake --install build/ci-windows --config Release --prefix build/ci-windows/install-original
$taskSource=[IO.Path]::GetFullPath((Join-Path $taskRoot 'build/ci-windows/install-original'))
$taskDestination=[IO.Path]::GetFullPath((Join-Path $taskRoot "build/ci-windows/install-relocated-$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"))
if (!$taskSource.StartsWith($taskRoot+'\') -or !$taskDestination.StartsWith($taskRoot+'\')) { throw 'Move outside workspace' }
Move-Item -LiteralPath $taskSource -Destination $taskDestination
Invoke-CMake -S tests/installed_consumer -B build/ci-windows-consumer -G 'Visual Studio 17 2022' -A x64 "-DCMAKE_PREFIX_PATH=$taskDestination" "-DCMAKE_GENERATOR_INSTANCE=$($taskInstance.installationPath)"
Invoke-CMake --build build/ci-windows-consumer --config Release --parallel 4
$taskFailedConfigurations=@()
& ctest --test-dir build/ci-windows-consumer -C Release --output-on-failure --no-tests=error
if ($LASTEXITCODE -ne 0) { $taskFailedConfigurations+='installed consumer' }
foreach($taskConfiguration in @('Debug','Release')) {
    & ctest --test-dir build/ci-windows -C $taskConfiguration --output-on-failure --no-tests=error
    if ($LASTEXITCODE -ne 0) { $taskFailedConfigurations+=$taskConfiguration }
}
if ($taskFailedConfigurations.Count -gt 0) { throw "CTest failed: $($taskFailedConfigurations -join ', ')" }
