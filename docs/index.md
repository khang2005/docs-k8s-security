# K8s Audit Security Dashboard

Documentation for the Kubernetes Audit Security Dashboard project. This project provides log aggregation and visualization for Kubernetes audit logs using Grafana, Loki, and Alloy.

## Overview

This dashboard enables security teams to monitor and analyze Kubernetes audit events, providing visibility into:

- API server request patterns
- Authentication failures
- Permission escalations
- Resource modifications
- Compliance auditing

## Architecture

The system consists of the following components:

- **Alloy**: Kubernetes-native collector that ships audit logs to Loki
- **Loki**: Log aggregation system optimized for Kubernetes workloads
- **Grafana**: Visualization and alerting platform
- **Cloudflare R2**: Object storage for documentation
- **Cloudflare Worker**: Serves the documentation site

## Quick Links

- [Architecture Overview](architecture/diagrams.md)
- [Installation Guide](installation/prerequisites.md)
- [LogQL Reference](reference/queries.md)

## Repository

[:material-github: khangduytran/k8s-audit-security](https://github.com/khangduytran/k8s-audit-security){ .md-button }
