# Resource Management Strategy

Running a production-grade stack (Kafka, Postgres, Telemetry, multiple Operators, and Web UIs) on a single local laptop can quickly lead to OOM (Out of Memory) kills and CPU throttling if not managed carefully.

Our cluster implements an intelligent, strict resource management strategy driven entirely by the `config.yaml`.

## Requests vs. Limits (QoS)

In Kubernetes, resource allocation is handled via `requests` (guaranteed resources) and `limits` (hard caps). 

We employ a **Burstable Quality of Service (QoS)** strategy:
- **Requests** are set relatively low to ensure the Kubernetes scheduler allows all pods to be placed on the single Kind node without throwing `Insufficient Memory` errors.
- **Limits** are carefully tuned to prevent any single container (especially JVM-based ones like Kafka) from monopolizing the host system's RAM.

### SSoT Driven Allocation
All resources are defined in `config.yaml`. For example:

```yaml
settings:
  kafka:
    resources:
      cpu:
        request: "100m"
        limit: "1"
      memory:
        request: "512Mi"
        limit: "1Gi"
```

## Runtime Observability: The Resource Board

To maintain high cluster stability, we monitor the relationship between **Configured Limits** and **Actual Consumption** in real-time. 

The following board (generated via `task status`) illustrates a healthy, steady-state cluster running on a developer machine. Note how JVM-based components (Kafka, Connect) stay within their 70% heap allocation, while Go/Rust components (Otel, Redpanda Console) maintain an extremely low footprint.

```text
📊 Component Status & Resource Usage (Namespace: infrastructure)
POD                                                STATUS       | CPU REQ  CPU LIM  CPU USE  | MEM REQ  MEM LIM  MEM USE 
-------------------------------------------------- ------       | -------  -------  -------  | -------  -------  ------- 
cloudbeaver-6fc84b5666-gzs8g                       Running      | 100m     500m     7m       | 256Mi    512Mi    221Mi   
grafana-6b8667f98b-9bbqs                           Running      | 50m      200m     3m       | 128Mi    256Mi    232Mi   
kafka-cluster-broker-2                             Running      | 100m     1        46m      | 512Mi    1Gi      779Mi   
kafka-cluster-controller-3                         Running      | 100m     1        24m      | 512Mi    1Gi      619Mi   
kafka-cluster-entity-operator-78fc86f4f-79bl9      Running      | 100m     500m     14m      | 256Mi    512Mi    504Mi   
kafka-cluster-kafka-exporter-6fc5678f68-zkrfd      Running      | -        -        8m       | -        -        19Mi    
kafka-connect-connect-0                            Running      | 100m     1        14m      | 512Mi    768Mi    610Mi   
karapace-56bd4c6d9-slx7f                           Running      | 100m     500m     5m       | 256Mi    512Mi    57Mi    
kube-state-metrics-57fbd8fd-bxsgx                  Running      | 10m      100m     3m       | 32Mi     64Mi     20Mi    
otel-collector-86b6578ff5-w86z5                    Running      | 50m      200m     27m      | 256Mi    1Gi      318Mi   
postgres-7b55c6b9cc-x4266                          Running      | 100m     500m     13m      | 256Mi    512Mi    110Mi   
prometheus-7c7ffc5756-vbmfk                        Running      | 100m     500m     13m      | 256Mi    512Mi    256Mi   
redpanda-console-6d8fd75ff-5trfm                   Running      | 50m      200m     1m       | 64Mi     128Mi    87Mi    
schema-registry-5f46dddbc8-v89w9                   Running      | 100m     500m     6m       | 256Mi    384Mi    274Mi   
strimzi-cluster-operator-58d7db5bcc-9ljwh          Running      | 200m     1        47m      | 384Mi    384Mi    250Mi   
```

## JVM Auto-Sizing Automation

One of the most complex issues in local Java deployments is managing JVM Heap sizes against container limits. If a container has a 1Gi memory limit, but the JVM attempts to allocate 1.5Gi of heap, the Linux OOM Killer will forcefully terminate the container, resulting in crash loops.

To solve this, our rendering pipeline (`Taskfile`) features an intelligent JVM auto-sizing script:

1. It reads the strict `limit.memory` from `config.yaml` for Java components (Kafka, Schema Registry, Kafka Connect, Entity Operator).
2. It converts the value into Megabytes.
3. It automatically calculates **70% of the limit** and dynamically generates the `-Xms` and `-Xmx` Java options.

```bash
# Simplified representation of the pipeline logic
MEM_MB=1024 # Derived from 1Gi limit
JVM_MB=(1024 * 0.7) = 716
# Output injected into deployment: -Xms716m -Xmx716m
```
This guarantees the JVM has maximum possible safe memory while leaving 30% for native memory and OS overhead, ensuring zero OOM kills.

## Lightweight Component Alternatives

Resource management isn't just about limiting heavy apps; it's about avoiding them entirely when possible.
* We use **Alpine Linux** images wherever feasible (e.g., Postgres).
* We use **Redpanda Console** instead of Confluent Control Center.
* We use **CloudBeaver** instead of heavy Java-based DB clients.
* We utilize a **Sidecar Pattern** for the Postgres exporter to share pod overhead rather than spawning a new deployment.

By combining strict resource caps, JVM mathematical auto-sizing, and lightweight component selection, the entire cluster runs smoothly in under 8GB of RAM.
