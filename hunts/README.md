# Threat Hunt Log

This folder records the threat-hunting activity performed during the live-fire range.

## Purpose

The goal is to document actions that challenge the current detection coverage and look for suspicious activity that may not yet have generated an alert.

## Hunt Template

Each hunt should record:

- date and time,
- hunter name,
- hypothesis,
- data sources used,
- query or technique,
- findings,
- evidence,
- final assessment.

## Example Hunt Entries

### Hunt 01 — Brute force against SSH
- Hypothesis: attackers may test weak credentials against Linux endpoints.
- Result: suspicious failed login bursts observed in syslog data.
- Outcome: supported by existing SSH brute force detection rule.

### Hunt 02 — New local user creation
- Hypothesis: attackers may add an unauthorized account for persistence.
- Result: user creation events were identified and investigated.
- Outcome: detection rule validated and documented.

### Hunt 03 — Cron persistence
- Hypothesis: attackers may create cron jobs to maintain access.
- Result: suspicious cron modifications were reviewed.
- Outcome: detection rule covered the observed pattern.

## Standard Operating Practice

- record hunts as they happen,
- keep evidence tied to timestamps,
- mark whether the hunt confirmed or disproved the hypothesis,
- include a final status of "true positive", "false positive", or "no malicious activity detected".

## Files in This Folder

Use one file per hunt or one consolidated log file, depending on the event volume. The important part is to keep the history clear and reviewable.
