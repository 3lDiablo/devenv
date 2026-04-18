# Repository Guidelines

This project provides a local development environment based on a single-node Kubernetes (Kind) cluster. It is designed to be lightweight, open-source, and developer-friendly.

## Project Structure & Module Organization
- **conductor/**: Project planning and specification (using the Conductor framework).
- **config.yaml**: Centralized configuration for cluster settings, versions, and providers.
- **Taskfile.yml**: Orchestration script for managing the environment lifecycle.
- **k8s/**: (To be created) Helm charts and Kubernetes manifests for services.

## Build, Test, and Development Commands
We use [Taskfile](https://taskfile.dev/) for automation. Common commands:
- `task init`: Create the Kind cluster and deploy all services.
- `task cluster-create`: Just create the cluster.
- `task deploy-all`: Deploy Kafka, Postgres, and their UIs.
- `task status`: Show running pods and services.
- `task cluster-delete`: Teardown the environment.

## Coding Style & Naming Conventions
- **YAML**: Use 2-space indentation. Maintain consistency in `config.yaml`.
- **Naming**: Use lowercase with hyphens for Kubernetes resources (e.g., `kafka-ui`, `postgres-db`).
- **Configuration**: Avoid hardcoding values in Helm charts or manifests. Reference variables from `config.yaml` or use environment variables.

## Testing Guidelines
- Verify connectivity to Kafka and Postgres after deployment.
- Ensure Redpanda Console and the DB UI are accessible on localhost via port-forwarding or node ports.

## Commit & Pull Request Guidelines
- Keep commit messages concise and descriptive (e.g., `feat: add Redpanda Console deployment`).
- Ensure `Taskfile.yml` and `config.yaml` remain consistent after changes.
