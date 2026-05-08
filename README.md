# Kubernetes Local Development Environment

A high-fidelity, single-node Kubernetes development environment engineered for cloud-native engineers. This project leverages **Kind** (Kubernetes in Docker) and a **Single Source of Truth (SSoT)** architecture to deliver a local experience that mirrors production-grade orchestration with minimal overhead.

## Core Architecture

The environment is built on three pillars of modern platform engineering:

1.  **Declarative SSoT**: All configuration—including infrastructure resource limits, networking, and component versions—is centralized in `config.yaml`.
2.  **Automated Lifecycle**: Orchestrated via [Go-Task](https://taskfile.dev/), the system replaces complex shell scripts with a dependency-aware execution pipeline.
3.  **High-Fidelity Components**: Runs standard Kubernetes Operators (Strimzi) and CNCF-native observability stacks (OpenTelemetry) rather than simplified docker-compose alternatives.

## Integrated Stack

| Component | Technology | Role |
| :--- | :--- | :--- |
| **Orchestration** | `Kind` + `Kustomize` | K8s Control Plane & configuration management. |
| **Kafka Stack** | `Strimzi` + `Apicurio` | Enterprise-grade Kafka Operator & Schema Registry. |
| **Database** | `PostgreSQL 17` | Robust relational backend for schemas and applications. |
| **Telemetry** | `OTel` + `Prometheus` | Unified observability and metrics collection. |
| **UIs** | `Redpanda Console` | Modern, stateless UI for Kafka stream exploration. |
| **DB UI** | `CloudBeaver` | Lightweight, web-based database management. |

## Quickstart: Zero-Friction Setup

The environment is designed to be **self-bootstrapping**. You only need `go-task` installed to begin.

```bash
# Initialize and launch the full environment
task up
```

!!! note "Self-Bootstrapping Dependencies"
    Upon running `task up`, the system will automatically audit your workstation for required tools (`kind`, `kubectl`, `yq`, `jq`, etc.). If dependencies are missing, the task will offer to install them via Homebrew automatically.

### Common Operations

| Command | Action |
| :--- | :--- |
| `task status` | View real-time cluster health and resource usage (CPU/MEM). |
| `task status:watch` | Continuous dashboard mode for cluster monitoring. |
| `task render` | Regenerate K8s manifests from `config.yaml` templates. |
| `task down` | Destructive teardown and cleanup of the environment. |

## SSoT Configuration (`config.yaml`)

To modify the environment, edit the centralized `config.yaml`. The pipeline handles the heavy lifting of template rendering and deployment updates.

- **Resource Management**: Adjust `requests` and `limits` for any service. JVM heap sizes for Kafka are automatically calculated based on these values.
- **Networking**: Manage host-to-cluster port mappings via the `cluster.ports` block.
- **Versioning**: Centralized image tag management under the `images` section to avoid supply-chain fragmentation.

## Accessing Services

Once initialized, services are exposed on `localhost` via NodePorts:

- **Redpanda Console**: [http://localhost:8080](http://localhost:8080)
- **CloudBeaver**: [http://localhost:8978](http://localhost:8978)
- **Grafana**: [http://localhost:3000](http://localhost:3000)
- **Prometheus**: [http://localhost:9090](http://localhost:9090)

## Technical Reference

For architectural deep-dives and advanced guides, see the internal documentation suite:
- [Overview & Philosophy](./docs/index.md)
- [Architecture & Core Concepts](./docs/architecture/index.md)
- [Developer Guides](./docs/guides/index.md)
- [Configuration Schema](./docs/reference/config-schema.md)
