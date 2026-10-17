# Rules of Engagement

This document defines the expected behavior for all participants who are interacting with the live-fire SOC range.

## Purpose

The purpose of this project is to create a realistic, controlled training environment for blue-team operations, detection engineering, and threat hunting. The exercise is designed to allow participants to test attack behavior against intentionally vulnerable endpoints while the SOC team monitors and responds.

## Scope

The exercise is limited to the following:

- the designated Azure endpoints in the project resource group,
- the specific ports, services, and applications intentionally exposed for testing,
- the agreed attack paths defined by project ownership and documentation.

No other systems or cloud resources may be targeted.

## Allowed Activity

Participants may perform only the activities explicitly approved by the project owner. These include:

- credential guessing or brute-force testing against approved services,
- reconnaissance against the designated range only,
- exploitation against approved vulnerabilities in the test environment,
- execution of permitted malware or test payloads in a contained environment.

All activity must fall within the learning and simulation goals of the exercise.

## Strictly Forbidden

The following actions are not allowed under any circumstances:

- DDoS or denial-of-service attacks,
- attacks against external systems outside the range,
- pivoting laterally into other networks,
- data exfiltration from the environment,
- malware deployment outside the approved lab scope,
- crypto mining, spam, or abuse of cloud resources,
- social engineering targeting real people or organizations,
- any destructive activity that breaks the environment without consent.

## Safety and Risk Controls

To reduce operational risk:

- outbound access is restricted by default,
- only approved IP ranges can access admin services,
- the range is isolated in its own dedicated Azure resource group,
- all attack traffic is logged and monitored,
- no live production credentials or business systems are exposed,
- the environment is shut down or rebuilt after the event window ends.

## Community Participation

The project includes vetted community participants who are allowed to test attack paths in the range. Their identities are not published in the repository or public reports. Any mentions of participants in documentation are anonymized.

## Data Handling

- no real secrets or credentials are stored in this repository,
- no participant identifying information will be published,
- screenshots and reports will be redacted where necessary,
- evidence created from the event will be used for learning, documentation, and portfolio purposes only.

## Response Expectations

The SOC team is expected to:

- detect suspicious behavior,
- validate alerts,
- investigate suspicious activity,
- track what happened in the hunt and incident logs,
- document findings and lessons learned.

## Incident Escalation

If a participant crosses the defined boundary or if an event appears to be outside the approved scope, the project lead must immediately:

1. stop the activity,
2. isolate the affected VM or resource,
3. document the event,
4. assess whether the environment needs to be rebuilt.

## Sign-Off Requirement

Before anyone is given access to the range, they must agree to the following:

- they understand the scope,
- they agree to the boundaries,
- they understand the consequences of violating the rules,
- they will not target systems outside the project.

## Final Note

This range is a controlled cybersecurity training environment. The purpose is to learn and improve defensive capabilities, not to cause harm or create unsafe conditions for external systems.
