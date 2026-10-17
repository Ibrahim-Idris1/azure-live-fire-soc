# Roles and Responsibilities

This project is designed to emulate a small cybersecurity operations team, with two primary roles.

## Lead SOC Analyst

The lead analyst is responsible for:

- project planning and architecture,
- Azure environment management,
- detection engineering,
- deployment of rules and automation,
- reporting and final documentation,
- ensuring the event remains within scope.

## Student SOC Analyst

The student analyst is responsible for:

- EDR deployment and validation,
- endpoint health checks,
- attack simulation and detection validation,
- monitoring alerts and live hunting,
- investigating suspicious behavior,
- documenting incidents, hunts, and lessons learned.

## Community Participants

The community members are not part of the official documentation and are treated as vetted external participants within the controlled attack range. They operate under the project Rules of Engagement and are only allowed to test approved behaviors against the designated endpoints.

## Why this split works

This structure mirrors a realistic SOC workflow:

- one person manages the environment and detection strategy,
- one person validates the endpoint coverage and monitor activity,
- the team works together to investigate incoming threats and improve detections.

This is useful both for training and for demonstrating maturity in a portfolio project.
