# Configuration Schema Reference

This page provides a comprehensive reference for all configuration keys available in the `config.yaml` file. This file serves as the Single Source of Truth (SSoT) for the entire development environment.

## 1. Service Settings (`settings:`)

The `settings` block defines the operational parameters for each service deployed in the cluster.

!!! tip "Extending the Schema"
    To learn how to add your own services to this block, see the [Deploying a New Component](../guides/add-component.md) guide.

### Kafka (`settings.kafka`)
| Key | Type | Description | Default | Impact |
| :--- | :--- | :--- | :--- | :--- |
| `cluster_name` | String | Name of the Kafka cluster resource. | `kafka-cluster` | Affects resource names in K8s. |
| `version` | String | Apache Kafka version. | `4.2.0` | Determines features and compatibility. |
| `metadata_version` | String | KRaft metadata version. | `4.2-IV1` | Must match Kafka version requirements. |
| `broker_replicas` | Integer | Number of Kafka brokers. | `1` | Affects availability and resource usage. |
| `controller_replicas`| Integer | Number of KRaft controllers. | `1` | Determines quorum size. |
| `default_partitions` | Integer | Default partitions for topics. | `6` | Sets baseline for auto-created topics. |
| `port` | Integer | Internal broker port. | `9092` | Internal listener configuration. |
| `resources.cpu.request`| String | Initial CPU allocation. | `100m` | Scheduling priority. |
| `resources.memory.limit`| String | Maximum RAM allocation. | `1Gi` | JVM heap is auto-sized to 70% of this. |

### PostgreSQL (`settings.postgres`)
| Key | Type | Description | Default | Impact |
| :--- | :--- | :--- | :--- | :--- |
| `db_name` | String | Default database name. | `postgres` | Initialization parameter. |
| `user` | String | Administrative username. | `postgres` | Credentials for all services. |
| `password` | String | Administrative password. | `postgres` | **Security**: Change for sensitive data. |
| `port` | Integer | Database listener port. | `5432` | Internal connection endpoint. |

### Telemetry Stack (`settings.telemetry`)
| Key | Type | Description | Default | Impact |
| :--- | :--- | :--- | :--- | :--- |
| `enabled` | Boolean | Enable OTel/Prometheus stack. | `true` | Toggle for observability features. |
| `common_metrics_port` | Integer | Standard port for exporters. | `8080` | Scraping endpoint configuration. |

---

## 2. Cluster Configuration (`cluster:`)

Defines the underlying Kind Kubernetes infrastructure.

!!! info "Operational Guide"
    For practical examples on changing cluster ports or provider settings, see [Tweaking the Configuration](../guides/tweak-configuration.md).

| Key | Type | Description | Default | Impact |
| :--- | :--- | :--- | :--- | :--- |
| `name` | String | Name of the Kind cluster. | `<cluster_name>` | Affects `kubectl` context name. |
| `provider` | String | Container engine (`docker`/`podman`). | `docker` | Determines CLI tool and networking logic. |
| `node_image` | String | Kubernetes node version. | `v1.31.0` | Determines K8s API version. |
| `api_server_port` | Integer | Local API server port. | `6443` | Endpoint for `kubectl`. |

### Port Mappings (`cluster.ports`)
List of objects mapping host ports to cluster NodePorts.
- `name`: Human-readable identifier.
- `host`: Port exposed on `localhost`.
- `node`: The internal Kubernetes NodePort (30000-32767).

---

## 3. Image Registry (`images:`)

Centralized version management for all container images. Each entry consists of:

!!! tip "Deep Dive"
    To understand how these image strings are used to automatically pull and load images into the local cluster, read the [Smart Image Management](../internals/image-management.md) documentation.
- `registry`: e.g., `docker.io` or `quay.io`.
- `repository`: Path to the image.
- `tag`: Version identifier.

The pipeline automatically constructs the full image string: `{registry}/{repository}:{tag}`.
