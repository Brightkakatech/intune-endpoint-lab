<#
.SYNOPSIS
    Re-enables the Windows Update service.

.DESCRIPTION
    Sets the Windows Update service (wuauserv) back to its default start type
    (Manual) and starts it. Runs as SYSTEM when deployed through Intune.

    Exit codes:
      0 = fixed
      1 = the fix failed (shown as "failed" in the Intune report)

    Written for Windows PowerShell 5.1.
    Test only in the lab VM, never on your own laptop.
#>

$serviceName = 'wuauserv'

try {
    Set-Service -Name $serviceName -StartupType Manual -ErrorAction Stop
    Start-Service -Name $serviceName -ErrorAction Stop
    Write-Output "Remediated: the Windows Update service was set to Manual and started."
    exit 0
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
