# SOC Operational Playbook

This document describes how the SOC team should operate during the live-fire event.

## Team Roles

### Lead analyst
Responsible for:

- environment oversight,
- detection validation,
- incident prioritization,
- project documentation,
- reporting and final analysis.

### Student analyst
Responsible for:

- EDR deployment and validation,
- monitoring alerts in real time,
- hunting for new or suspicious patterns,
- assisting with detection tuning,
- documenting investigative findings.

## Live Event Workflow

### 1. Environment readiness
Before attack traffic begins, confirm the following:

- endpoints are online,
- EDR is reporting,
- logs are flowing to the SIEM,
- detections are active,
- the incident process is understood by the team.

### 2. Alert monitoring
The team should review alerts continuously and classify each event using a simple process:

- benign,
- suspicious,
- malicious,
- false positive,
- needs follow-up.

### 3. Investigation process
For every suspicious alert:

1. identify the source IP or host,
2. determine the technique used,
3. correlate with related events,
4. review EDR and SIEM telemetry,
5. check for persistence and lateral movement,
6. decide if the event is a true incident or a tuning issue.

### 4. Threat hunting
The team should hunt on a regular schedule using a hypothesis-driven approach. Examples include:

- unusual account activity,
- service creation and persistence,
- suspicious scheduled tasks or cron entries,
- new user creation,
- command execution patterns,
- unusual outbound connections.

### 5. Detection improvement
When a valid attack path is identified, the SOC team should:

- document the exact behavior,
- validate whether current detection rules cover it,
- add or adjust detections in GitHub,
- review if the rule is noisy or needs tuning,
- redeploy the detection changes.

## Daily Cadence

### Morning
- confirm environment status,
- review detections and missing coverage,
- check ingestion health,
- note any newly identified attack patterns.

### During the live event
- monitor alerts in near real time,
- triage incoming events,
- log each relevant finding,
- update the hunt log.

### End of day
- review incidents and alerts,
- identify what was caught and what was missed,
- note detection gaps,
- update the project report.

## Evidence Collection

The team should preserve enough evidence to support the report and postmortem. Evidence may include:

- timeline entries,
- alert details,
- host telemetry,
- command execution evidence,
- EDR findings,
- screenshots or query outputs as necessary.

## Escalation Criteria

An event should be escalated when:

- it indicates a successful compromise,
- persistence is detected,
- credentials are exposed or used,
- privileged actions occur,
- the attacker crosses expected control boundaries.

## Documentation Standard

All incidents and hunts should be recorded in the project repository with:

- timestamp,
- affected endpoint,
- technique or MITRE mapping,
- detection or hunt query,
- analyst observations,
- final verdict,
- follow-up actions.

## Final Principle

The objective is not to win a simulated attack, but to demonstrate disciplined SOC behavior: detect, validate, investigate, respond, and improve.
