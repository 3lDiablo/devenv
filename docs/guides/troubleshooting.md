# Troubleshooting Guide

This guide provides solutions for common issues encountered when managing the local Kubernetes development environment.

## 1. Connectivity Issues

### Error: `dial tcp 127.0.0.1:6443: connect: connection refused`
This error indicates that the Kubernetes API server is unreachable.

**Possible Causes:**
- **Kind Cluster is Down**: The cluster may have been stopped or failed to start.
- **Docker/Podman Engine Stopped**: The underlying container engine must be running.

**Solutions:**
1.  Verify the cluster status:
    ```bash
    kind get clusters
    ```
2.  Check the status of the node containers:
    ```bash
    docker ps -a --filter "label=io.x-k8s.kind.cluster=<cluster_name>"
    ```
3.  If the containers are stopped, restart the cluster:
    ```bash
    task start
    ```
4.  Verify that your `KUBECONFIG` is pointing to the correct context:
    ```bash
    kubectl config current-context
    # Should be kind-<cluster_name>
    ```

### Error: `Context Deadline Exceeded` (during `task up`)
Often occurs during the `cluster:create` or `cluster:load-images` stages on resource-constrained host machines.

**Solutions:**
1.  Increase the resource allocation for your container engine (Docker Desktop/Colima/Podman). Recommended: **4 CPUs, 8GB RAM**.
2.  Prune unused Docker resources to free up disk space:
    ```bash
    docker system prune -f
    ```

## 2. Kafka & Operator Failures

### Kafka Resource is `Not Ready`
If `kubectl get kafka -n infrastructure` shows the cluster is not ready for an extended period.

**Solutions:**
1.  Check the Strimzi Operator logs:
    ```bash
    kubectl logs -l name=strimzi-cluster-operator -n infrastructure
    ```
2.  Check for Persistent Volume Claims (PVC) issues. Since Kind uses local storage, ensure your host disk is not full.

## 3. Schema Registry Issues

### `Apicurio Registry` fails to start
Usually caused by the PostgreSQL dependency not being fully ready.

**Solutions:**
1.  Verify PostgreSQL health:
    ```bash
    kubectl get pods -l component=postgres -n infrastructure
    ```
2.  Check the registry logs for database connection errors:
    ```bash
    kubectl logs -l component=schema-registry -n infrastructure
    ```

## 4. Cluster Lifecycle & Image Loading Errors

### Error: `ctr: command not found` or `ctr: unrecognized image format`
This occurs during the `cluster:load-images` stage.

- **Cause**: Race condition. Even though the Kind container is "Running" on the host, the internal `containerd` process inside the node is still booting.
- **Automated Fix**: The `task up` workflow now includes an automated "wait-for-containerd" loop that polls the node until the runtime is ready.
- **Manual Solution**: If it still fails, simply re-running `task up` allows the node to finish its initialization.

### Error: `failed to load image` or `NotFound: content digest`
This is the most common error during the first launch, especially with multi-platform images on macOS.

**Specific Error Messages:**
- `Error response from daemon: unable to create manifests file: NotFound: content digest sha256:... not found`
- `ERROR: command "docker save -o ... failed with error: exit status 1"`
- `ctr: content digest sha256:... not found`

**Cause:**
This is almost always caused by the **"Containerd Image Store"** (Beta feature) in Docker Desktop. When enabled, Docker stores images in a format that `kind load` cannot always export correctly, leading to missing digests during the `docker save` process.

**Solutions:**
1.  **The "Golden Fix"**: Open Docker Desktop **Settings > General** (or **Features in development**) and **uncheck** the option **"Use containerd for pulling and storing images"**. Restart Docker Desktop and run `task up`.
2.  **Self-Healing Task**: The `cluster:load-images` task now detects these failures and will attempt to force a `docker pull` to repair the local cache automatically.
3.  **Manual Repair**: If the automatic fix fails, manually delete and re-pull the image:
    ```bash
    docker rmi <image_tag>
    docker pull <image_tag>
    task up
    ```

## 5. Telemetry & Observability

### Grafana: "Datasource Error" or empty dashboards
If dashboards show "No data" or Grafana logs show `i/o timeout` when querying Prometheus.

**Possible Causes:**
- **Prometheus Port Mismatch**: If the datasource URL in Grafana is incorrect (e.g., missing port).
- **Service Discovery Issues**: Prometheus may not be discovering the pods if labels are missing.

**Error Example (in Grafana logs):**
`dial tcp <ip>:80: i/o timeout` (Note the port 80; Prometheus should be on 9090).

**Solutions:**
1.  **Check rendered configuration**: Verify that `k8s/components/overlays/local/telemetry/grafana/datasources.yaml` contains the correct Prometheus URL (e.g., `http://prometheus:9090`).
2.  **Verify Prometheus Service**:
    ```bash
    kubectl get svc prometheus -n infrastructure
    ```
3.  **Check Prometheus Discovery**: Open the Prometheus UI (usually at `http://localhost:9090`) and go to **Status > Targets**. Verify that all expected components (Kafka, Postgres, etc.) are "UP".
4.  **Re-render and Redeploy**:
    ```bash
    task render:telemetry
    task deploy:telemetry
    ```
