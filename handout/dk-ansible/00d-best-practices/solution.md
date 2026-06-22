# Lösung: Best Practices

---

## Aufgabe 1 – Dockerfile

```dockerfile
# Stage 1: Build
FROM node:20.14-alpine3.20 AS builder

WORKDIR /app

# Erst package.json → npm install wird gecacht
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20.14-alpine3.20 AS production

WORKDIR /app

# Non-root User
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Nur Production-Dependencies
COPY package*.json ./
RUN npm ci --only=production

# Build-Artefakt aus Stage 1
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/server.js .

USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
```

```
# .dockerignore
node_modules
.git
*.log
.env
dist
coverage
.DS_Store
```

**Was wurde verbessert:**

- `package*.json` vor `COPY . .` → npm install nur bei Dependency-Änderungen neu
- Multi-Stage → kein Build-Tool im Produktions-Image
- `node:20.14-alpine3.20` → konkrete Version, reproduzierbar
- Non-root User → kein `root` im Container
- `.dockerignore` → keine `node_modules` vom Host mitkopiert

---

## Aufgabe 2 – Kubernetes Deployment

```bash
# Secret anlegen (einmalig, nicht ins Git committen)
kubectl create secret generic db-credentials \
  --from-literal=password=geheim123
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
    version: "1.0.0"
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
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: password
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
```

**Was wurde ergänzt:**

- `resources.requests` + `limits` → Scheduler weiß wo er den Pod platzieren kann, Node ist vor Überlastung geschützt
- `readinessProbe` → Traffic erst wenn Container bereit (wichtig für Rolling Updates)
- `livenessProbe` → automatischer Neustart bei Deadlock
- Passwort aus `secretKeyRef` → kein Klartext im YAML
- Labels erweitert → bessere Filterbarkeit mit `kubectl get`
