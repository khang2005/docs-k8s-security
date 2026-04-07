# Install Grafana

Grafana provides visualization and dashboards for Loki data.

## Helm Values

Create `grafana-values.yaml`:

```yaml
grafana:
  adminPassword: "${GRAFANA_ADMIN_PASSWORD}"
  
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Loki
          type: loki
          access: proxy
          url: http://loki.monitoring.svc.cluster.local:3100
          jsonData:
            timeout: 60
          isDefault: true

  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
        - name: 'default'
          orgId: 1
          folder: ''
          type: file
          disableDeletion: false
          updateIntervalSeconds: 10
          allowUiUpdates: true

  dashboards:
    default:
      kubernetes-audit:
        gnetId: 12019
        revision: 1
        datasource: Loki

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - grafana.example.com
  tls:
    - secretName: grafana-tls
      hosts:
        - grafana.example.com
```

## Install Grafana

```bash
helm install grafana grafana/grafana \
  -n monitoring \
  -f grafana-values.yaml
```

## Get Admin Password

```bash
kubectl get secret --namespace monitoring grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

## Access Grafana

```bash
kubectl port-forward svc/grafana 3000:80
```

Open http://localhost:3000 and login with `admin`.

## Next Steps

- [Configure Dashboard](dashboard.md) - Set up audit dashboard
