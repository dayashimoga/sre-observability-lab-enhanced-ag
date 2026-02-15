
# Architecture & Design

## 1. High-Level Architecture

The solution implements a localized "Modern Data Stack" for Observability on Kubernetes.

```mermaid
graph TD
    subgraph "Windows / WSL2 (k3s)"
        subgraph "Ingress Layer"
            Nginx[Nginx Ingress] -->|Routes| Grafana
            Nginx -->|Routes| Prometheus
            Nginx -->|Routes| DemoApp
        end

        subgraph "Observability Namespace"
            Prometheus[Prometheus (HA)] -->|Scrapes| DemoApp
            Prometheus -->|Writes| MinIO[(MinIO Object Store)]
            
            Loki[Loki (HA)] -->|Writes| MinIO
            
            Tempo[Tempo] -->|Writes| MinIO
            
            Grafana -->|Reads| Prometheus
            Grafana -->|Reads| Loki
            Grafana -->|Reads| Tempo
            
            Alertmanager -->|Notifies| PagerDuty[PagerDuty (Mock)]
        end

        subgraph "Node Level"
            FluentBit[Fluent Bit] -->|Pushes Logs| Loki
            OTel[OTel Collector] -->|Pushes Traces| Tempo
        end
        
        subgraph "Demo Namespace"
            DemoApp[Demo Application]
        end
    end

    DevOps[DevOps Engineer] -->|Git Push| GitHub
    GitHub -->|Sync| ArgoCD[ArgoCD Controller]
    ArgoCD -->|Reconcile| k3s
```

## 2. Project Structure

```text
sre-observability-lab-enhanced-ag/
├── .github/
│   └── workflows/          # CI/CD Pipelines (Linting, Validation)
├── argocd-apps/            # GitOps Application Manifests
│   ├── root.yaml           # "App of Apps" entry point
│   ├── observability.yaml  # Observability Stack App
│   └── demo-app.yaml       # User Workloads App
├── config/                 # Shared Configurations
│   ├── network-policies/   # Default Network Policies (Security)
│   └── rbac/               # RBAC Roles & Bindings
├── demo-app/               # Application Source Code
│   ├── Dockerfile          # Hardened Container Image
│   └── ...
├── docs/                   # Documentation
│   ├── ARCHITECTURE.md     # This file
│   ├── REQUIREMENTS.md     # Detailed Requirements
│   └── SETUP_WINDOWS.md    # Installation Guide
├── helm-charts/            # Helm Chart Wrappers
│   ├── apps/
│   │   └── demo-app        # Chart for the Demo Service
│   ├── core/               # Infrastructure Charts
│   │   ├── cert-manager
│   │   ├── ingress-nginx
│   │   └── storage         # StorageClasses
│   ├── enterprise/         # 3rd Party Integrations
│   │   ├── dynatrace
│   │   └── splunk
│   └── observability/      # The Stack
│       ├── blackbox-exporter
│       ├── fluent-bit
│       ├── kube-prometheus-stack
│       ├── loki-distributed
│       └── tempo           # Tracing Backend
└── runbooks/               # Operational Guides
    └── incident-response.md
```

## 3. Production-Grade Features

### 3.1. High Availability (HA)
*   **Prometheus**: Deployed as a `StatefulSet` with 2 replicas. Each replica scrapes targets independently.
*   **Loki**: Distributed microservices architecture (Ingesters, Queriers, Distributors) scaled explicitly.
*   **Rolling Updates**: All deployments use `RollingUpdate` strategies to ensure zero downtime during configuration changes.

### 3.2. Persistence & Storage Strategy
*   **Local Path Provisioner**: configured with `Retain` policy to prevent data loss if a PVC is deleted accidentally.
*   **Object Storage (MinIO)**: Used as the "Source of Truth" for Long-Term retention of Logs (Loki) and Traces (Tempo). This mimics AWS S3 production setups.

### 3.3. Security Hardening
*   **Network Policies**: We implement a "Default Deny" posture. Services must explicitly allow traffic (e.g., Prometheus is allowed to scrape Demo App, but Demo App cannot talk to Kubernetes API).
*   **Non-Root Containers**: The Demo App `Dockerfile` enforces `USER nginx` to prevent privilege escalation attacks.
*   **Read-Only Root Filesystem**: (Configured in values) Containers run with read-only root where possible.

### 3.4. GitOps Workflow
*   **Auditability**: Every change to the cluster is recorded in a Git Commit.
*   **Drift Detection**: ArgoCD automatically detects if someone manually changes a resource (`kubectl edit`) and heals it back to the Git state.
