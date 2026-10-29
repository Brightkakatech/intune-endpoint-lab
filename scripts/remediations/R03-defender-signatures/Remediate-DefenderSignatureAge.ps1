<#
.SYNOPSIS
    Updates Microsoft Defender antivirus signatures.

.DESCRIPTION
    Triggers a signature update, then checks the new signature age.

    Exit codes:
      0 = signatures updated
      1 = the update failed

    Written for Windows PowerShell 5.1. Runs as SYSTEM through Intune.
#>

try {
    Update-MpSignature -ErrorAction Stop
    $status = Get-MpComputerStatus -ErrorAction Stop
    Write-Output "Remediated: Defender signatures updated. Age is now $($status.AntivirusSignatureAge) day(s), version $($status.AntivirusSignatureVersion)."
    exit 0
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
