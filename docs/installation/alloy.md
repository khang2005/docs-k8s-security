# Install Alloy

Alloy collects and forwards Kubernetes audit logs to Loki.

## Helm Values

Create `alloy-values.yaml`:

```yaml
alloy:
  configMap:
    content: |
      logging "kubernetes-audit" {
        level  = "info"
        format = "json"

        configs = [{
          name       = "kubernetes-audit"
          scrape_confs = [{
            job_name = "kubernetes-audit"
            kubernetes_sd_configs = [{
              role = "pod"
            }]
            relabel_configs = [{
              source_labels = ["__meta_kubernetes_pod_name"]
              action        = "keep"
              regex         = "kube-apiserver-.*"
            }]
          }]
        }]
      }

      prometheus "loki" {
        forward_to = [loki.write.receiver]
      }

      loki "write" {
        endpoint {
          url = "http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push"
        }
      }
```

## Install Alloy

```bash
helm install alloy grafana/alloy \
  -n monitoring \
  -f alloy-values.yaml
```

## Verify Installation

```bash
kubectl get pods -n monitoring -l app=alloy
kubectl logs -n monitoring -l app=alloy --tail=100
```

## Configure Audit Policy

Ensure your Kubernetes API server has audit logging enabled:

```yaml
# /etc/kubernetes/audit-policy.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    resources:
      - group: ""
        resources: ["*"]
  - level: Metadata
    resources:
      - group: "*"
        resources: ["*"]
```

## Next Steps

- [Install Grafana](grafana.md) - Set up visualization
