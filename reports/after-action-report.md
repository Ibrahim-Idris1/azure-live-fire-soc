# After-Action Report

> **Status: preliminary.** The Sentinel incident totals are inconsistent across the analyst-reported review and the included screenshot. Deduplication criteria, the MTTD calculation basis, a separate false-positive count, and DET-001 validation evidence also remain incomplete. Do not present the overview counts below as unique attacks or confirmed compromises.

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
- Analyst-reported Sentinel overview: 769 new incidents in a selected 14-day view.
- Included Sentinel queue screenshot: 787 new incidents, 788 open incidents, and 1 active incident in a selected 14-day view. The screenshot's capture time and exact date range are not recorded, and its total does not match the analyst-reported 769; this discrepancy is unresolved.
- Open incidents reported at screenshot capture: 770; active incidents: 1
- Analytics rules reported as triggered: 5 of 6; DET-007 web-shell rule did not trigger
- Alert instances reported during review: 775
- True-positive findings reported: 6
- The remaining incidents were described as repeated brute-force detections across multiple source IPs, identified while investigating another alert. The precise deduplication/campaign-grouping criteria are not documented.
- Unique incidents after deduplication and a separate false-positive total: not yet reported; repeated alerts are not automatically false positives.
- Mean time to detect reported: 4 hours as an average; calculation start/end points and included incidents are not yet documented.
- DET-001's KQL aggregation bin was reported as changed from five to ten minutes in Sentinel and is now reflected in Terraform; validation evidence is not yet in the repository.

These are analyst-reported review totals. The 775 alerts and 769 incidents are different measures for the same reported event scope; do not subtract them or treat either as a unique-attack count. Document the deduplication and true-positive criteria, preserve evidence of the selected event range, and specify the MTTD inputs before presenting final outcome statistics. SSH brute-force alert volume was particularly high and may contribute to alert fatigue. The 10-minute aggregation bin is now in Terraform; per analyst confirmation, the rule intentionally retains a five-minute run frequency and five-minute query lookback. Describe this configuration accurately and add validation results before claiming the tuning is fully verified.

The [included Sentinel queue screenshot](../screenshots/incidence%20tab%20in%20sentinel%20indicating%20the%20number%20of%20incidence%20being%20triggered.png) is labeled "Last 14 days" and shows 787 new and 788 open incidents, while the analyst-reported overview is 769 new incidents. The screenshot's exact date range and capture time are not recorded, so it does not establish that either count matches the October 12-23 event window. Reconcile the source totals, selected date range, and capture time before reporting a final incident count. Incident volume is not a count of unique attacks or confirmed compromises.

## Lessons Learned

Alert volume and deduplication were significant operational lessons. The review reported 775 alert instances, 769 incidents, and 6 true-positive findings; the remaining incidents were described as repeated brute-force detections across multiple source IPs. Document how related activity was grouped before reporting a deduplicated case count. The SSH brute-force rule's KQL aggregation bin was changed from five to ten minutes while retaining a five-minute lookback and run frequency; preserve validation evidence.

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
