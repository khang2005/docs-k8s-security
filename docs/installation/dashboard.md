# Dashboard Configuration

Configure the Kubernetes Audit Security Dashboard in Grafana.

## Dashboard Import

### Option 1: Import from Grafana.com

1. Navigate to **Dashboards** → **Import**
2. Enter dashboard ID: `12019` (Kubernetes Audit)
3. Select Loki datasource
4. Click Import

### Option 2: JSON Import

Import the provided `dashboard.json` from the repository.

## Panel Overview

### Overview Row

| Panel | Query | Description |
|-------|-------|-------------|
| Total Events | `{job="kubernetes-audit"}` | Count of all audit events |
| Error Rate | `rate({job="kubernetes-audit", verb="get"}[5m])` | Requests resulting in errors |
| Events by Verb | `sum by (verb) (rate({job="kubernetes-audit"}[5m]))` | Breakdown by HTTP verb |

### Authentication Row

| Panel | Query | Description |
|-------|-------|-------------|
| Login Failures | `rate({job="kubernetes-audit", responseStatuscode=~"401|403"}[5m])` | Failed auth attempts |
| Token Usage | `sum by (user) (rate({job="kubernetes-audit"}[5m]))` | Requests by user |

### Authorization Row

| Panel | Query | Description |
|-------|-------|-------------|
| RBAC Violations | `{job="kubernetes-audit", responseStatuscode="403"}` | Forbidden access attempts |
| Service Accounts | `sum by (user) (rate({job="kubernetes-audit", user=~"system:.*"}[5m]))` | Service account activity |

## Alerts

Configure alerts for security events:

```yaml
groups:
  - name: k8s-audit-alerts
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate({job="kubernetes-audit", 
                    responseStatuscode=~"5.."}[5m])) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
```

## Next Steps

- [LogQL Reference](../reference/queries.md) - Query syntax reference
