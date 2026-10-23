# Incident Log

This folder is used to record project incidents and major findings discovered during the live-fire exercise.

## Incident Record Template

Each incident should include:

- incident ID,
- date and time,
- affected endpoint,
- source IP or source actor,
- technique observed,
- alert or detection triggered,
- investigation summary,
- impact assessment,
- containment actions,
- final status.

## Example

### INC-001
- Date: 2026-10-15
- Endpoint: vm-linux-01
- Technique: SSH brute force
- Source: external address in validated range
- Detection: SSH Brute Force Attempt
- Outcome: alert fired and was investigated
- Status: contained / monitored

## Investigated Incidents

These four investigated alert types produced actionable findings during the review. The statuses below reflect the evidence recorded in each hunt; they are not a count of all unique incidents in Sentinel.

### INC-HUNT-SSH-2026-10-17 — Unauthorized SSH login
- Date: 2026-10-17 14:23:03 UTC (investigated 2026-10-23)
- Endpoint: `vm-linux-01`
- Technique: SSH password guessing followed by a successful SSH authentication
- Source: `102.217.8.26` (not recognized by the analyst or team)
- Account: `socadmin`
- Detection: DET-001, SSH Brute Force Attempt
- Outcome: Successful password authentication was confirmed. The identity of the operator and post-login impact remain unverified.
- Status: **Confirmed unauthorized successful authentication; potential compromise under investigation.**
- Hunt record: [SSH unauthorized login hunt](../hunts/2026-10-17-ssh-unauthorized-login-det001.md)

### INC-HUNT-RDP-2026-10-12 — RDP brute-force attempts
- Date: 2026-10-12 through 2026-10-23 (reviewed 2026-10-23)
- Endpoint: `vm-win-01`
- Technique: Repeated RDP logon failures / password guessing
- Source: Multiple source IPs (see hunt query results)
- Detection: DET-002, RDP Brute Force Attempt
- Outcome: Repeated failed attempts were observed. No successful RDP logon was found for the reviewed failed-attempt sources in the correlation results.
- Status: **Brute-force attempts confirmed; no successful RDP access observed in the reviewed results.**
- Hunt record: [RDP brute-force hunt](../hunts/2026-10-12-rdp-bruteforce-det002.md)

### INC-HUNT-SERVICE-2026-10-19 — New service installations
- Date: 2026-10-19 (events at 14:32:57 and 15:02:11 UTC)
- Endpoint: `vm-win-01`
- Technique: Windows service installation (Service Control Manager Event ID 7045)
- Source: LimaCharlie EDR installation and a controlled service test
- Detection: DET-005, New Service Installed (Sentinel incident shown as ID 423)
- Outcome: Two service-installation events were reviewed; the analyst identified them as expected EDR installation and test activity.
- Status: **Explained by known activity; no unauthorized installation identified in the reviewed window.**
- Hunt record: [New service hunt](../hunts/2026-10-19-new-service-det005.md)

### INC-HUNT-CRON-2026-10-17 — Linux cron persistence alert
- Date: 2026-10-17 13:02:18 UTC
- Endpoint: `vm-linux-01`
- Technique: Cron activity involving `/opt/scripts/cleanup.sh`
- Source: Not established by the reviewed evidence
- Detection: DET-006, Linux Persistence via Cron
- Outcome: Repeated cron execution and related audit events were observed. The captured evidence did not establish who created or modified the cron entry or the source of the activity.
- Status: **Inconclusive; source and authorization of the cron change remain unverified.**
- Hunt record: [Cron persistence hunt](../hunts/2026-10-17-cron-persistence-det006.md)

## Documentation Standard

The incident log should be used as the source of truth for:

- what happened,
- what was observed,
- which detections fired,
- what the SOC team did,
- what needs to be improved afterward.

This log becomes part of the after-action report and the final portfolio evidence.
