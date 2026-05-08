# ==============================================================================
#
#               Prometheus - Configuration File (prometheus.yml)
#
# ==============================================================================
#
# Overview:
#   This file defines the configuration for the Prometheus server. It tells
#   Prometheus what to scrape (the "scrape_configs"), how often to scrape it,
#   and how to label the collected metrics.
#
#   This configuration is mounted into the Prometheus pod via a ConfigMap.
#
# Key Features:
#   -   Kubernetes Service Discovery: Instead of hardcoding the IP addresses of
#       services to scrape, this configuration uses `kubernetes_sd_configs`.
#       Prometheus will automatically discover pods and nodes in the cluster and
#       scrape them if they match the defined rules.
#   -   Relabeling: Extensive use of `relabel_configs` allows for powerful,
#       dynamic manipulation of the metadata (labels) associated with scrape
#       targets. This is used to filter targets, set the correct port, and add
#       meaningful labels to the metrics.
#
# ==============================================================================

global:
  # How frequently to scrape targets by default.
  scrape_interval: 10s

# A list of scrape configurations, also known as "jobs".
scrape_configs:
  # --- Job: Scrape application pods in the 'infrastructure' namespace ---
  - job_name: 'kubernetes-pods'
    # Use Kubernetes Service Discovery to find scrape targets.
    kubernetes_sd_configs:
      # The `pod` role discovers all pods in the cluster.
      - role: pod
        # We only care about pods in our specific namespace.
        namespaces:
          names:
            - infrastructure
    # --- Relabeling Rules ---
    # Relabeling is a powerful feature to rewrite the label set of a target before it is scraped.
    # The rules are applied in order to each discovered pod.
    relabel_configs:
      # Rule 1: Keep only pods that have a `component` label matching our services.
      # This is the primary filtering mechanism.
      - source_labels: [__meta_kubernetes_pod_label_component]
        action: keep
        regex: (kafka-cluster|kafka-nodepool|postgres|schema-registry|redpanda|kube-state-metrics|kafka-connect)

      # Rule 2: Further filter pods based on their known metrics port.
      # Some pods expose multiple ports, but we only want to scrape the `/metrics` endpoint.
      # This rule keeps a target only if its component and port number match a known combination.
      - source_labels: [__meta_kubernetes_pod_label_component, __meta_kubernetes_pod_container_port_number]
        action: keep
        regex: (KAFKA_NAME|kafka-nodepool|kafka-connect);KAFKA_METRICS_PORT|(postgres);POSTGRES_METRICS_PORT|(schema-registry|redpanda|kube-state-metrics);COMMON_METRICS_PORT

      # Rule 3-5: Rewrite the target's scrape address (`__address__`).
      # By default, Prometheus uses the pod's IP and the container's port. These rules
      # ensure the correct metrics port is always used, based on the component label.
      - source_labels: [__meta_kubernetes_pod_label_component, __meta_kubernetes_pod_ip]
        action: replace
        regex: (KAFKA_NAME|kafka-nodepool|kafka-connect);(.+)
        replacement: ${2}:KAFKA_METRICS_PORT # Use port KAFKA_METRICS_PORT for Kafka components.
        target_label: __address__
      - source_labels: [__meta_kubernetes_pod_label_component, __meta_kubernetes_pod_ip]
        action: replace
        regex: (postgres);(.+)
        replacement: ${2}:POSTGRES_METRICS_PORT # Use port POSTGRES_METRICS_PORT for Postgres.
        target_label: __address__
      - source_labels: [__meta_kubernetes_pod_label_component, __meta_kubernetes_pod_ip]
        action: replace
        regex: (schema-registry|redpanda|kube-state-metrics);(.+)
        replacement: ${2}:COMMON_METRICS_PORT # Use port COMMON_METRICS_PORT for these components.
        target_label: __address__

      # Rule 6-9: Add useful metadata from the pod discovery as permanent labels on the metrics.
      - source_labels: [__meta_kubernetes_namespace]
        target_label: namespace
      - source_labels: [__meta_kubernetes_pod_name]
        target_label: pod
      - source_labels: [__meta_kubernetes_pod_name]
        target_label: kubernetes_pod_name
      - source_labels: [__meta_kubernetes_pod_label_component]
        target_label: component
      
      # Rule 10: Copy all labels from the Kubernetes pod (e.g., `app`, `version`)
      # to the metrics, prefixed with `pod_`.
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      
      # Rule 11-13: Standardize the `job` label. This is useful for Grafana dashboards
      # that expect a consistent job name (e.g., all Kafka-related components get the `job="kafka"` label).
      - source_labels: [__meta_kubernetes_pod_label_component]
        action: replace
        regex: (KAFKA_NAME|kafka-nodepool|kafka-connect)
        replacement: kafka
        target_label: job
      - source_labels: [__meta_kubernetes_pod_label_component]
        action: replace
        regex: postgres
        replacement: postgres
        target_label: job
      - source_labels: [__meta_kubernetes_pod_label_component]
        action: replace
        regex: (schema-registry|redpanda|karapace|kube-state-metrics)
        replacement: $1
        target_label: job

    # --- Metric Relabeling Rules ---
    # These rules are applied *after* the scrape has occurred, but before the data is ingested.
    metric_relabel_configs:
      # Standardize the `instance` label to be the scrape address.
      - source_labels: [__address__]
        action: replace
        target_label: instance

  # --- Job: Scrape cAdvisor metrics from Kubernetes nodes ---
  # cAdvisor provides resource usage and performance metrics for containers.
  - job_name: 'kubernetes-nodes-cadvisor'
    scheme: https
    honor_labels: true
    # Use the pod's service account to securely connect to the Kubelet API.
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true # Required for Kind's self-signed certs.
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    kubernetes_sd_configs:
      # Discover all Kubernetes nodes.
      - role: node
    relabel_configs:
      # Copy all labels from the node to the metrics.
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      # The Kubelet API address is discovered on port 10250.
      - source_labels: [__address__]
        regex: '(.*):10250'
        replacement: '${1}:10250'
        target_label: __address__
      # Dynamically set the metrics path to the cAdvisor endpoint.
      - source_labels: [__meta_kubernetes_node_name]
        target_label: __metrics_path__
        replacement: /metrics/cadvisor
    metric_relabel_configs:
      # Drop metrics that don't have a container label (they are usually duplicates).
      - source_labels: [container]
        regex: '^$'
        action: drop

  # --- Job: Scrape Kubelet's own metrics ---
  # The Kubelet itself also exposes useful metrics about the node's health.
  - job_name: 'kubernetes-nodes-kubelet'
    scheme: https
    honor_labels: true
    tls_config:
      ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      insecure_skip_verify: true
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - source_labels: [__address__]
        regex: '(.*):10250'
        replacement: '${1}:10250'
        target_label: __address__
        # Note: The metrics path defaults to `/metrics`, which is correct for the Kubelet's own metrics.
