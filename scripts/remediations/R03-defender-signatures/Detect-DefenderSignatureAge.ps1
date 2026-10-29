<#
.SYNOPSIS
    Detects out-of-date Microsoft Defender antivirus signatures.

.DESCRIPTION
    Defender identifies malware using signatures (definitions) that Microsoft
    updates several times a day. Old signatures mean new threats are missed.

    Edge case found during local testing: when Defender is not the active
    antivirus (another product is installed, or Defender is turned off),
    it reports a signature age of 65535 days and no update date. That value
    means "unknown", not "very old", so it is reported separately.

    Exit codes:
      0 = signatures are recent
      1 = signatures are too old, Defender is not active, or its status
          can't be read. Intune runs the remediation script.

    Written for Windows PowerShell 5.1.
#>

$maxAgeDays = 1
$unknownAge = 65535

try {
    $status = Get-MpComputerStatus -ErrorAction Stop
}
catch {
    Write-Output "Non-compliant: could not read Microsoft Defender status. $($_.Exception.Message)"
    exit 1
}

$age = $status.AntivirusSignatureAge
$lastUpdated = $status.AntivirusSignatureLastUpdated

if (-not $status.AntivirusEnabled -or $age -eq $unknownAge -or -not $lastUpdated) {
    Write-Output "Non-compliant: Defender antivirus is not active (running mode: $($status.AMRunningMode)), so signature age is unknown. Check whether another antivirus is installed or Defender is disabled."
    exit 1
}

if ($age -gt $maxAgeDays) {
    Write-Output "Non-compliant: Defender signatures are $age day(s) old (last updated $lastUpdated)."
    exit 1
}

Write-Output "Compliant: Defender signatures are $age day(s) old (last updated $lastUpdated)."
exit 0
