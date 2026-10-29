# Endpoint policy plan

BrightKaka Tech: Intune and Defender endpoint lab
Status: **Draft (pre-trial)**. Actual results are recorded during the trial.

## How the pieces fit together

| Policy type | Question it answers | Where it lives in Intune |
|---|---|---|
| **Compliance policy** | "Is this device healthy enough to be trusted?" It only *checks* and reports. | Devices → Compliance |
| **Configuration and security policies** | "How should this device be set up?" They *change* settings on the device. | Devices → Configuration, and Endpoint security |
| **Update rings** | "When should this device install Windows updates?" | Devices → Windows → Update rings |
| **Apps** | "What software should this device have?" | Apps → Windows |

**Compliance and Conditional Access work together.** Compliance marks a device as compliant or not compliant. Conditional Access policy CA05 (Project 4) then blocks access from devices that are not compliant. Compliance on its own doesn't block anything.

**Avoid duplicate settings.** If two policies set the same setting differently, Intune shows a **Conflict** and may apply neither. In this lab, each setting has exactly one owner (see the "Source of truth" column below).

## Groups

| Group | Members | Used for |
|---|---|---|
| Intune-Pilot-Users | alice, bob | User-targeted policies, MDM enrolment scope |
| Intune-Pilot-Devices | The lab VM (added after Autopilot registration) | Device-targeted policies, Autopilot profile |

## 1. Compliance policy: `CMP01 Windows baseline compliance`

Platform: Windows 10 and later. Assigned to: Intune-Pilot-Devices.

| Setting | Value | Why |
|---|---|---|
| Require BitLocker | Require | A lost laptop must not expose company data |
| Require Secure Boot | Require | Stops malicious code loading before Windows starts |
| Require code integrity | Require | Windows checks that system drivers and files are signed |
| Minimum OS version | 10.0.26100 (Windows 11 24H2) | Older builds stop receiving security updates |
| Require a password | Require | Basic access control. Windows Hello counts. |
| Firewall | Require | Blocks unwanted network connections |
| Trusted Platform Module (TPM) | Require | Needed for BitLocker and Windows Hello |
| Antivirus / Antispyware | Require | Confirms Microsoft Defender (or another registered antivirus) is running |
| Microsoft Defender Antimalware, real-time protection | Require | Malware protection must be switched on, not just installed |

**Actions for non-compliance:** mark the device non-compliant immediately, and email the user after 1 day (needs a notification message template).

**Tenant-wide setting** (Endpoint security → Device compliance → Compliance policy settings): set **"Mark devices with no compliance policy assigned as"** to **Not compliant**. Otherwise a device that receives no policy counts as compliant by default, which is a gap attackers can use.

## 2. BitLocker policy: `ENC01 BitLocker OS drive`

