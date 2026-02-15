# Demo App Incident Response Runbook

## Symptoms
- High latency
- Error rate spikes
- Pod crash loops

## Diagnosis
1. Check Grafana dashboard for latency/error metrics.
2. Inspect logs in Loki.
3. Trace requests in Jaeger.

## Resolution
- Scale deployment: kubectl scale deploy demo-app --replicas=4
- Rollback recent changes if errors persist.
- Restart pods if crash looping.

## Postmortem
- Document RCA in postmortem-template.md
- Update alert thresholds if needed.
