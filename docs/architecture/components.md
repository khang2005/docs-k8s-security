# Component Structure

Detailed documentation of each component in the K8s Audit Security Dashboard.

## Alloy

Alloy is the successor to Grafana Agent, providing Kubernetes-native observability data collection.

### Installation

```bash
helm install alloy grafana/alloy -n monitoring -f values.yaml
```

### Configuration

```yaml
logging "kubernetes-audit" {
  level  = "info"
  format = "json"

  configs = [{
    name       = "kubernetes-audit"
    scrape_confs = [{
      job_name   = "kubernetes-audit"
      kubernetes_sd_configs = [{
        role = "pod"
        namespaces = {
          own_namespace = true
        }
      }]
      pipeline_stages = [...]
    }]
  }]
}
```

## Loki

Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system.

### Helm Values

```yaml
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storageConfig:
    aws:
      bucketnames: loki
      endpoint: ${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
      region: auto
```

## Grafana

Grafana provides visualization and alerting for Loki data.

### Dashboard Features

- **Overview Panel**: Total audit events, error rate
- **Authentication Panel**: Login failures, token usage
- **Authorization Panel**: RBAC violations, permission checks
- **Resource Panel**: Deployment changes, scaling events

## Cloudflare R2

R2 provides object storage for Loki's chunk storage backend.

### Bucket Configuration

- **Bucket Name**: `loki-data`
- **Access**: Via S3-compatible API with R2 credentials

## Cloudflare Worker

Worker serves the documentation site from R2 bucket.

### Endpoints

- `GET /` - Serve index.html
- `GET /*` - Proxy to R2 object
