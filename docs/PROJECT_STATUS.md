
# Project Status & Roadmap

## 1. Project Overview
This repository hosts a production-grade **SRE Observability Lab** designed to run on a local Windows/WSL2 environment using k3s. It features a full monitoring stack (Prometheus, Loki, Tempo), Enterprise integrations (Splunk, Dynatrace), and a sample application, all managed via GitOps (ArgoCD).

## 2. Implementation Status

### ✅ Completed Features
| Component | Details |
| :--- | :--- |
| **K3s Infrastructure** | Automated setup scripts (`setup_windows.ps1`, `setup_k3s.sh`) for WSL2. |
| **Ingress** | Nginx Ingress Controller with Cert Manager for TLS. |
| **Metrics** | Kube-Prometheus-Stack (HA Repicas=2), Persistent Storage (LocalPath). |
| **Logs** | Loki (Distributed) with MinIO (S3 compatible) backend. Fluent Bit DaemonSet. |
| **Traces** | Grafana Tempo (S3 backend), OpenTelemetry Collector. |
| **Demo App** | Hardened Nginx container, auto-instrumented with OpenTelemetry, HPA enabled. |
| **GitOps** | ArgoCD "App of Apps" pattern (`argocd-apps/root.yaml`) managing the whole stack. |
| **Security** | Network Policies (Default Deny), Non-root containers, RBAC. |
| **Documentation** | Architecture, Requirements, Setup Guide, Runbooks. |

### 🚧 Pending / In-Progress
| Component | Status | Notes |
| :--- | :--- | :--- |
| **Service Mesh** | *Skipped* | Linkerd/Istio omitted to save resources on local lab environment. |
| **Vault Integration** | *Planned* | Secrets currently use SealedSecrets (simulated). HashiCorp Vault integration is a future enhancement. |
| **Chaos Engineering** | *Planned* | LitmusChaos or Chaos Mesh integration for reliability testing. |

### 🔮 Future Enhancements
1.  **Canary Deployments**: Integrate Argo Rollouts for the Demo App.
2.  **Cost Monitoring**: Install Kubecost to track resource usage.
3.  **Cloud Hybrid**: Connect local k3s to a cloud control plane (e.g., Rancher).

## 3. How to Understand This Project (Step-by-Step)

### Step 1: Infrastructure Layer (`scripts/`)
Start here. The scripts configure the underlying OS (Windows/Linux) to support Kubernetes.
*   `setup_windows.ps1`: Allocates RAM/CPU.
*   `setup_k3s.sh`: Installs the cluster binary/process.

### Step 2: GitOps Layer (`argocd-apps/`)
Understand the entry point. ArgoCD looks at these manifests to decide *what* to deploy.
*   `root.yaml`: The parent application.
*   `observability.yaml`: The child app defining the monitoring stack.

### Step 3: Configuration Layer (`helm-charts/`)
Deep dive into *how* things are deployed. We use the "Wrapper Chart" pattern.
*   Look at `helm-charts/observability/kube-prometheus-stack/values.yaml`.
*   Notice the `PRODUCTION GRADE` comments explaining HA and Storage settings.

### Step 4: Application Layer (`demo-app/`)
See the workload.
*   `Dockerfile`: Minimalist, secure image.
*   `index.html`: The content being served.

## 4. Testing Strategy

### Unit Testing (Linting)
We verify the YAML syntax and Helm constraints.
```bash
helm lint helm-charts/apps/demo-app
```

### End-to-End Testing (Manual Verification)
1.  **Deployment**: Run `scripts/deploy_stack.sh`.
2.  **Health Check**: Ensure all pods are running.
3.  **Functionality**:
    *   Visit `http://demo.local` -> Generates Traffic.
    *   Visit `http://grafana.local` -> View "Demo App" Dashboard.
    *   Confirm Metrics (Requests/sec), Logs (Access logs), and Traces (Latency) appear.
