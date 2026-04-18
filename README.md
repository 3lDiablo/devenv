# ⚡ Local Development Environment

A professional-grade, lightweight, and developer-centric local development environment based on a single-node **Kubernetes (Kind)** cluster.

This project uses the **Pure Dynamic Bridge** architecture: a single source of truth (`config.yaml`) drives the entire stack with zero intermediate environment files.

---

## 🛠️ Prerequisites

The following tools must be installed and available in your PATH before initialization:

- **[Taskfile](https://taskfile.dev/installation/)**: CLI orchestrator and task runner.
- **[Kind](https://kind.sigs.k8s.io/)**: Local Kubernetes cluster engine.
- **[yq](https://github.com/mikefarah/yq)**: Command-line YAML processor (v4+).
- **[Kustomize](https://kustomize.io/)**: Standalone Kubernetes manifest builder (v4+).
- **[kubectl](https://kubernetes.io/docs/tasks/tools/)**: Kubernetes command-line interface.
- **[Docker](https://www.docker.com/)** or **[Podman](https://podman.io/)**: Container runtime engine.

---

## 🚀 Quick Start

Initialize the complete infrastructure stack:

```bash
task up
```

Teardown and clean up the environment:

```bash
task down
```

View all available orchestration commands:

```bash
task --list
```

---

## 🧐 Technical Stack Rationale

This environment is built on a specific set of architectural choices designed for stability, transparency, and high developer velocity.

### Why KRaft over Zookeeper?
We exclusively use **Kafka in KRaft mode** via the Strimzi Operator. 
- **Production Standard**: As of Kafka 3.x, KRaft is the production-ready consensus protocol. It is the future standard, and developing against it ensures your local environment mirrors modern cloud deployments.
- **Unified Metadata**: Eliminating Zookeeper removes a massive layer of complexity. Metadata is now managed within Kafka itself, leading to faster leader election and improved cluster stability.
- **Resource Efficiency**: Removing the Zookeeper ensemble saves significant CPU and RAM, keeping the environment lightweight.

### Why Classic Manifests over Helm?
For the core stack (Postgres, Redpanda Console, Schema Registry), we use raw Kubernetes manifests instead of 3rd-party Helm charts for several critical reasons:
1.  **Lightweight & Transparent**: These are single-container applications. Manifests provide exactly what is needed without the "hidden" defaults and bloat of large Helm charts.
2.  **Native NodePort Integration**: Our strict mandate for direct localhost access requires deterministic NodePort mapping. Custom manifests ensure the `nodePort` matches our `config.yaml` perfectly.
3.  **Clean Variable Injection**: Our **Pure Dynamic Bridge** (Kustomize `replacements`) is most reliable when targeting raw YAML structures. Injecting variables into complex Helm charts often requires "hacked" workarounds.
4.  **Bitnami Avoidance**: Due to the 2025 Bitnami registry shifts, their public charts are less reliable for simple, version-fixed local reproducibility. Using official library images in clean manifests is significantly safer.

---

## 🍎 Important for Podman (macOS) Users

On macOS, Podman runs inside a lightweight Linux Virtual Machine. This VM manages its own certificate store, which may not automatically trust certain Certificate Authorities (CAs) even if your host machine does. This can result in `x509: certificate signed by unknown authority` errors during image pulls.

### Automated Workaround
The orchestration in this project automatically handles this by:
1.  Using the `--tls-verify=false` flag during the `podman pull` phase on the host.
2.  Pre-loading images directly into the Kind cluster's internal storage via `kind load image-archive`.

This ensures a seamless setup even in restrictive network environments. If you need to pull images manually, ensure you include the TLS bypass flag:
```bash
podman pull --tls-verify=false <image>:<tag>
```

---

## 🛡️ Developer Experience (DevEx)

- **Kubecontext Safety**: All operations are explicitly scoped to the local Kind cluster (`kind-<cluster-name>`) to prevent accidental configuration of external environments.
- **Graceful Error Handling**: Status-aware task execution and dependency verification ensure a deterministic setup process.
- **Deterministic Orchestration**: Intelligent health-check logic ensures Kafka brokers are fully ready before deploying dependent services.
- **Pure Dynamic Bridge**: One file (`config.yaml`) controls everything. Taskfile and Kustomize extract values dynamically, ensuring a clean and traceable configuration.

---

## ⌨️ CLI Orchestration (Taskfile)

We use [Taskfile](https://taskfile.dev/) to provide a standardized interface:

| Command | Rationale |
| :--- | :--- |
| `task up` | Executes the full lifecycle: dependency check, cluster creation, operator installation, and stack deployment. |
| `task down` | Performs a graceful teardown of the Kind cluster and removes all generated local manifests. |
| `task status` | Aggregates the health status of infrastructure pods and provides active NodePort endpoints. |
| `task --list` | Enumerates all granular tasks available for advanced environment control. |

---

## ⚙️ Configuration

The **`config.yaml`** file acts as the central control plane for:
- Cluster identifiers and container runtime selection (Docker/Podman).
- Image registry management (supporting Bitnami Legacy migrations).
- Localhost port definitions and Kafka topology (replicas/storage).

---

## 📄 License

This project is open-source and released under the [MIT License](LICENSE).
