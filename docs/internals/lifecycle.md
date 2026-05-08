# Cluster Lifecycle Management

Managing a local Kubernetes environment means managing state. We need the ability to build from scratch, tear down completely, or temporarily pause workloads without losing data. 

The Taskfile orchestrates these lifecycles efficiently.

## Up & Down: The Nuclear Options

### `task up`
This is the primary entry point. It is strictly **idempotent**.
1. **Checks Dependencies:** Ensures `kind`, `yq`, `kubectl`, etc., are installed.
2. **Renders Configuration:** Creates all ConfigMaps, `kind.yaml`, and app configurations.
3. **Creates Cluster:** Checks if the cluster exists; if not, builds it.
4. **Pre-loads Images:** Injects cached container images to speed up deployment.
5. **Deploys Components:** Deploys all core services in parallel using a dependency graph.

If you run `task up` on an already running cluster, it will safely skip cluster creation and simply re-apply the Kustomize manifests, catching any configuration changes you made to `config.yaml`.

### `task down`
This is the nuclear reset button. It ensures zero state is left behind.
1. Deletes the Kind cluster instance entirely.
2. Runs host-level volume and network prunes (e.g., `docker volume prune -f`) to prevent orphaned resources.
3. **Cleans generated files:** It deletes all artifacts rendered in `k8s/cluster/`, `k8s/components/overlays/`, and `definitions/rendered/`.

This guarantees that the next `task up` starts from a completely pristine baseline.

## Start & Stop: The Daily Workflow

Sometimes you need to free up CPU/RAM to work on something else, but you don't want to destroy the database or Kafka topics.

### `task stop`
This task leverages the fact that Kind nodes are just containers.
* It identifies the Kind node container (`<cluster_name>-control-plane`).
* It executes `docker stop` (or `podman stop`) on that container.
* **Result:** The entire Kubernetes control plane and all pods are frozen. Memory is freed, and CPU usage drops to zero. State is preserved on the container's virtual filesystem.

### `task start`
* It executes `docker start` to wake up the Kind node.
* It contains intelligent polling logic:
  * It waits for the Kubernetes API to start responding (handling TLS handshake delays).
  * It executes `kubectl wait --for=condition=Ready nodes` to ensure the Kubelet has fully initialized before yielding control back to the user.

If `task start` is run when no cluster exists, it smartly falls back to executing `task up`.

## Modular Deployment (Task Dependencies)

The `task deploy:all` command doesn't just run scripts blindly. It uses Task's DAG (Directed Acyclic Graph) dependency system to parallelize work securely.

```yaml
  deploy:all:
    deps:
      - deploy:postgres
      - deploy:strimzi
      - deploy:cloudbeaver
      - deploy:kafka:nodepools
      # ...
```

By defining explicit dependencies (e.g., `deploy:kafka:connect` requires `deploy:kafka:cluster`), Task can run unrelated deployments (like Postgres and Strimzi Operator) at the exact same time, cutting the `task up` time nearly in half.
