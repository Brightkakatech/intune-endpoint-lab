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
| Version packaged | _record the version you downloaded_ |
| Source file | _record the file name, e.g. 7z….-x64.msi_ |
| Install command | `msiexec /i "<file>.msi" /qn` |
| Uninstall command | `msiexec /x {ProductCode} /qn` |
| Detection rule | **MSI product code** (Intune reads it from the MSI automatically when you upload the package) |
| Install context | System |
| Assignment | Required, Intune-Pilot-Devices |

`/qn` means "quiet, no user interface". `/i` installs and `/x` uninstalls. Every MSI has a unique **product code** (a GUID), which makes it the most reliable way to detect it.

## APP02: Notepad++ (EXE)

| Item | Value |
|---|---|
| Version packaged | _record the version you downloaded_ |
| Source file | _record the file name, e.g. npp.….Installer.x64.exe_ |
| Install command | `"<file>.exe" /S` |
| Uninstall command | `"%ProgramFiles%\Notepad++\uninstall.exe" /S` |
| Detection rule | **File**: path `%ProgramFiles%\Notepad++`, file `notepad++.exe`, detection method *File or folder exists* |
| Install context | System |
| Assignment | Required, Intune-Pilot-Devices |

`/S` (capital S) is the silent switch for installers built with NSIS, which Notepad++ uses. EXE installers have no product code, so detection checks for the installed program file instead.

## Packaging commands

```powershell
D:\Packaging\Tools\IntuneWinAppUtil.exe -c D:\Packaging\Source\7zip -s <7-zip file>.msi -o D:\Packaging\Output -q
D:\Packaging\Tools\IntuneWinAppUtil.exe -c D:\Packaging\Source\notepadpp -s <notepad++ file>.exe -o D:\Packaging\Output -q
```

| Switch | Meaning |
|---|---|
| `-c` | Source folder: everything in it goes into the package |
| `-s` | The setup file inside that folder |
| `-o` | Output folder for the `.intunewin` file |
| `-q` | Quiet mode, no prompts |

## Results (filled in during the trial)

| App | Uploaded | Assigned | Installed on VM | Notes |
|---|---|---|---|---|
| APP01 7-Zip | | | | |
| APP02 Notepad++ | | | | |
