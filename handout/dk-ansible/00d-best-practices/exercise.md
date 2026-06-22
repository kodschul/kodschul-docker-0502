# Übung: Best Practices

**Zeit:** 30 min

---

## Aufgabe 1 – Dockerfile refactorn (15 min)

Das folgende Dockerfile hat mehrere Probleme. Finde und behebe sie:

```dockerfile
FROM node:latest

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

EXPOSE 3000

CMD ["node", "server.js"]
```

**Probleme zu finden:**

- Falsche Layer-Reihenfolge (Cache-Invalidierung)
- Kein Multi-Stage Build (dev-Dependencies landen im Image)
- Kein `.dockerignore` → `node_modules` wird mitkopiert
- `latest`-Tag (nicht reproduzierbar)
- Läuft als root

Erstelle ein verbessertes Dockerfile und eine `.dockerignore`.

---

## Aufgabe 2 – Kubernetes Deployment absichern (15 min)

Ergänze das folgende Deployment um:

1. Resource Limits
2. Readiness Probe
3. Das Passwort aus einem Secret (nicht direkt im YAML)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: myapp:1.0.0
          ports:
            - containerPort: 8080
          env:
            - name: DB_PASSWORD
              value: "geheim123"
```
