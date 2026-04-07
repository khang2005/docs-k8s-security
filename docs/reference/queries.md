# LogQL Reference

LogQL is the query language for Loki. This reference covers common patterns for Kubernetes audit log analysis.

## Basic Syntax

```logql
{job="kubernetes-audit"} |= "error"
```

### Label Matchers

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Exact match | `{job="kubernetes-audit"}` |
| `!=` | Not equal | `{verb!="get"}` |
| `=~` | Regex match | `{resource=~"pods\|deployments"}` |
| `!~` | Not regex | `{user!~"system:.*"}` |

## Log Pipeline

```logql
{job="kubernetes-audit"} 
  | json 
  | verb == "create" 
  | resource == "pods"
```

### JSON Field Extraction

```logql
{job="kubernetes-audit"} 
  | json 
  | level = "Metadata.level"
  | user = "user.username"
```

## Aggregation Functions

### Rate

```logql
rate({job="kubernetes-audit"}[5m])
```

### Count Over Time

```logql
count_over_time({job="kubernetes-audit"}[5m])
```

### TopK / BottomK

```logql
topk(5, sum by (verb) (rate({job="kubernetes-audit"}[5m])))
```

## Common Queries

### Failed Authentication

```logql
rate({job="kubernetes-audit", responseStatus.code=~"401|403"}[5m])
```

### Deployments by User

```logql
sum by (user) (
  rate({job="kubernetes-audit", verb="post", resource="deployments"}[5m])
)
```

### Pod Creation Burst

```logql
sum by (user) (
  rate({job="kubernetes-audit", verb="post", resource="pods"}[5m])
) > 10
```

### Service Account Activity

```logql
sum by (user) (
  rate({job="kubernetes-audit", user=~"system:serviceaccount:.*"}[5m])
)
```

### Namespace Operations

```logql
sum by (namespace, verb) (
  rate({job="kubernetes-audit", resource="namespaces"}[5m])
)
```

## Formatting

### Line Formatting

```logql
{job="kubernetes-audit"} 
  | line_format "{{.timestamp}} {{.verb}} {{.resource}}"
```

### Table Format

```logql
{job="kubernetes-audit", verb="post"} 
  | json 
  | table user, resource, namespace
```

## Metrics Queries

Convert log queries to metrics:

```logql
sum(
  rate({job="kubernetes-audit", responseStatus.code="200"}[5m])
) by (user)
```

### Histogram

```logql
histogram_quantile(0.95, 
  sum(rate({job="kubernetes-audit"}[5m])) by (le, verb)
)
```
