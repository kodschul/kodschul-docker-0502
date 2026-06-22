# Lösung: Kubernetes Setup und Arbeitsumgebung

---

## Aufgabe 1

```bash
kubectl config view
# apiVersion: v1
# clusters:
# - cluster:
#     server: https://127.0.0.1:6443
#   name: docker-desktop
# contexts:
# - context:
#     cluster: docker-desktop
#     user: docker-desktop
#   name: docker-desktop
# current-context: docker-desktop

kubectl config get-contexts
# CURRENT   NAME             CLUSTER          AUTHINFO
# *         docker-desktop   docker-desktop   docker-desktop

kubectl config current-context
# docker-desktop

kubectl create namespace kurs
kubectl config set-context --current --namespace=kurs
kubectl config view --minify | grep namespace
#     namespace: kurs

kubectl config set-context --current --namespace=default
```

---

## Aufgabe 2

```bash
kubectl create namespace dev
kubectl create namespace staging

kubectl run web-dev --image=nginx:alpine -n dev
kubectl run web-staging --image=nginx:alpine -n staging

kubectl get pods -n dev
# NAME      READY   STATUS    RESTARTS   AGE
# web-dev   1/1     Running   0          5s

kubectl get pods -n staging
# NAME          READY   STATUS    RESTARTS   AGE
# web-staging   1/1     Running   0          3s

kubectl get pods -A
# dev       web-dev       1/1     Running   0
# staging   web-staging   1/1     Running   0

kubectl get pods
# → leer! (default namespace)  ← Antwort: Nein, -n dev nötig

kubectl delete namespace dev staging
# → löscht alle Ressourcen in diesen Namespaces mit
```

---

## Aufgabe 3

```bash
kubectl create deployment nginx-demo --image=nginx:alpine --replicas=2
# deployment.apps/nginx-demo created

kubectl scale deployment nginx-demo --replicas=3
# deployment.apps/nginx-demo scaled

kubectl get pods -w
# nginx-demo-abc   1/1   Running   0   5s
# nginx-demo-def   1/1   Running   0   5s
# nginx-demo-xyz   0/1   Pending   0   1s
# nginx-demo-xyz   1/1   Running   0   3s

kubectl describe deployment nginx-demo
# Replicas: 3 desired | 3 updated | 3 total | 3 available

kubectl port-forward deployment/nginx-demo 8080:80 &
curl http://localhost:8080
# <!DOCTYPE html>... nginx welcome page

kubectl delete deployment nginx-demo
```
