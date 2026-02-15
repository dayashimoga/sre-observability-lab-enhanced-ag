
# SRE Observability Lab (Enhanced)

A production-grade, GitOps-driven Observability stack for Kubernetes (k3s), designed for SREs to practice monitoring, logging, tracing, and incident response.

## 🚀 Features

*   **Full Stack Observability**: 
    *   **Metrics**: Prometheus (HA), Grafana, Alertmanager.
    *   **Logs**: Loki (Distributed), Fluent Bit.
    *   **Traces**: Tempo, OpenTelemetry.
*   **GitOps**: Fully automated deployment using ArgoCD.
*   **Security**: Network Policies, RBAC, Hardened Containers.
*   **Enterprise Ready**: Pre-configured for Splunk and Dynatrace integrations.

## 📂 Documentation

*   [**Setup Guide (Windows)**](docs/SETUP_WINDOWS.md): Get your local environment ready.
*   [**Requirements**](docs/REQUIREMENTS.md): Detailed functional specs.
*   [**Architecture**](docs/ARCHITECTURE.md): System design and component interaction.
*   [**Runbooks**](runbooks/incident-response.md): How to handle alerts.

## ⚡ Quick Start

1.  **Install k3s**: Follow the [Setup Guide](docs/SETUP_WINDOWS.md).
2.  **Install ArgoCD**:
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
3.  **Deploy**:
    ```bash
    kubectl apply -f argocd-apps/root.yaml
    ```
4.  **Access Grafana**: `http://grafana.local` (after Ingress setup).

## 🧪 Testing
Run the CI validation locally:
```bash
helm lint helm-charts/apps/demo-app
helm lint helm-charts/observability/kube-prometheus-stack
```
