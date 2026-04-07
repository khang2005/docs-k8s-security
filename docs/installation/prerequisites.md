# Prerequisites

Before installing the K8s Audit Security Dashboard, ensure you have the following prerequisites.

## Kubernetes Cluster

- Kubernetes 1.25+ with RBAC enabled
- `kubectl` configured with cluster access
- Helm 3.11+ installed

```bash
kubectl version --short
helm version
```

## Cloudflare Account

1. Create a Cloudflare account at [dash.cloudflare.com](https://dash.cloudflare.com)
2. Obtain your Account ID from the dashboard URL
3. Create an R2 bucket named `loki-data`
4. Generate API token with:
   - `Account Permissions: Edit`
   - `R2 Bucket Permissions: Edit`

## Required API Tokens

| Token | Purpose |
|-------|---------|
| `CLOUDFLARE_API_TOKEN` | R2 bucket access |
| `CLOUDFLARE_ACCOUNT_ID` | R2 API endpoint |

## Helm Repositories

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add alloy https://grafana.github.io/helm-charts
helm repo update
```

## Resource Requirements

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Alloy | 500m | 256Mi | - |
| Loki | 1000m | 2Gi | 10Gi |
| Grafana | 200m | 256Mi | - |

## Next Steps

- [Install Loki](loki.md)
- [Install Alloy](alloy.md)
- [Install Grafana](grafana.md)
