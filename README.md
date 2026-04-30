# Local Development Environment

A professional-grade, lightweight, and declarative local development environment based on a single-node **Kubernetes (Kind)** cluster.

This project provides a reproducible, **production-like** foundation for engineers, starting with a core stack of Kafka and PostgreSQL, but designed for easy expansion. It is managed by a simple, unified command-line interface.

---

## Features

- **Declarative Architecture**: The entire environment is defined by a single `config.yaml` file. All configuration for the cluster, components, and services is derived from this single source of truth.
- **Production-Like Kafka**: High-fidelity Kafka setup using the Strimzi operator in KRaft mode, with separated Controller and Broker NodePools.
- **Native Localhost Access**: All primary services are exposed on `localhost` via Kubernetes NodePorts, eliminating the friction of `kubectl port-forward`.
- **Persistent Data**: All stateful services (like PostgreSQL and Kafka) are backed by persistent volumes, ensuring data survives cluster restarts.
- **Extensible & Modular**: New components can be easily added to the Kustomize base, and the build system will automatically incorporate them.

## Core Components

The environment currently provisions the following services:

- **Streaming**: [Strimzi](https://strimzi.io/)-managed Apache Kafka
- **Database**: PostgreSQL
- **Kafka Management UI**: Redpanda Console
- **Database UI**: Cloudbeaver

## Architecture

This project follows a "Declarative Architecture" where `config.yaml` is the single source of truth. An orchestration layer using `Taskfile` and `yq` renders this configuration into manifests that are then applied to the cluster using `kustomize`.

## Prerequisites

You must have the following CLI tools installed on your system:
- `docker` or `podman`
- `kubectl`
- `kind`
- `task`
- `yq`

You can run `task check-deps` to verify your setup.

## Quick Start

1.  **Review Configuration**: Open `config.yaml` and adjust any settings as needed (e.g., change the container provider from `docker` to `podman`, or adjust `host` ports if they conflict with other local services).
2.  **Start Environment**:
    ```bash
    task up
    ```
3.  **Wait**: The initial setup will take a few minutes as images are loaded and components are deployed and initialized.
4.  **Access Services**: Once complete, services will be available on `localhost` at the ports defined in `config.yaml`.

## Commands

All project tasks are run via `Taskfile`. Run `task --list` for a full menu of available commands.

- `task up`: Creates and starts the environment from scratch.
- `task down`: Destroys the entire environment, including persistent data.
- `task stop`: Pauses the environment by stopping the cluster containers.
- `task start`: Resumes a paused environment.
- `task status`: Checks the status of all pods in the cluster.

## Configuration

### Component Toggles
You can easily activate or deactivate any service by toggling its `enabled` flag in `config.yaml` (e.g., `enabled: false`). 
The `Taskfile` orchestration is strictly conditioned around these flags. Disabling a component will prevent its tasks from executing during `task up` and remove it from the runtime generation.

### Port Mapping
To expose a component perfectly from the Kubernetes virtual network to your native `localhost`, you simply define a `ports` block under the component in `config.yaml` with a `host` port and a `node` port (between 30000-32767).
The orchestration pipeline will auto-detect the ports recursively, expose them dynamically in the Kind Node container configuration, and patch the respective Kubernetes Services via Kustomize.
### Resource Management & Auto-Sizing
To maintain a lightweight local footprint, you must explicitly declare Kubernetes `.resources` (`requests` & `limits`) for all components.

You do **not** need to manually define Java JVM constraints (like `-Xmx`). The Taskfile pipeline automatically detects your defined Kubernetes memory limits and computes an optimized JVM heap boundary internally, capping Java components natively at 70% of the Kubernetes limit. This completely protects your laptop from OOM (Out Of Memory) issues while hiding the complexity of JVM tuning.
