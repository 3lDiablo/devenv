# Advanced Networking & Exposure

A significant challenge with local Kubernetes is exposing internal cluster services so that tools running on the host machine (like local web browsers or debuggers) can communicate with them. 

Our environment uses a highly specific networking model built on **NodePorts** and **Host Port Mapping**.

## The Networking Topology

In a standard cloud Kubernetes cluster, you use a `LoadBalancer` or `Ingress` to expose services. Locally, those don't exist by default. We expose services via a two-step process:

1. **Kubernetes NodePort:** The service inside the cluster is exposed on a high port (e.g., `30092`) on the Kind virtual node.
2. **Container Host Mapping:** The underlying Docker/Podman container that acts as the Kind node maps that high port to a standard port on the host machine (e.g., `9092` -> `30092`).

### config.yaml Driven Ports

Both layers are driven by the `config.yaml` SSoT:

```yaml
# 1. Define the anchor (the conceptual port)
settings:
  kafka:
    port: &kafka_broker_port 9092

# 2. Map the host to the NodePort using the anchor
cluster:
  ports:
    - name: kafka-broker
      host: *kafka_broker_port       # Host port (9092)
      node: 30092                    # Kubernetes NodePort
```

When the `render:kind` task runs, it injects these mappings into the Kind configuration:
```yaml
# Generated inside kind.yaml
extraPortMappings:
  - containerPort: 30092
    hostPort: 9092
    listenAddress: "0.0.0.0"
    protocol: TCP
```

## The Bind Difference: `0.0.0.0` vs `127.0.0.1`

When exposing ports via container runtimes, the `listenAddress` is a critical security and functional boundary. Our setup explicitly binds to `0.0.0.0` inside the Kind config generation.

### Docker Desktop vs Colima / Podman

The behavior of port binding differs significantly depending on the engine you use to run Kind:

* **Docker Desktop (Mac/Windows):** Docker Desktop runs a lightweight hidden VM. When you map a port to `0.0.0.0`, Docker Desktop transparently proxies that port back out to `127.0.0.1` on your actual host OS. It "feels" like native binding.
* **Colima / Podman Machine:** These tools also run a VM, but their networking stacks can be stricter. Binding to `0.0.0.0` within the container engine ensures that the port is exposed *on the VM's virtual interface*. Colima and Podman then forward this virtual interface to the host. 

If we bound to `127.0.0.1` in the Kind config, the port would only be accessible from *inside the Kind container itself* (or the hidden VM), completely breaking access from the developer's macOS/Windows host browser.

## Internal Routing (The `.infrastructure` suffix)

For components communicating *within* the cluster (e.g., Kafka Connect talking to Schema Registry), we strictly use internal Kubernetes DNS.

Because all workloads exist in the `infrastructure` namespace, internal routing takes the form:
`http://{service-name}.infrastructure:{internal-port}`

**Example:**
When Redpanda Console needs to talk to Kafka Connect, the `render:redpanda` task injects:
`http://kafka-connect-api.infrastructure:8083`

This internal traffic never leaves the cluster, meaning it is not subject to the NodePort or Host Mapping layers, ensuring maximum performance and reliability between microservices.
