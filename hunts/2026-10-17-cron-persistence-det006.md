## Hunt: Cron Persistence — det-006 Follow-up

**Date:** 2026-10-17  
**Analyst:** Ibrahim Idris  
**Trigger:** det-006, “Linux Persistence via Cron,” on `vm-linux-01`  
**Alert time:** 14:02:18 local time (13:02:18 UTC)

### Hypothesis
The alert may be related to cron activity involving `/etc/cron.d/cleanup` or `/opt/scripts/cleanup.sh`. I investigated Syslog events on `vm-linux-01` around the alert time to review the script's execution and related audit activity.

### Scope
`vm-linux-01`, Syslog table, 30 minutes before and after the alert time (13:02:18 UTC).

### Query used
```kusto
let alertTime = datetime(2026-10-17T13:02:18Z);
Syslog
| where TimeGenerated between ((alertTime - 30m) .. (alertTime + 30m))
| where Computer =~ "vm-linux-01"
| where SyslogMessage contains "key=\"persistence\""
    or SyslogMessage contains "vuln-cleanup-script"
    or SyslogMessage contains "/etc/cron.d/cleanup"
    or SyslogMessage contains "/opt/scripts/cleanup.sh"
| project TimeGenerated, Computer, Facility, SyslogMessage
| order by TimeGenerated asc
```

### Findings
The query returned 296 rows. The results show repeated `cron` entries running `(root) CMD (/opt/scripts/cleanup.sh)`, along with `local6` audit events including `EXECVE` and `PATH` records for `/opt/scripts/cleanup.sh`.

This confirms that the cleanup script was executing repeatedly during the search window. The captured results do not establish who created or modified the cron entry, identify the originating session, or show whether the activity was caused by provisioning, testing, or an external actor.

### Conclusion
- [ ] Confirmed benign
- [ ] Confirmed malicious
- [x] Inconclusive — cron execution is visible, but the available evidence does not establish who created or modified the cron entry or the source of the activity.

### Follow-up actions
Review audit events for the cron-file write or modification, including the associated user, audit session, and key. Correlate those events with authentication activity and known provisioning or testing times before classifying the alert.

### Evidence
- `hunts/screenshots/2026-10-17-cron-persistence/02-cron-activity-timeline.png` — query and host activity results.
- Add the Sentinel incident detail screenshot to this folder after capture.
