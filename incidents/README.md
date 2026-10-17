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

## Documentation Standard

The incident log should be used as the source of truth for:

- what happened,
- what was observed,
- which detections fired,
- what the SOC team did,
- what needs to be improved afterward.

This log becomes part of the after-action report and the final portfolio evidence.
