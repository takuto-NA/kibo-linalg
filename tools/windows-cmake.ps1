param([Parameter(ValueFromRemainingArguments = $true)][string[]]$CMakeArguments)
$ErrorActionPreference = 'Stop'
# Windows treats environment names case-insensitively. Some launchers supply
# both PATH and Path; Framework MSBuild rejects that inherited environment.
$start = [System.Diagnostics.ProcessStartInfo]::new((Get-Command cmake.exe).Source)
$start.UseShellExecute = $false
$normalized = [System.Collections.Generic.Dictionary[string,string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($entry in [Environment]::GetEnvironmentVariables().GetEnumerator()) {
    $normalized[$entry.Key] = $entry.Value
}
$start.Environment.Clear()
foreach ($entry in $normalized.GetEnumerator()) { $start.Environment[$entry.Key] = $entry.Value }
foreach ($argument in $CMakeArguments) { $start.ArgumentList.Add($argument) }
$process = [System.Diagnostics.Process]::Start($start)
$process.WaitForExit()
exit $process.ExitCode
