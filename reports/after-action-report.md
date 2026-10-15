# After-Action Report

## Event Summary

This report captures the outcome of the live-fire SOC exercise, including the environment deployed, the attack traffic observed, detections fired, and lessons learned.

## Scope

- Date range: to be completed
- Environment: Azure live-fire range
- Participants: SOC team and vetted community attackers
- Objective: validate detection coverage and threat-hunting workflow

## Environment Summary

- Two intentionally vulnerable endpoints were deployed and monitored
- Account creation, persistence, SSH/RDP brute force, and service-based malicious activity were observed
- Azure-native telemetry and EDR data were combined for investigation and detection tuning

## Attack Activity Observed

- external authentication attempts,
- service creation and persistence behavior,
- user creation and account misuse,
- suspicious scheduled or recurring activity,
- command execution patterns consistent with adversary tradecraft.

## Detections Deployed

- SSH Brute Force Attempt
- RDP Brute Force Attempt
- New Local User Account Created
- New Service Installed
- Linux Persistence via Cron

## Results

- Total detections fired: to be completed
- Total incidents reviewed: to be completed
- True-positive findings: to be completed
- False positives identified: to be completed
- Rules tuned or added: to be completed

## Lessons Learned

This section should capture what the SOC team learned during live monitoring, including:

- missing detections,
- noisy rules,
- suspicious behaviors not yet covered,
- mistakes made during investigation,
- improvements needed before the next event.

## Recommendations

- tune detections to reduce noise,
- expand coverage for lateral movement and persistence,
- create additional hunting queries for suspicious command execution,
- keep the environment reproducible with Terraform,
- continue documenting incidents in GitHub after each event run.

## Final Outcome

The purpose of this exercise is to show a realistic SOC process: build, monitor, detect, investigate, improve. This live-fire environment serves as a training platform and a portfolio-ready demonstration of defensive work.
