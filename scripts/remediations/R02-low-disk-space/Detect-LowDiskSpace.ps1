<#
.SYNOPSIS
    Detects low free disk space on the C: drive.

.DESCRIPTION
    A nearly full system drive causes failed updates, crashes and support
    tickets. The device is non-compliant when free space falls below the
    threshold.

    Exit codes:
      0 = enough free space
      1 = below the threshold, Intune runs the remediation script

    Written for Windows PowerShell 5.1.
#>

$thresholdPercent = 15

$drive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"

if (-not $drive -or $drive.Size -eq 0) {
    Write-Output "Non-compliant: could not read the size of drive C:."
    exit 1
}

$freePercent = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)
$freeGB = [math]::Round($drive.FreeSpace / 1GB, 1)

if ($freePercent -lt $thresholdPercent) {
    Write-Output "Non-compliant: C: has $freePercent% free ($freeGB GB). Threshold is $thresholdPercent%."
    exit 1
}

Write-Output "Compliant: C: has $freePercent% free ($freeGB GB)."
exit 0
