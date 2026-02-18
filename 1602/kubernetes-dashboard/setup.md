```
helm repo remove kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes-retired.github.io/dashboard/
helm repo update
```

```
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
