# Road to Production

While this local environment provides high-fidelity simulation, certain optimizations and shortcuts used for local development must be expanded when transitioning to a production-grade Kubernetes environment (e.g., EKS, GKE, or On-Premise).

## 1. Kafka Architecture

### KRaft Quorum
- **Local**: We use a single-node setup with the `DualRole` (Broker + Controller).
- **Production**: A minimum of 3 Controller nodes is required for high availability and quorum stability. Brokers should be decoupled from Controllers and scaled across multiple Availability Zones (AZs).

### Storage
- **Local**: Uses Kind's default `local-path` storage class.
- **Production**: Must utilize high-performance block storage (e.g., AWS EBS `gp3`, Azure Disk) with appropriate IOPS provisioning and `reclaimPolicy: Retain`.

## 2. Resource Management

### JVM Auto-Sizing
- **Local**: Our pipeline auto-sizes JVM heap to 70% of the container memory limit.
- **Production**: While the 70% rule remains a good baseline, production environments require explicit tuning of Garbage Collection (GC) parameters (e.g., G1GC) based on specific throughput and latency requirements.

### Limits and Requests
- **Local**: Focused on minimizing the footprint on a developer's machine.
- **Production**: Requires strict "Guaranteed" Quality of Service (QoS) for infrastructure components (Requests = Limits) to prevent eviction during node pressure.

## 3. Security & Networking

### Exposure
- **Local**: Services are exposed via `NodePort` on `localhost`.
- **Production**: Access should be managed via **Internal Load Balancers** (for service-to-service) and an **Ingress Gateway** (e.g., Istio, NGINX) with TLS termination for external access.

### Secret Management
- **Local**: Secrets are often derived from `config.yaml` or generated as plain text.
- **Production**: All sensitive data must be managed via a dedicated Secret provider (e.g., HashiCorp Vault, AWS Secrets Manager) and integrated into Kubernetes using the Secret Store CSI Driver or External Secrets Operator.

## 4. Observability

- **Local**: Runs a lightweight Prometheus/Grafana stack within the same cluster.
- **Production**: Telemetry should be exported to a centralized, persistent observability platform (e.g., SigNoz, Datadog, or a dedicated monitoring cluster) to ensure that metrics and logs are preserved even if the workload cluster fails.
