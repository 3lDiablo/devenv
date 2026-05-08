# Environment Variables & Injection

Because our architecture relies on the SSoT pipeline (`config.yaml`), developers rarely need to export environment variables directly in their host shell.

However, it is crucial to understand how variables flow into the Kubernetes containers.

## Host Level Overrides (Optional)

The `Taskfile` evaluates certain environment variables if present on the host OS executing the commands.

* `KIND_EXPERIMENTAL_PROVIDER`: Automatically set by the `Taskfile` to match the `cluster.provider` value in `config.yaml` (e.g., `docker` or `podman`). This informs the Kind binary which engine to utilize.

## Kustomize ConfigMap Injection

Inside the cluster, practically all configurations are exposed as environment variables derived from the `global-values` ConfigMap.

When `task render:values` runs, it flattens `config.yaml` paths. If you need to map a new configuration property to an environment variable in a container deployment, you use the flattened key name.

### Flattening Rules

1. Top-level keys become prefixes.
2. Dots (`.`) are converted to underscores (`_`).
3. Example: `settings.postgres.user` becomes `settings_postgres_user`.

### Example Mapping

If your container requires an environment variable called `DB_USER`, you patch it in Kustomize:

```yaml
# In your local kustomization.yaml replacements block
- source:
    kind: ConfigMap
    name: global-values
    fieldPath: data.settings_postgres_user
  targets:
    - select:
        kind: Deployment
        name: my-app
      fieldPaths:
        - spec.template.spec.containers.[name=my-app].env.[name=DB_USER].value
```

## JVM Auto-Sizing Variables

The pipeline automatically calculates and exposes JVM memory flags based on the strict limits defined in `config.yaml`.

For components like Kafka, Schema Registry, and Kafka Connect, the following keys are automatically injected into the `global-values` ConfigMap:

* `settings_{component}_jvm_xms`: The minimum heap size (e.g., `716m`)
* `settings_{component}_jvm_xmx`: The maximum heap size (e.g., `716m`)
* `settings_{component}_java_options`: The combined flag string (e.g., `-Xms716m -Xmx716m`)

These are patched natively into the respective `Deployment` or `Kafka` CRD to guarantee that no Java process exceeds 70% of its container's hard memory limit.
