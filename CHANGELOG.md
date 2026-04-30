# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-22 - Genesis

### Added
- **Dynamic Local Environment**: Automated initialization of a local single-node Kubernetes cluster using Kind and Taskfile.
- **Component Orchestration**: Dynamic deployment of essential services (Kafka, PostgreSQL, Redpanda Console) using Kustomize overlays.
- **Provider Support**: Seamless built-in compatibility and generic image loading for both Docker and Podman.
- **Dynamic Port Configuration**: Automated NodePort assignment for seamless localhost access across different OS environments.

---
_Note: This is the very first (Genesis) release establishing the core dynamic architecture._

## [0.2.0] - 2026-04-29 - Ecosystem
### Added
- **Kafka Initialization Engine**: Declarative engine to automatically provision topics and register schemas from JSON definitions.
- **Karapace REST Proxy**: Integrated as a core component to support REST-based, schema-aware event publishing.
- **Advanced Resource Management**: Centralized control of CPU/Memory requests/limits with dynamic JVM heap auto-calculation.
- **Definitions Hierarchy**: New structured directory for business metadata (`definitions/topics` and `definitions/schemas`).
