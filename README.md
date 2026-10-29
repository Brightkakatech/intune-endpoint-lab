# Intune and Defender Endpoint Lab

> **Status: in progress.** This README is filled in as the project is built.

## Summary

BrightKaka Tech is a fictional company used for my labs. This project manages and secures its Windows devices entirely from the cloud with Microsoft Intune and Microsoft Defender:

- **Autopilot** sets up a new device automatically when a user signs in
- **Compliance, BitLocker, a security baseline and update rings** keep the device healthy and protected
- **Win32 apps** are packaged and deployed without touching the device
- **Detection and fix scripts** find and repair common problems
- **Defender** onboarding, **attack surface reduction** rules (audited before blocking), and a **simulated threat** worked as a real incident

It builds on my [Zero Trust identity lab](https://github.com/Brightkakatech/zero-trust-identity-lab): Conditional Access policy CA05 there only allows devices that this project marks as compliant.

## Architecture

![Architecture diagram](docs/diagrams/architecture.png)

## What you need

| Item | Detail |
|---|---|
| Licences | Microsoft 365 Business Premium (Intune, Entra ID P1, Defender for Business), used through a trial |
| Lab device | Windows 11 Enterprise evaluation VM on Hyper-V (Generation 2, virtual TPM, Secure Boot) |
| Tools | Microsoft Win32 Content Prep Tool, PowerShell 7, Microsoft Graph PowerShell SDK |
| Cost | Free (trial licences and evaluation media) |

## Policy design

The full plan, with every setting and the reason for it, is in [docs/endpoint-policy-plan.md](docs/endpoint-policy-plan.md).

| Area | Policy |
|---|---|
| Compliance | CMP01 Windows baseline compliance |
| Encryption | ENC01 BitLocker OS drive |
| Security baseline | BSL01 Windows security baseline |
| Updates | UPD01 Pilot ring, UPD02 Broad ring |
| Defender | EDR01 Defender onboarding, ASR01 ASR rules |
| Scripts | R01 Windows Update service, R02 Low disk space, R03 Defender signatures |

## How it was built

_Step-by-step setup, written as each stage is completed._

## Results

_Screenshots and results, added during testing._

## What broke and what I learned

_Added during the build._

## Known limitations

- **Remediations licensing:** Remediations require Windows Enterprise E3/E5 (or equivalent). Business Premium is not on Microsoft's list, so the scripts may be deployed as Platform scripts instead.
- **One device:** policies are tested on a single VM. The broad update ring is designed but not assigned.
- **Short ASR review:** 3–5 days of audit data on one device, enough to show the method.

## Teardown

_Added at the end._

## Repository layout

```
README.md
docs/
  endpoint-policy-plan.md   every setting and the reason for it
  win32-apps.md             packaging details for each app
  incident-report.md        the simulated Defender incident
  diagrams/                 architecture diagram
  screenshots/              evidence for each stage
scripts/
  remediations/             detection and fix script pairs
intune-export/              exported Intune configuration (sanitised)
```

## Author

Bright Amalahu, Systems Administrator
[LinkedIn](https://www.linkedin.com/in/bright-amalahu/) · [Medium](https://medium.com/@brightkakatech) · [GitHub](https://github.com/Brightkakatech)
