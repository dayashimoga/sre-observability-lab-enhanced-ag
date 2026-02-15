
# Incident Response Runbook

## Severity Levels

| Severity | Description | Response Time |
| :--- | :--- | :--- |
| **SEV1** | Crucial functionality down (Ingress, DNS). | 15 mins |
| **SEV2** | Core feature degraded (Metrics missing, Logs delayed). | 1 hour |
| **SEV3** | Minor issue (Dashboard slow, Non-critical alert). | 4 hours |

## Common Incidents

### 1. Prometheus Target Down
**Alert**: `TargetDown`
**Impact**: Missing metrics for a specific service.
**Troubleshooting**:
1. Check Pod status: `kubectl get pods -n <namespace>`
2. Check Service endpoint: `kubectl get endpoints <service> -n <namespace>`
3. Check Application logs: `kubectl logs <pod> -n <namespace>`

### 2. High Error Rate (Demo App)
**Alert**: `HighErrorRate` (> 5% 5xx errors)
**Impact**: User experience degraded.
**Troubleshooting**:
1. Check Ingress logs: `kubectl logs -l app.kubernetes.io/name=ingress-nginx -n ingress-nginx`
2. Check Trace in Grafana -> Explore -> Tempo -> Query: `{ resource.service.name="demo-app" }`
3. Look for "500" status codes and expanding the trace to identify failing span.

### 3. PVC Full
**Alert**: `KubePersistentVolumeUsageCritical`
**Impact**: Data loss or service crash.
**Resolution**:
1. Identify PVC: `kubectl get pvc -A`
2. Expand PVC if StorageClass allows.
3. Delete old data (if Loki/Prometheus retention policies failed).
