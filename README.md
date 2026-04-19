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

The `config.yaml` file is the **single source of truth** for the entire environment. The version committed to the repository serves as the base configuration and working example. All values, including image versions, resource settings, and ports, should be managed from this file.
