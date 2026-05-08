# Taskfile Reference

The `Taskfile.yml` is the primary orchestration engine for the environment. It leverages `go-task` to provide a declarative, dependency-aware DAG (Directed Acyclic Graph) runner, replacing complex, error-prone shell scripts with a standardized command interface.

---

## Primary Workflows

These are the commands used for the core lifecycle of the cluster.

### `task up`
Initializes the entire environment from scratch.
- **Usage**: `task up`
- **Behavior**: **Idempotent.** It performs a full dependency check, renders all SSoT configurations, provisions the Kind cluster, sideloads images, and deploys the entire infrastructure stack.
- **Dependencies**: `check:deps` → `render` → `cluster:create` → `cluster:load-images` → `deploy:all`.

### `task down`
Destructive reset of the environment.
- **Usage**: `task down`
- **Behavior**: **Destructive.** Deletes the Kind cluster and performs a hard cleanup of Docker/Podman volumes and networks. It wipes all rendered configuration artifacts to ensure the next `task up` starts from a pristine baseline.

### `task stop`
Pauses the cluster without destroying data.
- **Usage**: `task stop`
- **Behavior**: Suspends the Kind node container. This frees up host CPU and RAM while preserving the state of Kafka topics and database records.

### `task start`
Resumes a paused cluster.
- **Usage**: `task start`
- **Behavior**: Wakes up the Kind node container and polls the Kubernetes API until the control plane is fully stabilized. If the cluster does not exist, it automatically falls back to `task up`.

---

## 🏗️ Deployment & Provisioning

Commands for managing specific layers of the stack.

### `task deploy:all`
The master deployment task that handles the concurrent rollout of all services.
- **Usage**: `task deploy:all`
- **Impact**: Deploys Strimzi, Kafka, Postgres, Schema Registry, Kafka Connect, Karapace, and the Telemetry stack.

### `task provision:kafka`
Handles the logical layer of the Kafka stack.
- **Usage**: `task provision:kafka`
- **Behavior**: Applies `KafkaTopic` custom resources and registers Avro/Protobuf schemas to the Apicurio API via REST.

---

## 📊 Observability & Utilities

### `task status`
Provides a real-time dashboard of the cluster's health.
- **Usage**: `task status`
- **Output**: A formatted table showing Pod status, CPU/Memory **Requests**, **Limits**, and **Actual Usage**.

### `task status:watch`
Continuous refresh mode for the status board.
- **Usage**: `task status:watch`
- **Frequency**: Refreshes every 2 seconds.

### `task check:deps`
Validates the developer's workstation configuration.
- **Usage**: `task check:deps`
- **Validation**: Ensures `kind`, `kubectl`, `yq`, `jq`, `bc`, `curl`, and `watch` are installed and available in the PATH.

!!! tip "Issue Resolution"
    If a task fails or you encounter unexpected behavior during cluster creation, refer to the [Troubleshooting Guide](../guides/troubleshooting.md).
