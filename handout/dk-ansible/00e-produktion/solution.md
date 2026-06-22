# Lösung: Produktion

---

## Aufgabe 1 – HPA

```yaml
# hpa.yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: load-test
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: load-test
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```

```bash
kubectl apply -f hpa.yml
kubectl get hpa
# NAME        REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS
# load-test   Deployment/load-test   0%/60%    1         5         1
```

> Hinweis: Der HPA benötigt den Metrics Server. In Docker Desktop K8s: `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

---

## Aufgabe 2 – Rolling Update & Rollback

```bash
kubectl create deployment rollout-demo --image=nginx:1.24-alpine
kubectl rollout status deployment/rollout-demo

kubectl set image deployment/rollout-demo nginx=nginx:1.25-alpine
kubectl rollout status deployment/rollout-demo
# Waiting for deployment "rollout-demo" rollout to finish...
# deployment "rollout-demo" successfully rolled out

kubectl rollout history deployment/rollout-demo
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>

kubectl rollout undo deployment/rollout-demo

kubectl describe deployment rollout-demo | grep Image
# Image: nginx:1.24-alpine   ← zurück auf V1
```

---

## Aufgabe 3 – Secret einbinden

```yaml
# secret-demo.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secret-demo
  template:
    metadata:
      labels:
        app: secret-demo
    spec:
      containers:
        - name: app
          image: nginx:alpine
          env:
            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: api_key
```

```bash
kubectl apply -f secret-demo.yml
kubectl exec deploy/secret-demo -- printenv API_KEY
# super-geheimer-key-123
```

> **Wichtig:** Der Secret-Wert erscheint im `printenv`-Output im Klartext – deshalb `kubectl exec` nur mit entsprechenden RBAC-Berechtigungen erlauben.
