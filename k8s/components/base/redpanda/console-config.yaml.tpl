# ==============================================================================
#
#               Redpanda Console - Configuration Template
#
# ==============================================================================
#
# Overview:
#   This file is a template for the main configuration of Redpanda Console. It
#   tells the web UI how to connect to the various backend services that make up
#   the Kafka ecosystem.
#
# Rendering:
#   The `Taskfile`'s `render:redpanda` task processes this file using `yq`. It
#   injects the correct service names and ports from `config.yaml` to produce the
#   final configuration file. This final file is then stored in a ConfigMap and
#   mounted into the Redpanda Console pod.
#
# ==============================================================================

# --- Kafka Configuration ---
kafka:
  brokers:
    # This value will be patched by `yq` to use the correct Kafka bootstrap service
    # name and port (e.g., "kafka-cluster-kafka-bootstrap:9092").
    - "kafka-cluster-kafka-bootstrap:9092"

# --- Schema Registry Configuration ---
schemaRegistry:
  enabled: true
  urls:
    # This URL will be patched by `yq` to point to the Apicurio Schema Registry
    # service. The path `/apis/ccompat/v7` is the standard endpoint for the
    # Confluent-compatible API that both Apicurio and Karapace provide.
    - "http://schema-registry:8081/apis/ccompat/v7"

# --- Kafka Connect Configuration ---
kafkaConnect:
  enabled: true
  clusters:
    - name: "kafka-connect"
      # This URL will be patched by `yq` to point to the Kafka Connect API service.
      # Using the full Kubernetes FQDN (`<service-name>.<namespace>`) is a robust way
      # to ensure the connection works.
      url: "http://kafka-connect-api.infrastructure:8083"
