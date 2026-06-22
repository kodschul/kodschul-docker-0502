# Übung: Produktion

**Zeit:** 30 min

---

## Aufgabe 1 – HPA konfigurieren (10 min)

Erstelle einen Horizontal Pod Autoscaler für ein bestehendes Deployment:

```bash
# Deployment anlegen (Basis)
kubectl create deployment load-test \
  --image=nginx:alpine \
  --replicas=1

kubectl expose deployment load-test --port=80
```

Erstelle nun eine `hpa.yml` für das `load-test`-Deployment:

- Minimum: 1 Replica
- Maximum: 5 Replicas
- Skaliere hoch wenn CPU-Auslastung > 60%

```bash
kubectl apply -f hpa.yml
kubectl get hpa
kubectl describe hpa load-test
```

---

## Aufgabe 2 – Rolling Update & Rollback (10 min)

```bash
# Deployment mit Image v1 erstellen
kubectl create deployment rollout-demo \
  --image=nginx:1.24-alpine

# Status prüfen
kubectl rollout status deployment/rollout-demo

# Update auf v2
kubectl set image deployment/rollout-demo \
  nginx=nginx:1.25-alpine

# Update beobachten
kubectl rollout status deployment/rollout-demo

# Revisionshistorie anzeigen
kubectl rollout history deployment/rollout-demo

# Rollback auf die vorherige Version
kubectl rollout undo deployment/rollout-demo

# Prüfen: welche Image-Version läuft jetzt?
kubectl describe deployment rollout-demo | grep Image
```

---

## Aufgabe 3 – Secret sicher einbinden (10 min)

1. Erstelle ein Secret:

```bash
kubectl create secret generic app-secret \
  --from-literal=api_key=super-geheimer-key-123
```

2. Erstelle ein Deployment `secret-demo`, das den Wert als Umgebungsvariable `API_KEY` nutzt:

```yaml
# secret-demo.yml – ergänze den fehlenden secretKeyRef-Block
env:
  - name: API_KEY
    valueFrom:
      # ... hier ergänzen
```

3. Überprüfe ob der Wert im Container ankommt:

```bash
kubectl exec deploy/secret-demo -- printenv API_KEY
```
