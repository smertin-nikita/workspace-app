# Workspace microservices demo

## Prerequisites
Install helm:
https://helm.sh/docs/intro/install/

## Install
Add repositories:

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
Create namespace
```shell
kubectl create ns workspace-ns
```

Install ingress controller
```shell
 helm repo update && helm install nginx ingress-nginx/ingress-nginx --namespace workspace-ns -f deploy/nginx-ingress.yaml
```


Apply manifests
```shell
kubectl apply -f deploy
```

Update hosts file
```
<minikube ip> auth.arch.homework backend.arch.homework
```

## Postman collection
https://www.postman.com/material-geoscientist-42602158/public-projects/folder/6q0hke2/process-user-registration