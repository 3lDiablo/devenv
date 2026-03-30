# 🚀 Local Development Environment on Kubernetes

This project provides a complete local development environment, based on Kubernetes via `kind`. It includes essential services like PostgreSQL, Kafka (in KRaft mode), Schema Registry, Kafka Connect, and a Kafka GUI, all managed simply with [Task](https://taskfile.dev/).

![Language](https://img.shields.io/badge/Shell-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Tool](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Tool](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Tool](https://img.shields.io/badge/Helm-0f162e?style=for-the-badge&logo=helm&logoColor=white)

---

## ⚙️ Configuration (`.env` file)

This project uses a `.env` file to manage all environment-specific configurations.

1.  **Copy the template:** `cp .env.template .env`
2.  **Fill in the values:** Edit the `.env` file with your desired service versions and cluster name.

### Image Repositories

Due to a policy change by VMware, older Bitnami images are now hosted in the `bitnamilegacy` Docker Hub repository. The configuration in `.env` allows you to specify both the repository and the tag for each service, ensuring reliable and reproducible builds.

---

## 🛠️ Setup

### 1. Install Task (macOS)

If you don't have `Task` installed, run this command:

```bash
brew install go-task/tap/go-task
```

### 2. Install Other Dependencies

The `setup` task will use Homebrew to install all other necessary tools (`kind`, `kubectl`, `helm`).

```bash
task setup
```

---

## 🛡️ Context Safety

**This environment is safe to manage, regardless of your current `kubectl` context.**

All `helm` and `kubectl` commands are explicitly configured to operate *only* on the `kind` cluster defined in your `.env` file.

---

## 🏁 Quick Start

### ▶️ Start the Environment

A single command to launch everything based on the configuration in `.env`.

```bash
task up
```

### ⏹️ Stop the Environment

To delete the cluster and all associated resources.

```bash
task down
```

### 🔄 Reinstall Services

If a service gets stuck in a bad state, you can force a clean reinstallation.

```bash
# Reinstall all services
task reinstall

# Reinstall a specific service (e.g., postgres, kafka, console)
task reinstall postgres
```

---

## 🔌 Service Access & GUIs

### 🐘 PostgreSQL

*   **Host**: `localhost`
*   **Port**: `5432`
*   **Superuser**: `postgres` / `password`
*   **Default DB**: `devdb`
*   **Recommended GUI**: [**Beekeeper Studio**](https://www.beekeeperstudio.io/) (modern, fast, user-friendly SQL client)

###  kafka Kafka

*   **Bootstrap Server**: `localhost:9094`
*   **Schema Registry**: `localhost:8081`
*   **Kafka Connect**: `localhost:8083`
*   **Recommended GUI**: [**Redpanda Console**](https://redpanda.com/docs/console/get-started/) (lightweight, feature-rich, open-source)
    *   **Access URL**: `http://localhost:8080`

---

## 📦 Data Persistence

Data for all stateful services (PostgreSQL, Kafka) is persistent and will survive cluster restarts. To completely wipe all data, run `task down`.