Endpoint security → Disk encryption → BitLocker. Assigned to: Intune-Pilot-Devices.
**Source of truth for all BitLocker settings** (the security baseline's BitLocker section is left as Not configured to avoid conflicts).

| Setting | Value | Why |
|---|---|---|
| Require device encryption | Enabled | Turns BitLocker on |
| Allow warning for other disk encryption | Disabled | Allows silent encryption, so users are not asked |
| Allow standard user encryption | Enabled | Works even when the user is not a local admin |
| Encryption method for OS drive | XTS-AES 256-bit | Strongest built-in option |
| Save BitLocker recovery information to Microsoft Entra ID | Enabled | IT can recover the drive if the user is locked out |
| Do not enable BitLocker until recovery information is stored | Enabled | Never encrypt a drive whose key could be lost |
| Recovery password rotation | Refresh on for Entra-joined devices | A recovery key that was shown to someone is replaced afterwards |

## 3. Security baseline: `BSL01 Windows security baseline`

Endpoint security → Security baselines → Security Baseline for Windows. Assigned to: Intune-Pilot-Devices.

A baseline is Microsoft's recommended set of several hundred security settings. **Do not accept it blindly.** Before assigning:

1. Read each category and note any setting that could break the lab (for example, remote access or local admin restrictions).
2. Set the **BitLocker** category to *Not configured*, because ENC01 owns those settings.
3. Record every setting you change from Microsoft's default, and why, in the table below.

| Category | Setting changed | Microsoft default | Lab value | Reason |
|---|---|---|---|---|
| BitLocker | All settings | Configured | Not configured | Avoid conflicts with ENC01 |
| | | | | |

## 4. Update rings

Devices → Windows → Update rings for Windows 10 and later.

| Setting | `UPD01 Pilot ring` | `UPD02 Broad ring` |
|---|---|---|
| Quality update deferral | 0 days | 7 days |
| Feature update deferral | 0 days | 60 days |
| Deadline for quality updates | 2 days | 5 days |
| Deadline for feature updates | 2 days | 7 days |
| Grace period before forced restart | 1 day | 2 days |
| Microsoft product updates | Allow | Allow |
| Assigned to | Intune-Pilot-Devices | Not assigned in the lab (one VM only) |

**Why two rings?** A small pilot group gets updates first. If an update breaks something, it is caught before it reaches everyone. The broad ring is created to show the design, even though only one VM exists.

## 5. Defender onboarding: `EDR01 Defender onboarding`

1. Microsoft Defender portal → Settings → Endpoints → Advanced features: turn on the **Microsoft Intune connection**.
2. Intune → Endpoint security → Endpoint detection and response → create a policy. Onboarding package: **Auto from connector**. Assigned to: Intune-Pilot-Devices.
3. Confirm the VM appears in the Defender portal's device inventory.

## 6. Attack surface reduction (ASR): `ASR01 ASR rules`

Endpoint security → Attack surface reduction → Attack Surface Reduction Rules.

ASR rules block behaviours that malware commonly uses, such as an Office document starting a script. **Every rule starts in Audit mode:** it logs what *would* have been blocked without blocking it. After reviewing the audit events, rules move to Block one by one.

| Rule | Start | Plan after audit review |
|---|---|---|
| Block abuse of exploited vulnerable signed drivers | Audit | Block (Microsoft "standard protection" rule) |
| Block credential stealing from the Windows local security authority subsystem (lsass.exe) | Audit | Block (standard protection rule) |
| Block persistence through WMI event subscription | Audit | Block (standard protection rule) |
| Block executable content from email client and webmail | Audit | Block if no legitimate hits |
| Block all Office applications from creating child processes | Audit | Block if no legitimate hits |
| Block Office applications from creating executable content | Audit | Block if no legitimate hits |
| Block Office applications from injecting code into other processes | Audit | Block if no legitimate hits |
| Block Win32 API calls from Office macros | Audit | Block if no legitimate hits |
| Block JavaScript or VBScript from launching downloaded executable content | Audit | Block if no legitimate hits |
| Block execution of potentially obfuscated scripts | Audit | Block if no legitimate hits |
| Block untrusted and unsigned processes that run from USB | Audit | Block if no legitimate hits |
| Use advanced protection against ransomware | Audit | Block if no legitimate hits |
| Block process creations originating from PSExec and WMI commands | Audit | Decide after review (can affect management tools) |
| Block executable files from running unless they meet a prevalence, age, or trusted list criterion | Audit | Likely stays in Audit (often noisy) |

**ASR audit review record** (filled in during the trial):

| Rule | Audit events seen | Legitimate or suspicious? | Decision |
|---|---|---|---|
| | | | |

**Lab limitation:** a real company reviews audit data for weeks across many devices. This lab reviews 3 to 5 days on one VM, which is enough to show the method.

## 7. Remediations (detection and fix scripts)

See `scripts/remediations/`. Each pair has a **detection** script (exit code 1 = problem found) and a **remediation** script that fixes it.

| ID | Problem | Why it matters |
|---|---|---|
| R01 | Windows Update service disabled | A disabled update service means the device silently stops receiving security patches |
| R02 | Low disk space on C: | Full disks cause update failures, crashes and support tickets |
| R03 | Out-of-date Defender signatures | Antivirus with old signatures misses new threats |

**Licensing note:** Remediations require Windows Enterprise E3/E5 (or Microsoft 365 E3/E5/F3, or Windows VDA). Microsoft 365 Business Premium is not on that list. If the tenant isn't eligible, the scripts are deployed as **Platform scripts** (run once) instead, and this limitation is stated in the README.

## 8. Win32 apps

Planned in the next preparation session: see `docs/win32-apps.md`.

## 9. Simulated incident

Microsoft's safe test (the EICAR test file, or the evaluation simulations in the Defender portal), run only on the isolated lab VM. The incident is investigated, classified as a test, resolved and written up as a one-page incident report in `docs/incident-report.md`.
