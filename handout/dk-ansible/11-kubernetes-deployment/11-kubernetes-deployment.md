# 11 – Kubernetes: Ressourcen und flexibles Deployment

**Block:** 90 min | **Tag 3**

---

## Lab 11.1 – Pods: Konzept und Architektur

### Pod vs. Container

```
Pod
├── eigene IP-Adresse
├── eigene Volumes
├── ein oder mehrere Container
│   ├── Container A (App)
│   └── Container B (Sidecar: Logging/Proxy)
└── alle Container teilen: Netzwerk + localhost
```

### Pod-Manifest

```yaml
# pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    tier: backend
  annotations:
    description: "Backend-Pod für myapp"
spec:
  containers:
    - name: app
      image: nginx:alpine
      ports:
        - containerPort: 80
          name: http
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "200m"
      env:
        - name: APP_ENV
          value: "production"
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 10
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 15
        periodSeconds: 20
```

### Multi-Container Pod (Sidecar Pattern)

```yaml
spec:
  containers:
    - name: app
      image: myapp:1.0
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/app

    - name: log-forwarder
      image: fluentd:v1.16
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/app

  volumes:
    - name: shared-logs
      emptyDir: {}
```

---

## Lab 11.2 – Deployment mit Labels und Selektoren

### Deployment-Manifest

```yaml
# deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: default
  labels:
    app: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend # muss zu template.labels passen!
  template:
    metadata:
      labels:
        app: frontend
        version: "2.1.0"
        tier: web
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "32Mi"
              cpu: "50m"
            limits:
              memory: "64Mi"
              cpu: "100m"
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
```

### Labels und Selektoren

```bash
# Nach Labels filtern
kubectl get pods -l app=frontend
kubectl get pods -l app=frontend,tier=web
kubectl get pods -l 'version in (2.1.0, 2.0.0)'
kubectl get pods -l 'version notin (1.0.0)'

# Labels anzeigen
kubectl get pods --show-labels

# Label hinzufügen / ändern
kubectl label pod mypod env=production
kubectl label pod mypod env=staging --overwrite

# Label entfernen
kubectl label pod mypod env-
```

### Rolling Update

```bash
# Deployment updaten
kubectl set image deployment/frontend nginx=nginx:1.25-alpine

# Update-Status beobachten
kubectl rollout status deployment/frontend

# Pause und Resume
kubectl rollout pause deployment/frontend
kubectl rollout resume deployment/frontend

# Rollback
kubectl rollout undo deployment/frontend
kubectl rollout undo deployment/frontend --to-revision=2
kubectl rollout history deployment/frontend
```

### Update-Strategie konfigurieren

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1 # max 1 zusätzlicher Pod
      maxUnavailable: 0 # immer volle Kapazität
```

---

## Lab 11.3 – Services

### Service-Typen

| Typ            | Beschreibung                         | Wann nutzen                      |
| -------------- | ------------------------------------ | -------------------------------- |
| `ClusterIP`    | Nur intern im Cluster erreichbar     | Service-zu-Service-Kommunikation |
| `NodePort`     | Auf jedem Node über Port 30000-32767 | Lokales Testing                  |
| `LoadBalancer` | Externer Load Balancer (Cloud)       | Produktionszugang                |
| `ExternalName` | DNS-Alias auf externe URL            | Externe Services einbinden       |

### Service-Manifest

```yaml
# service.yml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  type: ClusterIP # Standard
  selector:
    app: frontend # wählt alle Pods mit diesem Label
  ports:
    - port: 80 # Service-Port
      targetPort: 80 # Container-Port
      name: http
```

```yaml
# NodePort für lokalen Zugang
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080 # 30000-32767, optional (oder zufällig)
```

### Service Discovery

```bash
# DNS-Name eines Services im Cluster:
# <service-name>.<namespace>.svc.cluster.local

# Beispiele:
# frontend-svc.default.svc.cluster.local
# backend-svc.production.svc.cluster.local

# Kurzform innerhalb desselben Namespace:
# frontend-svc

# DNS testen
kubectl run dns-test --rm -it --image=alpine --restart=Never -- \
  nslookup frontend-svc
```

### ConfigMap und Secret

```yaml
# configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  app.properties: |
    server.port=8080
    spring.datasource.url=jdbc:postgresql://db:5432/myapp
```

```yaml
# Einbinden als ENV
envFrom:
  - configMapRef:
      name: app-config

# Einbinden als Datei (Volume)
volumes:
  - name: config-vol
    configMap:
      name: app-config
volumeMounts:
  - name: config-vol
    mountPath: /etc/config
```

### Port-Forward für lokales Testen

```bash
# Service lokal erreichbar machen
kubectl port-forward svc/frontend-svc 8080:80
# → http://localhost:8080

# Auf bestimmtes Pod-Port-Forward
kubectl port-forward pod/frontend-abc123 8080:80
```

---

## Zusammenfassung

```
Pod
├── kleinste Einheit, eigene IP
└── Liveness + Readiness Probe → Self-Healing

Deployment
├── verwaltet Pods über ReplicaSet
├── Rolling Update: maxSurge / maxUnavailable
└── Rollback: kubectl rollout undo

Labels + Selektoren
├── Pods filtern und gruppieren
└── Service → Deployment-Verbindung

Service
├── ClusterIP  → intern
├── NodePort   → extern (Testing)
└── LoadBalancer → extern (Cloud/Prod)

ConfigMap / Secret
└── Konfiguration vom Code trennen
```
