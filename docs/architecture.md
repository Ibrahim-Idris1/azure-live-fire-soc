# Architecture Overview

This range is a small Azure-based SOC exercise built from Terraform. It provisions two endpoints, can optionally plant intentionally vulnerable configurations, sends endpoint logs to Log Analytics and Microsoft Sentinel, and deploys the Sentinel detections defined in this repository.

## High-Level Design

```text
Community attackers
        |
        v
Azure resource group
  Virtual network 10.10.0.0/16
  Subnet 10.10.1.0/24
  NSG
   |                         |
   v                         v
vm-linux-01                vm-win-01
Ubuntu Server 22.04        Windows Server 2022
DVWA, Samba, audit rules   Sysmon, Windows events
   |                         |
   +------------+------------+
                v
     Azure Monitor agents
                |
                v
Log Analytics Workspace + Microsoft Sentinel
                |
                v
       SOC detection and response
```

## Components

### 1. Azure infrastructure

Terraform creates a resource group, a virtual network and target subnet, a network security group, and Linux and Windows virtual machines with public IP addresses. SSH and RDP are limited to configured administrator source IPs by default; their respective `ssh_open_to_internet` and `rdp_open_to_internet` variables can widen access. Inbound HTTP on port 80 is allowed from any source. Outbound Azure Monitor HTTPS is allowed, while other internet egress is denied unless `allow_updates_outbound` is enabled.

The Linux VM uses Ubuntu Server 22.04 and the Windows VM uses Windows Server 2022. Vulnerability provisioning is controlled by `plant_vulnerabilities`; it is disabled by default. Terraform also defines daily VM start automation and optional 23:00 auto-shutdown schedules.

### 2. Linux attack surface

When vulnerability planting is enabled, the Linux provisioning script creates a weak-password `backupuser`, a world-writable root cron script, the DVWA web application backed by MariaDB, and an anonymous writable Samba share at `/srv/samba/public`. Audit rules watch the cron artifacts, DVWA files, and Samba share.

The NSG currently allows inbound HTTP but does not add an inbound SMB rule for TCP port 445. The Samba share is configured on the endpoint, but remote SMB access requires a permitted network path; do not expose SMB broadly to the internet.

### 3. Windows attack surface

The Windows provisioning script installs Sysmon and, when vulnerability planting is enabled, creates the `svc_backup` account and a vulnerable service path under `C:\VulnApp`.

### 4. Logging and telemetry

Azure Monitor agents and data collection rules send Linux Syslog and Windows Security/Event data to the Log Analytics workspace. The Linux collection rule includes the configured facilities and log levels; auditd activity is available through this path when emitted as Syslog. Microsoft Sentinel is onboarded to the workspace.

The Terraform in this repository does not install the Linux auditd package or configure LimaCharlie. The Linux provisioning script adds audit rules and loads them, while any LimaCharlie agent and tenant configuration must be managed separately.

### 5. Detection as code

The Terraform module under `detections/rules` defines the Sentinel scheduled analytics rules. GitHub Actions deploys the rules using the repository's configured Azure authentication. The current rule files include DET-001, DET-002, and DET-004 through DET-006.

## Security Model

- Keep the range in a dedicated resource group and restrict administrator access to approved source IPs.
- Outbound internet access is denied by default, apart from Azure Monitor; update access is an explicit option.
- HTTP is exposed by the current NSG. SMB is not opened inbound by the current NSG.
- Treat the planted vulnerabilities as training-only and never use production credentials or sensitive data in the range.
- Run participant activity only under a written Rules of Engagement.

This environment is intentionally insecure and is not suitable for production workloads.