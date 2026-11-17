# Detection Rules

| ID | Name | Severity | Data source | ATT&CK | Tactics | Status |
|----|------|----------|-------------|--------|---------|--------|
| DET-001 | SSH Brute Force | Medium | Syslog | T1110 | Credential Access | 10-minute KQL bin synced from reported Sentinel tuning; validation evidence pending |
| DET-002 | RDP Brute Force | Medium | SecurityEvent | T1110 | Credential Access | Tested, firing |
| DET-004 | New Local User | Medium | SecurityEvent, Syslog (auditd) | T1136 | Persistence / Privilege Escalation | Tested, firing |
| DET-005 | New Service Installed | Medium | Event | T1543.003 | Persistence / Privilege Escalation | Tested, firing |
| DET-006 | Cron Persistence | Medium | Syslog (auditd) | T1053.003 | Persistence | Tested, firing |
| DET-007 | Possible Web Shell — Apache Spawning Shell | High | Syslog (auditd) | T1505.003 | Initial Access / Execution | deployed; did not trigger during the October 12-23, 2026 event |

During the event, the team reported that the other five listed analytics rules triggered. Triggered alerts still require individual triage before being classified as true positives.

The Sentinel SSH brute-force rule's KQL aggregation bin was changed from five to ten minutes to reduce false-positive alert volume; the Terraform query now reflects that change. Per analyst confirmation, the rule still runs every five minutes and queries a five-minute lookback. Describe this as a 10-minute aggregation bin with a five-minute query lookback, not a full rolling 10-minute detection window. Add validation evidence when available.