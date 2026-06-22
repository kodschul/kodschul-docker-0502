# Übung: Kubernetes Deployments, Services und ConfigMaps

**Zeit:** 30 min

---

## Aufgabe 1 – Deployment mit Service (15 min)

Erstelle zwei YAML-Dateien:

**deployment.yml** – Deployment für `nginx:alpine`:

- Name: `webapp`
- 2 Replicas
- Label: `app=webapp`
- Resource requests: 32Mi / 50m
- Readiness Probe auf `/` Port 80

**service.yml** – NodePort-Service:

- Name: `webapp-svc`
- Selector: `app=webapp`
- Port 80 → NodePort 30080

```bash
kubectl apply -f deployment.yml
kubectl apply -f service.yml

kubectl get pods -l app=webapp
kubectl get svc webapp-svc

# Teste den Zugang
curl http://localhost:30080
```

---

## Aufgabe 2 – ConfigMap einbinden (10 min)

Erstelle eine `configmap.yml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
data:
  APP_COLOR: "blue"
  APP_MESSAGE: "Hello from ConfigMap!"
```

Erweitere das Deployment: Binde alle Werte aus `webapp-config` als Umgebungsvariablen ein (`envFrom`).

```bash
kubectl apply -f configmap.yml
kubectl apply -f deployment.yml   # mit envFrom

# Überprüfe ob Variablen im Container ankommen
kubectl exec deploy/webapp -- printenv | grep APP_
```

---

## Aufgabe 3 – Rolling Update (5 min)

```bash
# Update auf neue Image-Version
kubectl set image deployment/webapp nginx=nginx:1.25-alpine

# Update live verfolgen
kubectl rollout status deployment/webapp

# Rollback
kubectl rollout undo deployment/webapp

# Welche Version läuft jetzt?
kubectl describe deployment webapp | grep Image
```
