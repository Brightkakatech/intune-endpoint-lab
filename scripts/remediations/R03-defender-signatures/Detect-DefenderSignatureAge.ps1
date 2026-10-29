<#
.SYNOPSIS
    Detects out-of-date Microsoft Defender antivirus signatures.

.DESCRIPTION
    Defender identifies malware using signatures (definitions) that Microsoft
    updates several times a day. Old signatures mean new threats are missed.

    Exit codes:
      0 = signatures are recent
      1 = signatures are too old (or Defender status can't be read),
          Intune runs the remediation script

    Written for Windows PowerShell 5.1.
#>

$maxAgeDays = 1

try {
    $status = Get-MpComputerStatus -ErrorAction Stop
}
catch {
    Write-Output "Non-compliant: could not read Microsoft Defender status. $($_.Exception.Message)"
    exit 1
}

$age = $status.AntivirusSignatureAge
$lastUpdated = $status.AntivirusSignatureLastUpdated

if ($age -gt $maxAgeDays) {
    Write-Output "Non-compliant: Defender signatures are $age day(s) old (last updated $lastUpdated)."
    exit 1
}

Write-Output "Compliant: Defender signatures are $age day(s) old (last updated $lastUpdated)."
exit 0
