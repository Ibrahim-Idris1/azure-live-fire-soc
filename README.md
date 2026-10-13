# Live-Fire SOC Range

**A live-fire Security Operations Center exercise built on Azure** — intentionally vulnerable endpoints, real community attackers, and a two-analyst blue team detecting, hunting, and responding in real time. Every piece of the range — infrastructure, detections, and the pipeline that deploys them — is built and versioned as code.

---

## Overview

Most SOC portfolio projects use canned datasets or simulated attacks. This one doesn't. We deployed real vulnerable systems in Azure, invited vetted community members to attack them under a signed Rules of Engagement, and ran a live two-person SOC — threat hunting, writing detections, and responding — against genuinely unpredictable traffic.

The goal: demonstrate the full SOC lifecycle the way it actually happens on a real team — infrastructure as code, detection as code, live triage, and a documented after-action report — not a lab exercise with a known answer key.

---

## Team

| Name | Role | Profile |
|---|---|---|
| [Your Name] | Lead SOC Analyst — infrastructure, detection engineering, pipeline | [LinkedIn/GitHub link] |
| [Student Name] | SOC Analyst — detection validation, EDR deployment, live monitoring | [LinkedIn/GitHub link] |

Attackers were vetted members of our security community, operating under a signed Rules of Engagement. Their activity is fully logged and analyzed; their identities are not published anywhere in this repository or report.

---

## Architecture

```
                        ┌─────────────────────────┐
                        │   Community Attackers     │
                        │  (vetted, signed RoE)     │
                        └────────────┬───────────────┘
                                     │ attacks
                                     ▼
        ┌────────────────────────────────────────────────┐
        │              Azure Virtual Network               │
        │         (outbound locked down by default)        │
        │                                                    │
        │   ┌──────────────┐          ┌──────────────┐      │
        │   │ vm-linux-01    │          │ vm-win-01      │      │
        │   │ Ubuntu Server  │          │ Windows Server │      │
        │   │ + auditd       │          │ + Sysmon       │      │
        │   │ + LimaCharlie  │          │ + LimaCharlie  │      │
        │   └───────┬────────┘          └────────┬───────┘      │
        └────────────┼─────────────────────────────┼─────────────┘
                     │ logs                         │ logs
                     ▼                              ▼
        ┌────────────────────────────────────────────────┐
        │   Log Analytics Workspace + Microsoft Sentinel     │
        │   (SIEM — detections, incidents, hunting)           │
        └────────────────────┬───────────────────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │   SOC Analysts (us)        │
                 │  Hunt · Detect · Respond   │
                 └─────────────────────────┘

        Everything above is deployed and version-controlled
        via Terraform + GitHub Actions (OIDC, no stored secrets)
```

---

## Tools and technologies

- **Infrastructure as Code:** Terraform
- **Cloud platform:** Microsoft Azure
- **SIEM:** Microsoft Sentinel
- **Log sources:** Windows Security Events, Sysmon, PowerShell Script Block Logging, Linux auditd, Syslog
- **EDR:** LimaCharlie
- **Detection as Code:** KQL analytics rules deployed via Terraform, automated through GitHub Actions (OIDC federated auth, no stored credentials)
- **Attack simulation / validation:** Atomic Red Team
- **Version control & CI/CD:** GitHub, GitHub Actions
- **Documentation:** Markdown, this repository

---

## How it works

1. **Infrastructure deploys as code.** Two endpoints (Linux + Windows) are provisioned entirely via Terraform — network, NSGs, logging pipeline, and VM configuration are all defined in `/infrastructure`.
2. **Vulnerabilities are planted as code.** A Terraform-triggered provisioning script introduces intentional, documented weaknesses (weak credentials, misconfigured services, insecure permissions) on each endpoint — see `/infrastructure/vulnerabilities`.
3. **Telemetry flows to Sentinel and LimaCharlie.** Every endpoint ships Windows Security Events, Sysmon, PowerShell logging, and Linux auditd/syslog data to a central Log Analytics workspace, plus independent EDR telemetry via LimaCharlie.
4. **Detections are written and deployed as code.** Each detection rule lives in `/detections/rules` as a Terraform resource, mapped to MITRE ATT&CK. A GitHub Actions pipeline — authenticated to Azure via OIDC, no stored secrets — runs `terraform plan` on every pull request and `terraform apply` on merge to `main`, deploying rules straight to Sentinel.
5. **Attackers operate under signed rules.** Community participants are given scope and access only after agreeing to a documented Rules of Engagement (`/docs/rules-of-engagement.md`).
6. **The SOC hunts and responds live.** We monitor Sentinel incidents and LimaCharlie telemetry in real time, document every hunt (`/hunts`) and every incident (`/incidents`), and validate detection coverage against Atomic Red Team simulations.
7. **Results are reported.** A dashboard and after-action report (`/dashboards`, `/reports`) summarize the full event: what was attempted, what we caught, what we missed, and what we learned.

---

## Repository structure

```
├── docs/                   Rules of engagement, architecture notes, setup guide
├── infrastructure/
│   ├── terraform/            Network, VMs, logging pipeline, automation schedules
│   └── vulnerabilities/      Documented, intentionally planted weaknesses
├── detections/
│   ├── rules/                 Sentinel detection rules (Terraform, KQL)
│   └── tests/                 Atomic Red Team validation mappings
├── hunts/                   Threat hunt logs
├── incidents/                Incident timeline and response notes
├── dashboards/               Sentinel Workbook exports and screenshots
├── reports/                  After-action report and metrics
└── .github/workflows/        CI/CD pipeline for detection-as-code deployment
```

---

## Key results

*(To be completed after the live event)*

- Total attack attempts observed:
- Incidents detected:
- Detection rules deployed:
- Mean time to detect:
- Notable techniques caught:
- Notable gaps found and addressed:

Full breakdown in [`/reports/after-action-report.md`](reports/after-action-report.md).

---

## Reproducing this range

1. Clone this repository.
2. Install Terraform and the Azure CLI.
3. Copy `infrastructure/terraform/terraform.tfvars.example` to `terraform.tfvars` and fill in your own values (subscription ID, SSH key, admin IP).
4. `terraform init && terraform plan && terraform apply` from `infrastructure/terraform`.
5. See [`docs/setup-guide.md`](docs/setup-guide.md) for the full walkthrough.

---

## Ethics and safety

- All attack activity was conducted by consenting participants under a written Rules of Engagement.
- Outbound network access from both endpoints is locked down by default, preventing the range from being used to attack third parties.
- No participant names, IPs, or identifying information are published anywhere in this repository.
- All planted vulnerabilities and configurations described here are intentionally insecure for training purposes only and must never be deployed in a production environment.

---

## License

[Choose a license, e.g. MIT — add LICENSE file]