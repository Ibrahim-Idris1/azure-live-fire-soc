## Hunt: SSH Brute Force — Unauthorized Login Follow-up

**Hunt date:** 2026-10-23  
**Activity date:** 2026-10-17  
**Analyst:** Ibrahim Idris  
**Trigger:** DET-001, “SSH Brute Force Attempt,” on `vm-linux-01`  
**Confirmed login:** `socadmin` from `102.217.8.26` at `2026-10-17 14:23:03 UTC`

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

This query checks the focused window for an accepted SSH authentication from the IP and account identified during the initial review. An `Accepted password` event indicates successful password authentication; it does not identify the person behind the source IP.

```kusto
Syslog
| where TimeGenerated between (datetime(2026-10-17T14:15:00Z) .. datetime(2026-10-17T14:35:00Z))
| where Computer =~ "vm-linux-01"
| where SyslogMessage contains "102.217.8.26"
| where SyslogMessage has_any ("Accepted password", "Accepted publickey", "Accepted keyboard-interactive")
| project TimeGenerated, Computer, Facility, SyslogMessage
| order by TimeGenerated asc
```

#### 3. Review authentication attempts and session context

This query shows nearby failures, successes, and session-related messages for the same host and source. Use it to establish event order and identify related records around the accepted login.

```kusto
Syslog
| where TimeGenerated between (datetime(2026-10-17T14:15:00Z) .. datetime(2026-10-17T14:35:00Z))
| where Computer =~ "vm-linux-01"
| where SyslogMessage contains "102.217.8.26"
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
- The focused query returned `Accepted password for socadmin from 102.217.8.26` at `2026-10-17 14:23:03 UTC`.
- The analyst confirmed that `102.217.8.26` is not theirs and is not recognized as belonging to a team member.
- This confirms a successful SSH authentication from an unauthorized, unrecognized source. The identity of the operator and the extent or impact of activity after authentication have not yet been established.

### Conclusion
- [ ] False positive
- [x] Confirmed unauthorized successful SSH authentication
- [ ] Full post-login impact established

Treat `vm-linux-01` and the `socadmin` account as potentially compromised until post-login activity and the authorized live-fire participant records have been checked. The confirmed login is sufficient to escalate and respond; it does not by itself prove what actions the authenticated session performed.

### Follow-up actions
1. Preserve the incident and relevant logs/screenshots before rebuilding or deleting the VM.
2. Restrict inbound SSH to trusted sources using the Azure Network Security Group, while maintaining a verified administrative access path.
3. Change the `socadmin` password and review/revoke unrecognized SSH keys. Rotate any other credentials exposed to or reused on the VM.
4. Review the post-login query results and surrounding audit events for privilege use, commands, account or key changes, services, and scheduled tasks.
5. Compare the source IP and login time with authorized live-fire participant records. If the activity cannot be attributed to an authorized participant, retain the unauthorized-access classification and follow the incident-response process.

### Evidence
Screenshots under `hunts/screenshots/2026-10-17-ssh-bruteforce/`:
- `01-failed-logins-by-source.png` — failed attempts summarized by source and host.
- `02-accepted-socadmin-login.png` — accepted SSH login from `102.217.8.26`.
- `03-authentication-context.png` — nearby failures and session messages.
- `04-post-login-host-activity.png` — post-login audit and host activity results.
- `05-sentinel-incident-detail.png` — DET-001 incident details.
