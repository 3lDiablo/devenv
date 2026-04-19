# Specification: Extend Dynamic Ports

## 1. Overview

This track extends the "define-once, reuse-everywhere" port configuration pattern to all remaining components in the project. The goal is to make the environment more consistent and easier to manage by ensuring a single value in `config.yaml` controls all instances of a specific port number (host, service, and container) for each service.

## 2. Functional Requirements

The dynamic port pattern will be applied to the following components:
- `kafka-broker`
- `schema-registry`
- `kafka-connect`
- `redpanda-console`
- `cloudbeaver`

For each component, a single port value defined in `config.yaml` under its `settings` block shall be the canonical source for all its related ports. This value must correctly populate the corresponding `hostPort`, `containerPort`, `service.port`, and `service.targetPort` where applicable.

## 3. Acceptance Criteria

- **AC1 (Single Source):** For each component, a change to its single port value in `config.yaml` is correctly reflected in the Kind config and all relevant Kubernetes resources after running `task render`.
- **AC2 (Successful Deployment):** The `task up` command must complete successfully with the new configurations in place.
- **AC3 (Service Accessibility):** All refactored services must be accessible from the host machine on their configured ports.