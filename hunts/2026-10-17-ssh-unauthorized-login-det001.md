## Hunt: SSH Brute Force — Unauthorized Login Follow-up

**Hunt date:** 2026-10-23  
**Activity date:** 2026-10-17  
**Analyst:** Ibrahim Idris  
**Trigger:** DET-001, “SSH Brute Force Attempt,” on `vm-linux-01`  
**Confirmed login:** `socadmin` from a source IP redacted in this public copy at `2026-10-17 14:23:03 UTC`

### Hypothesis
Repeated failed SSH logins against `vm-linux-01` may include an unauthorized successful login. I investigated the source IPs and targeted accounts, checked for a successful authentication from a source the analyst does not recognize, and reviewed the host's nearby authentication and audit activity.

### Scope
- Host: `vm-linux-01`
- Initial review period: 2026-10-12 through the time of investigation
- Focused authentication review: 2026-10-17 14:15–14:35 UTC
- Focused post-login review: 2026-10-17 14:23–15:23 UTC
- Data source: `Syslog`

### Investigation steps and queries

#### 1. Identify SSH sources and accounts with repeated failed logins

This query summarizes failed SSH password attempts by source IP and host over the review period. It helps prioritize frequent sources and shows which account names were targeted. High volume is evidence of repeated attempts, but does not on its own confirm successful access.

```kusto
let startTime = datetime(2026-10-12T00:00:00Z);
let endTime = now();
Syslog
| where TimeGenerated between (startTime .. endTime)
| where SyslogMessage has "Failed password"
| extend SourceIP = extract(@"from (\d+\.\d+\.\d+\.\d+)", 1, SyslogMessage)
| extend Account = extract(@"Failed password for (?:invalid user )?(\S+) from", 1, SyslogMessage)
| where isnotempty(SourceIP)
| summarize FailedAttempts = count(),
            TargetedAccounts = make_set(Account, 20),
            FirstFailure = min(TimeGenerated),
            LastFailure = max(TimeGenerated)
    by SourceIP, Computer
| order by FailedAttempts desc
```

#### 2. Validate the suspected successful login

This query checks the focused window for an accepted SSH authentication from the IP and account identified during the initial review. Replace the placeholder locally with the source IP from your authorized evidence. An `Accepted password` event indicates successful password authentication; it does not identify the person behind the source IP.

```kusto
Syslog
| where TimeGenerated between (datetime(2026-10-17T14:15:00Z) .. datetime(2026-10-17T14:35:00Z))
| where Computer =~ "vm-linux-01"
| where SyslogMessage contains "REPLACE_WITH_SOURCE_IP"
| where SyslogMessage has_any ("Accepted password", "Accepted publickey", "Accepted keyboard-interactive")
| project TimeGenerated, Computer, Facility, SyslogMessage
| order by TimeGenerated asc
```

#### 3. Review authentication attempts and session context

This query shows nearby failures, successes, and session-related messages for the same host and source. Replace the placeholder locally with the source IP from your authorized evidence. Use the results to establish event order and identify related records around the accepted login.

```kusto
Syslog
| where TimeGenerated between (datetime(2026-10-17T14:15:00Z) .. datetime(2026-10-17T14:35:00Z))
| where Computer =~ "vm-linux-01"
| where SyslogMessage contains "REPLACE_WITH_SOURCE_IP"
    or SyslogMessage contains "socadmin"
    or SyslogMessage has_any ("session opened", "session closed", "sudo")
| project TimeGenerated, Computer, Facility, SyslogMessage
| order by TimeGenerated asc
```

#### 4. Review host activity after the successful login

This query checks selected authentication, audit, and cron facilities for related activity during the hour after the login. Review the returned audit records for commands, account changes, privilege use, and persistence-related changes. A lack of matching records is not proof that no other activity occurred.

```kusto
Syslog
| where TimeGenerated between (datetime(2026-10-17T14:23:03Z) .. datetime(2026-10-17T15:23:03Z))
| where Computer =~ "vm-linux-01"
| where Facility in ("auth", "authpriv", "local6", "cron")
| where SyslogMessage has_any (
    "socadmin", "sudo", "USER_LOGIN", "USER_AUTH", "EXECVE", "PATH",
    "cron", "sshd", "Accepted", "session opened", "session closed",
    "useradd", "authorized_keys"
)
| project TimeGenerated, Computer, Facility, SyslogMessage
| order by TimeGenerated asc
```

### Findings
- The failed-login review showed substantial SSH password-failure activity against `vm-linux-01`, including multiple source IPs and many targeted account names.
- The focused query returned an accepted password authentication for `socadmin` at `2026-10-17 14:23:03 UTC`.
- The source IP is redacted in this public copy; the analyst reported that it was not theirs and was not recognized as belonging to a team member.
- This confirms a successful SSH authentication from an unauthorized, unrecognized source. The identity of the operator and the extent or impact of activity after authentication have not yet been established.

### Conclusion
- [ ] False positive
- [x] Confirmed unauthorized successful SSH authentication
- [ ] Full post-login impact established

The project owner reports that `vm-linux-01` was isolated and rebuilt and its credentials and SSH keys were rotated. The successful authentication remains confirmed, but the operator's identity and post-login impact are still unverified.

### Follow-up actions
- The project owner reports host isolation/rebuild and credential/key rotation as completed.
- Preserve any retained incident logs and evidence; review post-login activity and compare the event with authorized participant records if evidence remains available.
- Keep the source address redacted in public materials. Do not classify the activity as authorized or the host impact as known without supporting evidence.

### Evidence
Screenshots under `hunts/screenshots/2026-10-17-ssh-bruteforce/`:
- `01-failed-logins-by-source.png` — failed attempts summarized by source and host.
- `02-accepted-socadmin-login.png` — accepted SSH login; redact the source address before publishing.
- `03-authentication-context.png` — nearby failures and session messages.
- `04-post-login-host-activity.png` — post-login audit and host activity results.
- `05-sentinel-incident-detail.png` — DET-001 incident details.
