## Hunt: RDP Brute Force — Failed Attempts, No Successful RDP Logon Observed

**Hunt date:** 2026-10-23  
**Activity period reviewed:** 2026-10-12 through 2026-10-23  
**Analyst:** Ibrahim Idris  
**Trigger:** DET-002, “RDP Brute Force Attempt,” on `vm-win-01`  
**Data source:** `SecurityEvent`

### Hypothesis
The high volume of DET-002 alerts may represent repeated external RDP password-guessing activity. I investigated the source IPs and targeted accounts, then correlated failed RDP logons with successful interactive RDP logons from the same IP and host to check whether any source appears to have gained access.

### Scope and detection context
The review covered Windows Security events from 2026-10-12 through the investigation date on `vm-win-01`. DET-002 detects Event ID 4625 with logon type 10 or 3 and triggers when at least 10 failures occur in a five-minute window. The rule logic is in `detections/rules/det-002-rdp-bruteforce.tf`.

### Investigation steps and queries

#### 1. Summarize failed RDP logons by source IP

This query groups Event ID 4625 failures by source IP and computer, showing totals, targeted accounts, and the first and last observed failures. Use it to identify high-volume sources and patterns. A high failure count indicates repeated attempts, not successful access.

```kusto
let startTime = datetime(2026-10-12T00:00:00Z);
let endTime = now();
SecurityEvent
| where TimeGenerated between (startTime .. endTime)
| where Computer =~ "vm-win-01"
| where EventID == 4625
| where LogonType == 10 or LogonType == 3
| where isnotempty(IpAddress) and IpAddress != "-"
| summarize FailedAttempts = count(),
            TargetedAccounts = make_set(TargetUserName, 20),
            FirstFailure = min(TimeGenerated),
            LastFailure = max(TimeGenerated)
    by IpAddress, Computer
| order by FailedAttempts desc
```

#### 2. Correlate failed attempts with later successful RDP logons

This query looks for Event ID 4624 interactive RDP logons (logon type 10) from the same IP and computer as the failed attempts, and counts successes occurring after the first observed failure. A match is a lead to investigate; confirm whether the source and account were authorized.

```kusto
let startTime = datetime(2026-10-12T00:00:00Z);
let endTime = now();
let failures =
    SecurityEvent
    | where TimeGenerated between (startTime .. endTime)
    | where Computer =~ "vm-win-01"
    | where EventID == 4625
    | where LogonType == 10 or LogonType == 3
    | where isnotempty(IpAddress) and IpAddress != "-"
    | summarize FailedAttempts = count(),
                FirstFailure = min(TimeGenerated),
                LastFailure = max(TimeGenerated),
                TargetedAccounts = make_set(TargetUserName, 20)
        by Computer, IpAddress;
let successes =
    SecurityEvent
    | where TimeGenerated between (startTime .. endTime)
    | where Computer =~ "vm-win-01"
    | where EventID == 4624
    | where LogonType == 10
    | where isnotempty(IpAddress) and IpAddress != "-"
    | project Computer, IpAddress, SuccessTime = TimeGenerated,
              SuccessfulAccount = TargetUserName;
failures
| join kind=leftouter successes on Computer, IpAddress
| summarize FailedAttempts = take_any(FailedAttempts),
            FirstFailure = take_any(FirstFailure),
            LastFailure = take_any(LastFailure),
            TargetedAccounts = take_any(TargetedAccounts),
            SuccessfulRDPLogonsAfterFirstFailure = countif(SuccessTime > FirstFailure),
            FirstSuccessAfterFailure = minif(SuccessTime, SuccessTime > FirstFailure),
            SuccessfulAccounts = make_set_if(SuccessfulAccount, SuccessTime > FirstFailure, 20)
    by Computer, IpAddress
| order by SuccessfulRDPLogonsAfterFirstFailure desc, FailedAttempts desc
```

#### 3. Review a source IP's nearby Windows logon events

If a source needs closer review, replace `REPLACE_WITH_IP` with the IP and set the time range around the relevant failed activity. This shows failed and successful logons and selected related Security events for the host.

```kusto
let startTime = datetime(2026-10-17T14:00:00Z); // Adjust to the event being reviewed
let endTime = datetime(2026-10-17T15:00:00Z);
SecurityEvent
| where TimeGenerated between (startTime .. endTime)
| where Computer =~ "vm-win-01"
| where IpAddress == "REPLACE_WITH_IP"
| where EventID in (4624, 4625, 4648, 4672)
| project TimeGenerated, Computer, EventID, TargetUserName,
          IpAddress, LogonType, SubjectUserName
| order by TimeGenerated asc
```

### Findings
- The failed-logon query returned 140 source-IP/computer rows for `vm-win-01`, with substantial numbers of failed attempts and multiple targeted account names.
- The screenshots show repeated failure activity, including sources with thousands of failures during the reviewed period.
- The analyst reports that the correlation query showed no later successful RDP logons for the sources reviewed.
- Based on the reviewed query results, no successful RDP access was observed from those failed-attempt sources. This does not prove that no access occurred by another source, through another logon type, or outside the available telemetry or time window.

### Conclusion
- [x] Confirmed brute-force/password-guessing attempts; no successful RDP logon observed in the reviewed correlation results
- [ ] Confirmed compromise through RDP
- [ ] False positive

The repeated failures are genuine suspicious activity and should not be labelled false positives solely because authentication did not succeed. The available evidence supports unsuccessful brute-force attempts, not a confirmed RDP compromise.

### Follow-up actions
1. Preserve the Sentinel incidents and query results with their time range visible.
2. Review the highest-volume IPs and targeted accounts against authorized live-fire participant or scanner records.
3. Keep RDP restricted to trusted sources or an approved management path; do not broadly allowlist sources based only on IP reputation.
4. Consider tuning alert grouping or suppression to reduce repeated incidents while retaining visibility into distinct sources and bursts. Validate any change against the detection goal before deploying it.
5. If new evidence of a successful logon appears, investigate the account and host activity around that event before assessing impact.

### Evidence
Save screenshots under `hunts/screenshots/2026-10-12-rdp-bruteforce/`:
- `01-failed-rdp-logons-by-source.png` — failed attempts summarized by source and account.
- `02-failure-success-correlation.png` — correlation output showing no successful RDP logons for the reviewed sources.
- `03-source-event-review.png` — focused event query for any high-priority IPs investigated.
- `04-sentinel-incident-detail.png` — DET-002 incident details.
