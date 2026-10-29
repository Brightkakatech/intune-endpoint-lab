# Win32 app packaging

BrightKaka Tech: Intune and Defender endpoint lab

## What a Win32 app is

Intune can deploy several kinds of Windows app. A **Win32 app** is the most flexible: almost any installer (`.msi` or `.exe`) is wrapped into an encrypted `.intunewin` package and uploaded to Intune. For each app, Intune needs four things:

| Item | What it does |
|---|---|
| **Install command** | How to install silently, with no windows or questions for the user |
| **Uninstall command** | How to remove it silently |
| **Detection rule** | How Intune checks whether the app is already installed. A wrong rule means Intune reinstalls the app forever, or reports failure even though the install worked. |
| **Install context** | System (for all users of the device) or User |

The two apps below are deliberately different: one is an **MSI** (a standard Windows Installer package) and one is an **EXE** (a vendor's own installer). Each needs a different kind of detection rule.

## Packaging folders

Installers and packages are large binary files, so they are kept **outside the Git repo** (and `.gitignore` excludes `*.msi`, `*.exe` and `*.intunewin` as a safety net). Only this documentation goes in Git.

```
D:\Packaging\
  Tools\IntuneWinAppUtil.exe
  Source\7zip\        7-Zip MSI installer
  Source\notepadpp\   Notepad++ installer
  Output\             finished .intunewin packages
```

## APP01: 7-Zip (MSI)

| Item | Value |
|---|---|
| Version packaged | 26.05 (released 21 October 2026) |
| Source | 7-zip.org, Download page, 64-bit x64 MSI |
| Source file | `7z2605-x64.msi` |
| SHA-256 | `3FE4AB99FA15629C652944309A2B2BC6E41FC933FC6B63F5DF1EBCF3AEA68263` |
| Digital signature | Not signed (normal for 7-Zip's MSI). Downloaded only from the official site, and the hash is recorded so the exact file can be verified. |
| Package | `7z2605-x64.intunewin` (1.9 MB) |
| Install command | `msiexec /i "7z2605-x64.msi" /qn` |
| Uninstall command | `msiexec /x {ProductCode} /qn` |
| Detection rule | **MSI product code** (Intune reads it from the MSI automatically when you upload the package) |
| Install context | System |
| Assignment | Required, Intune-Pilot-Devices |

`/qn` means "quiet, no user interface". `/i` installs and `/x` uninstalls. Every MSI has a unique **product code** (a GUID), which makes it the most reliable way to detect it.

## APP02: Notepad++ (EXE)

| Item | Value |
|---|---|
| Version packaged | 8.9.8 (file version 8.9.8.0) |
| Source | notepad-plus-plus.org, Downloads, 64-bit x64 installer |
| Source file | `npp.8.9.8.Installer.x64.exe` |
| SHA-256 | `7B2A949BF460FB37A3888C9048698F43222A185A48323023DF1C51E78A3CA1C2` |
| Digital signature | Valid, signed by NOTEPAD++ (Paris, France) |
| Package | `npp.8.9.8.Installer.x64.intunewin` (6.5 MB) |
| Install command | `"npp.8.9.8.Installer.x64.exe" /S` |
| Uninstall command | `"%ProgramFiles%\Notepad++\uninstall.exe" /S` |
| Detection rule | **File**: path `%ProgramFiles%\Notepad++`, file `notepad++.exe`, detection method *File or folder exists* |
| Install context | System |
| Assignment | Required, Intune-Pilot-Devices |

`/S` (capital S) is the silent switch for installers built with NSIS, which Notepad++ uses. EXE installers have no product code, so detection checks for the installed program file instead.

## Packaging commands

Packaging tool: Microsoft Win32 Content Prep Tool 1.8.7, from Microsoft's official GitHub repository. Its Authenticode signature was checked before use (Valid, Microsoft Corporation).

```powershell
D:\Packaging\Tools\IntuneWinAppUtil.exe -c D:\Packaging\Source\7zip -s 7z2605-x64.msi -o D:\Packaging\Output -q
D:\Packaging\Tools\IntuneWinAppUtil.exe -c D:\Packaging\Source\notepadpp -s npp.8.9.8.Installer.x64.exe -o D:\Packaging\Output -q
```

| Switch | Meaning |
|---|---|
| `-c` | Source folder: everything in it goes into the package |
| `-s` | The setup file inside that folder |
| `-o` | Output folder for the `.intunewin` file |
| `-q` | Quiet mode, no prompts |

For each app, the tool compresses the source folder, encrypts it, computes SHA-256 hashes so Intune can check the package arrives intact, and writes a `Detection.xml` metadata file. For an MSI, that metadata includes the product code, which Intune reads when the package is uploaded.

## How the installers were verified

```powershell
# Digital signatures
Get-ChildItem D:\Packaging\Source -Recurse -File | Get-AuthenticodeSignature |
    Select-Object @{n='File';e={Split-Path $_.Path -Leaf}}, Status, @{n='Signer';e={$_.SignerCertificate.Subject}}

# SHA-256 fingerprints
Get-ChildItem D:\Packaging\Source -Recurse -File | Get-FileHash -Algorithm SHA256 |
    Select-Object @{n='File';e={Split-Path $_.Path -Leaf}}, Hash
```

**Why this matters:** an installer deployed through Intune runs as SYSTEM on every assigned device. A tampered installer would spread malware to the whole fleet at once, which is how software supply chain attacks work. Checking signatures, using only official sources and recording hashes reduces that risk.

## Results (filled in during the trial)

| App | Uploaded | Assigned | Installed on VM | Notes |
|---|---|---|---|---|
| APP01 7-Zip | | | | |
| APP02 Notepad++ | | | | |
