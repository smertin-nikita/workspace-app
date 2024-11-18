# Workspace microservices demo

## Prerequisites
Install helm:
https://helm.sh/docs/intro/install/

## Install
Add repositories:

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
```

Install release:
```shell
helm dep update helm -n workspace-ns
helm upgrade workspace helm -n workspace-ns --install --create-namespace
```

Update hosts file
```
<minikube ip> arch.homework prometheus.arch.homework grafana.arch.homework locust.arch.homework
```

## OpenAPI
http://arch.homework/docs

## Locust load generator
http://locust.arch.homework
Host to test http://arch.homework:80

## Grafana 
http://grafana.arch.homework

## Prometheus
http://prometheus.arch.homework/
