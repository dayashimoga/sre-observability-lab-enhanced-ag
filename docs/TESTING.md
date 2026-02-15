
# Testing & Verification Guide

This document outlines the testing strategy for the SRE Observability Lab. It covers automated deployment checks and manual verification steps to ensure the stack is production-ready.

## 1. Automated Tests (CI/CD & Deployment)

### 1.1. Static Analysis (Linting)
*   **Tool**: `helm lint`
*   **Purpose**: Validates syntax of Helm charts before deployment.
*   **Run**: `helm lint helm-charts/apps/demo-app`

### 1.2. Deployment Automation (`deploy_stack.sh`)
*   **Scope**:
    1.  Checks for `kubectl` / `k3s`.
    2.  Installs `ArgoCD`.
    3.  Applies the Root GitOps Application.
*   **Success Criteria**: Script runs to completion with "🎉 FULL STACK DEPLOYMENT COMPLETE!".

## 2. End-to-End Verification (Manual)

Once the stack is deployed, perform these checks to verify functionality.

### 2.1. Infrastructure Health
Run: `kubectl get nodes` -> Status should be **Ready**.
Run: `kubectl get pods -A` -> All pods should be **Running** or **Completed**.

### 2.2. Observability Stack Verification

| Component | Test Action | Expected Result |
| :--- | :--- | :--- |
| **ArgoCD** | Login `https://localhost:8080` (admin/password) | All Apps (`root`, `observability`, `demo-app`) are **Synced/Healthy**. |
| **Demo App** | `curl -I http://demo.local` | HTTP 200 OK. |
| **Prometheus** | Query `up{job="demo-app"}` in Grafana | Value `1`. |
| **Loki** | Query `{app="demo-app"}` in Grafana | Recent access logs visible. |
| **Tempo** | Check "TraceID" in Logs or Explore Tempo | Traces appear for recent requests. |
| **Alertmanager** | Manually force an alert (e.g., scale down deployment) | Alert shows in Alertmanager UI. |

### 2.3. Enterprise Mock Verification
*   **Splunk**: Verify `splunk-connect-for-kubernetes` pods are running. Logs should show "Forwarding to HEC" (even if connection fails due to invalid token).
*   **Dynatrace**: Verify `dynatrace-operator` pods are running.

## 3. Failure Scenarios (Chaos Testing)
*   **Kill a Pod**: `kubectl delete pod -l app=prometheus`.
    *   *Expectation*: StatefulSet recreates the pod. Metrics gap should be minimal (HA).
*   **Delete Ingress**: `kubectl delete ingress demo-app`.
    *   *Expectation*: ArgoCD detects Drift and auto-heals (recreates Ingress) within 3 minutes.
