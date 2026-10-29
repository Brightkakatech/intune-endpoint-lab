# Local test results: detection scripts

Before deploying anything through Intune, each **detection** script was run on a real Windows 10 device (my lab host laptop) to check its output and exit code. Detection scripts only read information, so they are safe to run outside the lab. Remediation scripts make changes and run as SYSTEM, so they are tested only inside the lab VM.

Each script was run in **Windows PowerShell 5.1**, the same version Intune uses on devices:

```powershell
powershell.exe -ExecutionPolicy Bypass -File <script>; "Exit code: $LASTEXITCODE"
```

## First run

| Script | Output | Exit code |
|---|---|---|
| R01 Windows Update service | `Compliant: the Windows Update service start type is Manual.` | 0 |
| R02 Low disk space | `Non-compliant: C: has 3.6% free (12.5 GB). Threshold is 15%.` | 1 |
| R03 Defender signatures | `Non-compliant: Defender signatures are 65535 day(s) old (last updated ).` | 1 |

## What the results showed

**R01** worked as designed. Manual is Windows' default start type for this service.

**R02 found a real problem.** The Windows partition had only 3.6% free space. The lab VMs were stored on it, which was slowing the whole machine. They were moved to an external SSD, and free space went from 12.3 GB to 114.7 GB. The detection script found exactly the kind of issue it was written for.

**R03 exposed an edge case in my script.** A signature age of 65535 days with no update date is not a real age. Investigating:

```powershell
Get-MpComputerStatus | Select-Object AMRunningMode, AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled
# AMRunningMode: Not running | AMServiceEnabled: False | AntivirusEnabled: False | RealTimeProtectionEnabled: False

Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | Select-Object displayName
# Windows Defender, Avast Antivirus
```

**Cause:** a third-party antivirus (Avast) was installed. Windows runs only one antivirus in real-time mode, so Defender had stepped aside and reported 65535, which means "unknown".

**Fix:** the script now checks whether Defender is the active antivirus and, if not, reports that clearly instead of a misleading age.

## Retest after the fix

| Script | Output | Exit code |
|---|---|---|
| R03 Defender signatures | `Non-compliant: Defender antivirus is not active (running mode: Not running), so signature age is unknown. Check whether another antivirus is installed or Defender is disabled.` | 1 |

Exit code 1 is still correct: from Intune's point of view, a device where Defender is not protecting it is non-compliant.

## Lesson

Testing on a real device, not just the lab, found an edge case I had not thought of. It also confirmed that the lab VM must use **Defender as its only antivirus**, because ASR rules and Defender detections only work when Defender is active.
