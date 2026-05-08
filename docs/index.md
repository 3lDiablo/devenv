# Local Kubernetes Development Environment

This project provides a robust, product-grade local development environment based on a single-node Kubernetes cluster (using [Kind](https://kind.sigs.k8s.io/)). It is designed to deliver a high-fidelity development experience that mimics production environments while maintaining a lightweight footprint, strictly adhering to CNCF (Cloud Native Computing Foundation) and Open Source standards.

## Project Philosophy

The core architecture centers on a **Single Source of Truth (SSoT)**. The entire environment configuration—including versioning, networking, and component settings—is centralized in a single `config.yaml` file.

This declarative approach ensures:

- **Consistency**: Everything from Helm chart templates to Kustomize patches is derived from the exact same values.
- **Maintainability**: Version numbers and port definitions are managed centrally, eliminating the need to track changes across multiple manifests.
- **Flexibility**: Global settings can be adjusted by modifying a single file.

## Why This Architecture?

Tool selection is based on architectural efficiency and standard compliance:

- **Go-Task (`task`)**: Orchestrates the environment lifecycle. It simplifies complex multi-step workflows—such as templating, cluster provisioning, and image loading—into declarative, reproducible tasks, replacing long, error-prone `kubectl` command chains.
- **Kustomize**: Provides native Kubernetes configuration management. It allows for dynamic environment rendering through overlays and patches without the complexity of maintaining local Helm charts or external rendering engines.
- **Kind (Kubernetes in Docker)**: Provides a full Kubernetes control plane. Unlike `docker-compose`, Kind enables the use of Kubernetes-native Operators (e.g., Strimzi) locally by running the control plane within OCI-compliant containers.

## Quickstart

Get the environment up and running immediately with these three steps:

1.  **Initialize**: Provision the Kind cluster and deploy the full stack.
    ```bash
    task up
    ```
2.  **Verify**: Check that all pods are healthy and metrics are flowing.
    ```bash
    task status
    ```
3.  **Access**: Open the Redpanda Console at [http://localhost:8080](http://localhost:8080) to browse topics and schemas.

## Documentation Structure

This documentation is split into four primary pillars:

1. **[Architecture & Core Concepts](architecture/index.md):** The "Why" and the "What". Deep dives into the CNCF philosophy, Kafka Stack, Telemetry Stack, and Resource Management.
2. **[Under the Hood (Internal Mechanics)](internals/ssot-pipeline.md):** The "How It Works". Explanations of the SSoT Rendering pipeline, advanced networking, image management, and lifecycle logic.
3. **[Developer Guides & How-Tos](guides/tweak-configuration.md):** The "How to do things". Actionable, step-by-step guides for daily operations and **[Troubleshooting](guides/troubleshooting.md)**.
4. **[Reference Manual](reference/taskfile.md):** Complete references for the Taskfile workflows, Environment variables, and **[Configuration Schema](reference/config-schema.md)**.

---

!!! tip "Getting Started"
    To spin up the cluster immediately, simply ensure your dependencies are installed and run `task up`.
