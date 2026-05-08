# Real-World Interactions

Once the cluster is up and running via `task up`, you will need to interact with it to develop, debug, and test your applications.

Because our architecture utilizes NodePort mapping bound to `0.0.0.0` inside the Kind container, interacting with the cluster from your host machine is extremely straightforward.

## 1. Accessing Web UIs

Web UIs are mapped directly to your `localhost`. Assuming default `config.yaml` ports:

* **Redpanda Console (Kafka UI):** `http://localhost:8080`
* **CloudBeaver (Database UI):** `http://localhost:8978`
* **Prometheus:** `http://localhost:9090`
* **Grafana:** `http://localhost:3000` (Default login is `admin` / `admin_password`)

## 2. Interacting with Kafka

### Producing / Consuming Messages via CLI
If you have local Kafka binaries installed, you can talk to the cluster just like a remote environment:

```bash
# List topics
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Produce a message
echo "Hello World" | kafka-console-producer.sh --broker-list localhost:9092 --topic my-topic

# Consume messages
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic my-topic --from-beginning
```

### Publishing Schemas via REST API (Apicurio)
You can manually publish or query schemas using the Confluent-compatible REST endpoint exposed by Apicurio.

```bash
# Query all subjects
curl http://localhost:8081/apis/ccompat/v7/subjects

# Note: The automated Taskfile `provision:kafka` handles JSON/Avro definitions found in `definitions/schemas/` automatically.
```

### Developing Kafka Connectors
Kafka Connect's REST API is fully exposed. You can POST connector configurations directly from your host terminal:

```bash
curl -X POST -H "Content-Type: application/json" --data '{
  "name": "my-postgres-source",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres.infrastructure",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "postgres",
    "database.dbname": "postgres"
  }
}' http://localhost:8083/connectors
```

> [!IMPORTANT]
> Notice in the JSON payload above, `database.hostname` is `postgres.infrastructure`. When configuring workloads that run *inside* the cluster, always use the internal Kubernetes DNS names, not `localhost`.

## 3. Database Interactions

You can connect local IDE tools (like DataGrip, DBeaver, or pgAdmin) directly to the PostgreSQL instance.

* **Host:** `localhost`
* **Port:** `5432`
* **User:** `postgres` (or as defined in `config.yaml`)
* **Password:** `postgres`

Alternatively, use the built-in CloudBeaver UI at `http://localhost:8978`.

## 4. Kubernetes `kubectl` Access

The cluster context is automatically managed by Kind. The `Taskfile` utilizes the `CONTEXT` variable to ensure commands hit the correct cluster.

To run `kubectl` manually against the cluster:

```bash
# The context name is 'kind-' followed by the cluster.name in config.yaml
kubectl get pods -n infrastructure --context kind-<cluster_name>

# Tail logs of a specific pod
kubectl logs -l component=schema-registry -n infrastructure -f --context kind-<cluster_name>
```
