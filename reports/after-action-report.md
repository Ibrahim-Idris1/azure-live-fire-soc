# After-Action Report

## Event Summary

This report captures the outcome of the live-fire SOC exercise, including the environment deployed, the attack traffic observed, detections fired, and lessons learned.

## Scope

- Date range: October 12-23, 2026
- Environment: Azure live-fire range
- Participants: SOC team and vetted community attackers
- Objective: validate detection coverage and threat-hunting workflow

## Environment Summary

- Two intentionally vulnerable endpoints were deployed and monitored
- Sentinel analytics alerts were generated for SSH/RDP brute force, new local users, new services, and Linux cron persistence. The web-shell rule did not trigger. Alert generation alone does not establish successful compromise; findings must be triaged before being classified as true positives.
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

- Event window: October 12-23, 2026
- New incidents shown in Sentinel's selected 14-day overview: 769
- Open incidents shown at screenshot capture: 770; active incidents: 1
- Analytics rules reported as triggered: 5 of 6; DET-007 web-shell rule did not trigger
- Total incidents reviewed: to be completed
- True-positive findings: to be completed
- False positives identified: to be completed
- Rules tuned or added: to be completed

Initial triage of roughly 700 alerts found four incidents that produced useful investigation findings; many remaining alerts appeared to be duplicates or repeated alerts for the same activity. This is a preliminary analyst assessment, not a finalized deduplicated incident count. Reconcile the alert and incident totals and record the review criteria before publishing final outcome statistics. SSH brute-force alert volume was particularly high and may contribute to alert fatigue. DET-001 tuning is planned; no tuning should be reported as completed until changes are validated and deployed.

The Sentinel overview count is an alert/incident volume, not a count of unique attacks or confirmed compromises. The screenshot uses the preset "Last 14 days" view, which may include activity before the October 12 event start; set a custom October 12-23 range before treating 769 as the exact event-period total. Triage and deduplication are also required before reporting true-positive totals. Add the overview screenshot to `reports/screenshots/` after redacting identifying or sensitive details.

## Lessons Learned

Alert volume and deduplication were significant operational lessons. Initial triage of roughly 700 alerts found four incidents with useful investigation findings, while many other alerts appeared duplicative or repeated. The SSH brute-force rule generated especially high volume; review its grouping and suppression behavior to reduce alert fatigue without hiding new sources, hosts, or meaningful bursts. Validate changes against expected test activity and suspicious activity before deployment.

This section should also capture other lessons from live monitoring, including:

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
