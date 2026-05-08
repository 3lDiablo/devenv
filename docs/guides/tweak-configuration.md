# Tweaking the Configuration

The primary way you will interact with the infrastructure definition is through the `config.yaml` file. Because of our SSoT pipeline, modifying this single file propagates changes throughout the entire cluster.

!!! tip "Reference Guide"
    For a detailed breakdown of all available keys in `config.yaml`, refer to the [Configuration Schema Reference](../reference/config-schema.md).

## Common Tweak Scenarios

### 1. Changing Port Mappings
If port `8080` is taken on your host machine by another process, you can easily move Redpanda Console to a different port.

1. Open `config.yaml`.
2. Locate the component settings:
```yaml
  redpanda_console:
    port: &rp_port 8080 # This is the INTERNAL port, usually leave it.
```
3. Locate the `cluster.ports` mapping section:
```yaml
    - name: redpanda-console
      host: *rp_port                 # Change this to 8089, or change the anchor above
      node: 30080
```
4. Run `task render` then `task cluster:create` (if you need to recreate the Kind cluster to update the port binding), or simply `task up`.

### 2. Upgrading a Component Version
To test a new version of PostgreSQL or Kafka, you do not need to hunt through Helm charts.

1. Open `config.yaml`.
2. Scroll to the `images` section:
```yaml
  postgres:
    registry: docker.io
    repository: library/postgres
    tag: "17.0-alpine" # Change this to "18.0-alpine"
```
3. Run `task up`. The pipeline will automatically fetch the new image, update the Kustomize patches, and Kubernetes will perform a rolling restart of the Postgres pod.

### 3. Adjusting Resource Allocations
If Kafka is throwing OOM errors during heavy local load testing, you can increase its limits.

1. Open `config.yaml`.
2. Find the Kafka resource block:
```yaml
    resources:
      memory:
        request: "512Mi"
        limit: "1Gi" # Increase this to "2Gi"
```
3. Run `task up`. The pipeline will automatically recalculate the JVM `-Xms` and `-Xmx` arguments based on your new `2Gi` limit (allocating roughly `1.4Gi` to the JVM).

## Applying Changes

Because our setup is declarative, the safest way to apply a change to `config.yaml` is to run:

```bash
task render
task deploy:all
```

If you changed a **Host Port mapping** or the **Node Image**, you must rebuild the cluster, as those settings are baked into the Kind container upon creation:

```bash
task down
task up
```
