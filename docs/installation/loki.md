# Install Loki

Loki is the log aggregation system that stores and indexes Kubernetes audit logs.

## Create Namespace

```bash
kubectl create namespace monitoring
```

## Create Secret

```bash
kubectl create secret generic loki-secrets \
  --from-literal=CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN} \
  --from-literal=CLOUDFLARE_ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID} \
  -n monitoring
```

## Helm Values

Create `loki-values.yaml`:

```yaml
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storageConfig:
    aws:
      bucketnames: loki-data
      endpoint: ${CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com
      region: auto
      s3forcepathstyle: true
  schema_config:
    configs:
      - from: "2024-01-01"
        store: boltdb-shipper
        object_store: aws
        schema: v11
        index:
          prefix: index_
          period: 24h

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - loki.example.com
```

## Install Loki

```bash
helm install loki grafana/loki \
  -n monitoring \
  -f loki-values.yaml
```

## Verify Installation

```bash
kubectl get pods -n monitoring -l app=loki
kubectl logs -n monitoring -l app=loki --tail=100
```

## Next Steps

- [Install Alloy](alloy.md) - Configure log collection
