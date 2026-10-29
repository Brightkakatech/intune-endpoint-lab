<#
.SYNOPSIS
    Frees disk space by removing old temporary files.

.DESCRIPTION
    Deletes files older than 7 days from the Windows temp folder and from each
    user's temp folder. It deliberately does NOT touch documents, downloads or
    the Recycle Bin, because deleting user data automatically is risky.

    If the drive is still low after cleaning, Intune reports the issue as
    recurring. That is the signal for a human to investigate.

    Exit codes:
      0 = clean-up ran
      1 = clean-up failed

    Written for Windows PowerShell 5.1. Runs as SYSTEM through Intune.
    Test only in the lab VM, never on your own laptop.
#>

$maxAgeDays = 7
$cutoff = (Get-Date).AddDays(-$maxAgeDays)

try {
    $before = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace

    $tempPaths = @(Join-Path $env:SystemRoot 'Temp')
    $tempPaths += Get-ChildItem -Path 'C:\Users' -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName 'AppData\Local\Temp' }

    foreach ($path in $tempPaths) {
        if (Test-Path -Path $path) {
            Get-ChildItem -Path $path -Recurse -Force -File -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt $cutoff } |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }

    $after = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
    $freedMB = [math]::Round(($after - $before) / 1MB, 1)

    Write-Output "Remediated: removed temp files older than $maxAgeDays days. Freed $freedMB MB."
    exit 0
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
