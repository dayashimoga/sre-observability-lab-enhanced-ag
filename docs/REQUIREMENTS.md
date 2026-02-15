
# Project Requirements

## 1. Overview
The goal of this project is to implement a **Production-Grade Observability Stack** on a local Kubernetes (k3s) environment running on Windows. The stack must support Metrics, Logs, Traces, and Synthetic Monitoring, integrated with Enterprise tools (Splunk, Dynatrace), and managed via GitOps (ArgoCD).

## 2. Functional Requirements

### 2.1. Metrics Collection & Visualization
*   **Prometheus**: Must collect metrics from all cluster components (Nodes, Kubelet, cAdvisor) and application workloads.
*   **High Availability**: Prometheus must run in HA mode (2+ replicas) to ensure no gap in metrics during upgrades/failures.
*   **Long-Term Storage**: Metrics must be retained for at least 10 days locally, with object storage integration (Thanos/MinIO) for historical analysis.
*   **Grafana**: Provide dashboards for Cluster Health, Node Resources, and Application Performance (SLOs).

### 2.2. Log Aggregation
*   **Loki**: Centralized log aggregation system.
*   **Fluent Bit**: Lightweight log collector running as a DaemonSet on all nodes.
*   **Functionality**: Query logs by `app`, `namespace`, or `pod` labels. Support structural logging (JSON).

### 2.3. Distributed Tracing
*   **Tempo/Jaeger**: Ingest distributed traces from applications.
*   **OpenTelemetry**: Use OTel Collector to receive traces from applications (via OTLP) and export to Tempo.
*   **Correlation**: Traces must be linked to Logs (via TraceID) and Metrics (Exemplars).

### 2.4. Synthetic Monitoring
*   **Blackbox Exporter**: Periodically probe external endpoints (e.g., Google) and internal services to verify connectivity and uptime.

### 2.5. Application Monitoring
*   **Demo App**: A reference Nginx application.
*   **Instrumentation**: Must expose availability metrics and traces.
*   **Autoscaling**: HPA configured to scale based on CPU usage.

### 2.6. Enterprise Integration
*   **Splunk**: Forward Audit logs or specific application logs to Splunk via HEC.
*   **Dynatrace**: Deploy OneAgent for full-stack monitoring.

## 3. Non-Functional Requirements

### 3.1. Infrastructure & OS
*   **Platform**: k3s (Lightweight Kubernetes).
*   **Host OS**: Windows 10/11 (via WSL2).
*   **Resources**: optimized for 4 vCPUs / 12GB RAM.

### 3.2. GitOps & Automation
*   **ArgoCD**: All components must be deployed via ArgoCD "App of Apps" pattern.
*   **No Manual Changes**: Cluster state must match Git state.
*   **CI/CD**: GitHub Actions for linting and validiating manifests.

### 3.3. Security
*   **RBAC**: Minimal privilege principles for all service accounts.
*   **Network Policies**: Default Deny-All ingress/egress, allow-listing specific traffic.
*   **Secrets**: Encrypted at rest (SealedSecrets) or managed securely (External Secrets).
*   **TLS**: Ingress components must be served over HTTPS.

### 3.4. Reliability
*   **Persistence**: Critical data (Prometheus TSDB, Loki Chunks, Grafana DB) must persist across pod restarts using PersistentVolumeClaims (PVCs).
*   **Resiliency**: Components deployed with `PodDisruptionBudgets` and `AntiAffinity` rules where applicable.
