# Setup Guide

This guide explains how to stand up the Azure SOC range and prepare it for a live-fire exercise.

## Overview

The project deploys a small Azure environment containing intentionally vulnerable endpoints and the telemetry stack needed to detect malicious behavior. The infrastructure is defined in Terraform so it can be recreated quickly and cleanly.

## Prerequisites

Before you begin, make sure you have:

- an Azure subscription with permission to create resources
- the Azure CLI installed
- Terraform installed
- a GitHub repository configured for the project
- an admin IP or CIDR range for safe inbound access
- a valid SSH public key for the Linux VM
- a secure Windows administrator password

## Azure Login

```bash
az login
az account set --subscription "<your-subscription-id>"
```

## Configure Variables

From the Terraform folder, create a `terraform.tfvars` file and populate required values.

Example:

```hcl
subscription_id = "<azure-subscription-id>"
location = "eastus"
prefix = "livefire-soc"
admin_source_ips = ["203.0.113.5/32"]
admin_ssh_public_key = "ssh-rsa AAAAB3Nza..."
windows_admin_password = "StrongPassword123!"
ssh_open_to_internet = false
rdp_open_to_internet = false
allow_updates_outbound = false
plant_vulnerabilities = true
```

> Never commit real secrets to GitHub. Prefer environment variables or a local secret file that is excluded from version control.

## Terraform Workflow

Run these commands from the Terraform directory:

```bash
terraform init
terraform plan
terraform apply
```

When the environment is no longer needed:

```bash
terraform destroy
```

## What Gets Deployed

The infrastructure includes:

- Azure resource group
- virtual network and subnet
- Linux endpoint with SSH access
- Windows endpoint with RDP access
- network security groups
- monitoring, logging, and SIEM components
- optional vulnerable configuration scripts

## Validate the Environment

Once Terraform completes, verify the following:

- both VMs are running,
- SSH and RDP access are restricted to approved admin sources,
- outbound internet access is blocked except for required Azure Monitor traffic,
- logs are reaching the workspace,
- detections are firing when tested with a safe validation process.

## Security Controls to Keep in Place

This is an intentionally insecure environment designed for training, but it must still be managed safely.

Recommended controls:

- keep the entire range in a dedicated Azure resource group,
- lock outbound access down by default,
- do not attach production credentials or managed identities,
- anonymize or remove real IP addresses from public documentation,
- pair every exercise with a written Rules of Engagement,
- destroy the environment after the event window ends.

## Recommended Validation Flow

Before the community begins attacking the range:

1. verify endpoint health,
2. confirm EDR communication,
3. test detection coverage with Atomic Red Team or equivalent safe validation,
4. confirm the SOC team can investigate alerts in real time,
5. review hunting assumptions and current detections,
6. document the event plan and escalation path.

## Common Troubleshooting

### Terraform apply fails
- check Azure subscription access,
- confirm the right resource permissions are available,
- verify the variables file is complete,
- check whether the chosen region supports the selected VM sizes.

### Logs do not appear in Sentinel
- verify the Azure Monitor agent is installed correctly,
- confirm the Log Analytics workspace is connected,
- check firewall rules and outbound restrictions,
- review VM extension status and OS logs.

### Detection rules do not fire
- validate the KQL query against actual collected log data,
- confirm the attack test is generating the expected log events,
- check whether the rule is scoped correctly to the right workspace,
- review query frequency and time windows.

## Final Notes

This environment should be treated as a training range, not a production environment. It should be deployed intentionally, kept isolated, monitored closely, and cleaned up promptly when the project ends.
