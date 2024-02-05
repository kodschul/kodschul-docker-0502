# Kubernetes Deployments und ReplicaSets: Erstellen, Updates und Rollbacks
In Kubernetes werden Deployments verwendet, um ReplicaSets und somit Pods zu managen. Hier sind Beispiele zum Erstellen von Deployments, Durchführen von Updates und Rollbacks.

## Deployments erstellen
Einfaches Deployment erstellen

```bash
# Beispiel-Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mein-erstes-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: meine-anwendung
  template:
    metadata:
      labels:
        app: meine-anwendung
    spec:
      containers:
      - name: meine-anwendung-container
        image: nginx:latest

# Deployment erstellen
kubectl apply -f mein-erstes-deployment.yaml
```

## Updates durchführen
Container-Image aktualisieren
```bash
# Aktualisiertes Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mein-erstes-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: meine-anwendung
  template:
    metadata:
      labels:
        app: meine-anwendung
    spec:
      containers:
      - name: meine-anwendung-container
        image: nginx:1.21.1

# Deployment aktualisieren
kubectl apply -f aktualisiertes-deployment.yaml
```

## Rollbacks durchführen
Rollback zu einer vorherigen Version
```bash
# Historie von Rollouts anzeigen
kubectl rollout history deployment mein-erstes-deployment

# Rollback zu einer vorherigen Version
kubectl rollout undo deployment mein-erstes-deployment
```

Diese Beispiele sollen als Einführung in die Erstellung von Kubernetes Deployments, das Durchführen von Updates und Rollbacks dienen. Passe die Konfigurationen und Befehle nach Bedarf an und betone die spezifischen Aspekte von Deployments, die für deine Präsentation relevant sind.