# Smart Image Management & OCI Compliance

When working with local Kubernetes, pulling large container images (like PostgreSQL or Kafka) over the internet for every cluster teardown/rebuild is painfully slow and wastes bandwidth.

Our environment features a "Smart Image" management workflow explicitly designed for offline capability and rapid cluster recreation, fully compliant with OCI (Open Container Initiative) standards.

## The Image Pre-Loading Workflow

Inside the `Taskfile`, the `cluster:load-images` task handles the heavy lifting before any deployments are applied.

The logic follows a precise fallback cascade:

1. **Parse SSoT:** It reads the `images` block in `config.yaml` to build a unique, sorted list of all required OCI tags (e.g., `quay.io/strimzi/kafka:0.51.0-kafka-4.2.0`).
2. **Check In-Cluster:** It executes `crictl images` *inside* the Kind node container to see if the image is already present in the node's `containerd` runtime.
3. **Fallback to Host:** If missing, it checks if the image exists in the host machine's local Docker/Podman cache (`docker image inspect`).
4. **Pull if Necessary:** Only if the image is entirely missing from the host cache does it execute a remote pull.
5. **Load into Kind:** Finally, it uses `docker save` piped directly into `kind load image-archive` to instantly transfer the cached image from the host into the Kind node.

### Why not an Internal Schema Registry?
Some local Kubernetes setups deploy an insecure local Docker registry (e.g., `localhost:5000`) inside the cluster to host images. 

**Pros of our `kind load` approach over a local registry:**
- **Simplicity:** No need to run, secure, or push to an extra registry container.
- **Speed:** `docker save | kind load` streams the tarball directly into the node's containerd socket, which is often faster than a network push/pull loop.
- **Portability:** Developers can pre-pull images on their corporate network, board a flight without Wi-Fi, run `task down` and `task up`, and the cluster will fully provision using the host cache.

## Engine Interoperability (Docker, Colima, Podman)

Our scripting is engine-agnostic. The `config.yaml` defines the `provider` (default `docker`). 
The `Taskfile` dynamic variables use this provider string to execute commands.

```yaml
# In Taskfile.yml
vars:
  PROVIDER: { sh: "yq eval '.cluster.provider' config.yaml" }
```

When a command runs, it executes `{{.PROVIDER}} exec ...`, allowing seamless substitution between `docker` or `podman`.

## Deep Dive: Containerd & The Snapshotter Pattern

At the core of a Kind node is **containerd**, the industry-standard container runtime. Understanding how images are stored and executed locally is key to debugging high-performance development stacks.

### 1. The `ctr` and `crictl` Tooling
Inside the Kind node, we interact with the runtime using two primary tools:
-   **`crictl`**: The CLI for CRI-compliant runtimes. We use this to verify pod and image status in a way that mimics how the Kubelet sees the world.
-   **`ctr`**: The low-level containerd CLI. This tool allows for direct manipulation of namespaces and raw image content, often used by the Kind orchestration script during the image injection phase.

### 2. Snapshotters: The OverlayFS Magic
Containerd uses **snapshotters** to manage the container's root filesystem. 
-   **OverlayFS**: This is the default snapshotter used in our environment. It works by layering a read-only "LowerDir" (the OCI image layers) with a writable "UpperDir" (the container's specific changes).
-   **Efficiency**: Because layers are deduplicated, if multiple pods share the same base image (e.g., `alpine`), they share the same physical blocks on the Kind node's disk, significantly reducing storage overhead.

### 3. How `kind load` Works (The OCI Pipeline)
When you run `task up`, the "Image Sideloading" phase occurs:
1.  **Export**: The host engine (Docker/Podman) exports the requested image as an **OCI-compliant tarball**.
2.  **Streaming**: This tarball is streamed into the Kind container.
3.  **Import**: The Kind node executes `ctr -n k8s.io images import -`. This bypasses the node's network stack entirely and writes the layers directly into the `containerd` content store.
4.  **Metadata Sync**: Containerd updates its internal metadata, making the image immediately "visible" to the Kubelet for pod scheduling.

### 4. VM Provider Nuances (Docker Desktop vs. Colima/Podman)
Image management behavior varies depending on how the host runs the container engine:

| Provider | Runtime Environment | Image Loading Nuance |
| :--- | :--- | :--- |
| **Docker Desktop** | Managed Linux VM | Docker Desktop handles the host-to-VM sync transparently. |
| **Colima** | Lima (Linux) VM | Images are stored inside the Lima VM. When running `kind load`, Kind must first export the image *from* the Lima VM before importing it into the Kind node container. |
| **Podman Machine** | Fedora CoreOS VM | Similar to Colima, there is an extra VM boundary. If an image is pulled on macOS via a "remote" Podman client, the `kind load` command must ensure the image is physically present on the VM's disk. |

> [!TIP]
> If you encounter "Image Not Found" errors on Colima/Podman even after a successful pull, it is often due to the VM's internal metadata cache being out of sync with the host client. A `colima restart` or `podman machine stop/start` forces a metadata re-scan.
