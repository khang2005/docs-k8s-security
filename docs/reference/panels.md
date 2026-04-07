# Dashboard Panels

Reference for dashboard panel configurations and best practices.

## Panel Types

### Stat Panel

Best for single-value metrics with trend.

```json
{
  "type": "stat",
  "fieldConfig": {
    "defaults": {
      "unit": "short",
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {"value": 0, "color": "green"},
          {"value": 100, "color": "yellow"},
          {"value": 500, "color": "red"}
        ]
      }
    }
  },
  "options": {
    "colorMode": "value",
    "orientation": "auto"
  }
}
```

### Time Series Panel

Best for visualizing metric trends over time.

```json
{
  "type": "timeseries",
  "fieldConfig": {
    "defaults": {
      "unit": "reqps",
      "custom": {
        "drawStyle": "line",
        "lineInterpolation": "smooth",
        "showPoints": "auto"
      }
    }
  }
}
```

### Bar Gauge

Best for showing current values against thresholds.

```json
{
  "type": "bargauge",
  "options": {
    "displayMode": "gradient",
    "orientation": "horizontal",
    "showUnfilled": true
  }
}
```

## Visualization Options

### Color Schemes

| Mode | Use Case |
|------|----------|
| `palette-classic` | Default coloring |
| `palette-classic-by-name` | Match series colors |
| `thresholds` | Based on threshold steps |
| `continuous-RdYlGr` | Gradient from red to green |

### Legend

```json
{
  "legend": {
    "displayMode": "table",
    "placement": "right",
    "showLegend": true,
    "values": ["mean", "last"]
  }
}
```

## Common Configurations

### Percentage Panel

```json
{
  "type": "gauge",
  "fieldConfig": {
    "defaults": {
      "unit": "percentunit",
      "max": 1,
      "thresholds": {
        "steps": [
          {"value": 0, "color": "red"},
          {"value": 0.9, "color": "yellow"},
          {"value": 0.95, "color": "green"}
        ]
      }
    }
  }
}
```

### Log Panel

```json
{
  "type": "logs",
  "options": {
    "showLabels": true,
    "showCommonLabels": true,
    "wrapLogMessage": false,
    " prettifyLogMessage": true,
    "enableLogDetails": true
  }
}
```

## Transformations

### Organize Fields

Reorder or hide fields from query results:

```json
{
  "id": "organize",
  "options": {
    "excludeByName": {
      "timestamp": false
    },
    "indexByName": {
      "user": 0,
      "verb": 1,
      "resource": 2
    }
  }
}
```

### Add Field from Calculation

Create calculated fields:

```json
{
  "id": "addFieldFromCalculation",
  "options": {
    "mode": "binary",
    "binary": {
      "left": "success_count",
      "operator": "/",
      "right": "total_count"
    },
    "operation": "result"
  }
}
```

## Links and Drilldown

Add links to navigate from panels:

```json
{
  "links": [
    {
      "title": "Explore Logs",
      "url": "/explore?left=${__from},${__to},${datasource},${__data.fields}",
      "type": "link"
    }
  ]
}
```
