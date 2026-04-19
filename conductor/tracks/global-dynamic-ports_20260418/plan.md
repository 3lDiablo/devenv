# Implementation Plan: Extend Dynamic Ports

This plan extends the "define-once" port pattern to all remaining components, one by one. Each phase represents a single component and will be verified before proceeding to the next.

### Phase 1: Kafka Broker Port (9092)

- [x] Task: In `config.yaml`, add a `port: &kafka_broker_port 9092` key to the `settings.kafka` block.
- [x] Task: In `config.yaml`, update the `host` key for the `kafka-broker` entry in `cluster.ports` to use the alias `*kafka_broker_port`.
- [x] Task: Verify the change by running `task render` and inspecting the generated `kind.yaml` to ensure the `hostPort` is correct.

### Phase 2: Schema Registry Port (8081)

- [x] Task: In `config.yaml`, create a `settings.schema_registry` block with a `port: &sr_port 8081` key.
- [x] Task: In `config.yaml`, update the `host` key for the `schema-registry` entry to use the alias `*sr_port`.
- [x] Task: Add a Kustomize `replacement` to target the `containerPort` in the Schema Registry `Deployment` and the `port`/`targetPort` in its `Service`.
- [x] Task: Verify the Schema Registry changes by running `task up` and inspecting the deployed resources.

### Phase 3: Kafka Connect Port (8083)

- [x] Task: In `config.yaml`, create a `settings.kafka_connect` block with a `port: &kc_port 8083` key.
- [x] Task: In `config.yaml`, update the `host` key for the `kafka-connect` entry to use the alias `*kc_port`.
- [x] Task: Add a Kustomize `replacement` to target the `port` in the Kafka Connect `Service`.
- [x] Task: Verify the Kafka Connect changes.

### Phase 4: Redpanda Console Port (8080)

- [x] Task: In `config.yaml`, create a `settings.redpanda_console` block with a `port: &rp_port 8080` key.
- [x] Task: In `config.yaml`, update the `host` key for the `redpanda-console` entry to use the alias `*rp_port`.
- [x] Task: Add a Kustomize `replacement` to target the `containerPort` in the `Deployment` and `port` in the `Service`.
- [x] Task: Verify the Redpanda Console changes.

### Phase 5: Cloudbeaver Port (8978)

- [x] Task: In `config.yaml`, add a `port: &cb_port 8978` key to the `settings.cloudbeaver` block.
- [x] Task: In `config.yaml`, update the `host` key for the `cloudbeaver` entry to use the alias `*cb_port`.
- [x] Task: Add a Kustomize `replacement` to target the `containerPort` in the `Deployment` and `port` in the `Service`.
- [x] Task: Verify the Cloudbeaver changes.