# Architecture Overview

This range is designed to behave like a small but realistic Azure-based SOC exercise. It gives the team a safe, reproducible environment to:

- deploy intentionally vulnerable endpoints,
- collect realistic telemetry,
- validate detections,
- hunt for attacker behavior, and
- document the incident lifecycle in a portfolio-ready way.

## High-Level Design

```text
                         ┌──────────────────────────────┐
                         │ Community Attackers          │
                         │ vetted participants           │
                         │ operating under signed RoE    │
                         └──────────────┬───────────────┘
                                        │
                                        │ attack traffic
                                        ▼
                     ┌────────────────────────────────────┐
                     │ Azure Resource Group               │
                     │ Virtual Network + NSGs             │
                     │                                    │
                     │ ┌──────────────┐     ┌────────────┐ │
                     │ │ vm-linux-01 │     │ vm-win-01  │ │
                     │ │ Ubuntu       │     │ Windows    │ │
                     │ │ auditd       │     │ Sysmon     │ │
                     │ │ Linux logs   │     │ Windows EVTX│ │
                     │ └──────┬───────┘     └──────┬─────┘ │
                     └─────────┼────────────────────┼─────┘
                               │                    │
                               │ telemetry          │ telemetry
                               ▼                    ▼
             ┌────────────────────────────────────────────────────┐
             │ Log Analytics Workspace                             │
             │ + Microsoft Sentinel + Security analytics rules      │
             └──────────────────────┬─────────────────────────────┘
                                    │
                                    │ alerting / hunting / investigations
                                    ▼
                   ┌────────────────────────────────────────────┐
                   │ SOC Team / Analysts                         │
                   │ - hunt                                       │
                   │ - validate detections                       │
                   │ - investigate alerts                        │
                   │ - generate reports                          │
                   └────────────────────────────────────────────┘
```

## Components

### 1. Azure infrastructure
The range is created from code using Terraform. It contains:

- one resource group
- one virtual network and subnet
- one Linux VM and one Windows VM
- network security groups with restricted outbound access
- Azure Monitor / Log Analytics connectivity
- optional auto-shutdown schedules for cost control

### 2. Intentionally vulnerable endpoints
The vulnerable machines are deliberately configured with insecure services, weak authentication paths, or misconfigured persistence behavior so the range creates realistic, high-value telemetry.

Examples include:

- SSH or RDP brute force paths
- weak local account creation conditions
- cron persistence on Linux
- Windows service persistence or startup activity
- intentionally insecure scripts used for training

### 3. Logging and telemetry
The event pipeline is designed to collect the information needed for detection and investigation.

Core log sources:

- Syslog / auditd on Linux
- Windows Security Event Log
- Sysmon telemetry on Windows
- PowerShell logs and command execution logging
- Azure Monitor / NSG / Activity logs

### 4. EDR
EDR telemetry provides additional endpoint visibility and incident context. The project uses the EDR layer to complement Azure-native logs and threat hunting activities.

### 5. Microsoft Sentinel
Sentinel is the central SIEM component for:

- scheduled detection rules,
- alert triage,
- hunting queries,
- incident tracking,
- timeline analysis,
- dashboarding.

### 6. GitHub and detection as code
This repository is the source of truth for all things that define the range:

- infrastructure code,
- detection rules,
- governance notes,
- operational logs,
- findings and report artifacts.

All detection logic is tracked and versioned in GitHub and deployed through a GitHub Actions workflow.

## Design Goals

This project is intentionally designed to teach the real SOC workflow:

1. Build the environment.
2. Validate the logging pipeline.
3. Simulate or receive attacks.
4. Tune detections.
5. Hunt for adversary behavior.
6. Review missed opportunities and false positives.
7. Write the final report.

## Security Model

To reduce risk and maintain safe operations:

- all outbound internet access is tightly restricted by default,
- only approved admin sources are allowed in,
- all activity is contained in a dedicated Azure resource group,
- no production credentials or secrets are stored in the repo,
- the project is intentionally isolated from anything unrelated to the lab.

## Operational Note

This range is for training and research within an agreed scope. It is not a production environment and should never be connected to sensitive data, real credentials, or live business systems.
