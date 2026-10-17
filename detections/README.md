# Detection Rules

| ID | Name | Severity | Data source | ATT&CK | Tactics | Status |
|----|------|----------|-------------|--------|---------|--------|
| DET-001 | SSH Brute Force | Medium | Syslog | T1110 | Credential Access | Tested, firing |
| DET-002 | RDP Brute Force | Medium | SecurityEvent | T1110 | Credential Access | Tested, firing |
| DET-004 | New Local User | Medium | SecurityEvent, Syslog (auditd) | T1136 | Persistence / Privilege Escalation | Tested, firing |
| DET-005 | New Service Installed | Medium | Event | T1543.003 | Persistence / Privilege Escalation | Tested, firing |
| DET-006 | Cron Persistence | Medium | Syslog (auditd) | T1053.003 | Persistence | Tested, firing |
| DET-007 | Possible Web Shell — Apache Spawning Shell | High | Syslog (auditd) | T1505.003 | Initial Access / Execution | deployed, pending validation |