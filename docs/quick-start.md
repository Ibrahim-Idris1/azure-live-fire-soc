# Quick Start

This is a short guide for the team to begin the live exercise quickly.

## Before the Event

- confirm Azure access and resource permissions,
- validate Terraform deployments,
- check all endpoints are visible and reporting,
- confirm EDR agents are active,
- validate logs are reaching Sentinel,
- verify the detection rules are active,
- confirm the hunt and incident log workflow is ready.

## During the Event

- monitor the SIEM for alerts,
- review detections and new incidents,
- hunt for suspicious behavior beyond the current rules,
- log each finding in the repository,
- improve detections where a real gap is identified.

## After the Event

- review what was blocked and what was not,
- capture detection gaps and false positives,
- update documentation,
- build the after-action report,
- produce the final dashboard and timeline summary.

## Good Practice

Keep every step visible in GitHub. The repo should show not only the attack environment, but also the evidence, hunt records, and lessons learned.
