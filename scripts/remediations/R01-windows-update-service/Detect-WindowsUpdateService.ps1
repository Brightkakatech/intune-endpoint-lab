<#
.SYNOPSIS
    Detects whether the Windows Update service has been disabled.

.DESCRIPTION
    If the Windows Update service (wuauserv) is disabled, the device silently
    stops installing security updates. Its normal start type is Manual
    (it starts on demand), so only "Disabled" is treated as a problem.

    Exit codes (used by Intune Remediations):
      0 = compliant, nothing to do
      1 = problem found, Intune runs the remediation script

    Written for Windows PowerShell 5.1, which is what Intune uses on devices.
#>

$serviceName = 'wuauserv'

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Output "Non-compliant: the Windows Update service ($serviceName) was not found."
    exit 1
}

if ($service.StartType -eq 'Disabled') {
    Write-Output "Non-compliant: the Windows Update service is disabled."
    exit 1
}

Write-Output "Compliant: the Windows Update service start type is $($service.StartType)."
exit 0
