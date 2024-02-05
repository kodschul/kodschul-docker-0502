# Kubernetes: Betrieb und Konfiguration
In diesem Dokument findest du Beispiele für den Betrieb von Kubernetes (K8s), die Erstellung von Netzwerken, die DNS-Konfiguration, Kubernetes Role-based Access Control (RBAC), Services und Load Balancing sowie die automatische Skalierung.

## Betrieb von Kubernetes
## Kubernetes-Cluster erstellen
```bash
# Minikube verwenden, um ein lokales Kubernetes-Cluster zu starten
minikube start
```
## Cluster-Informationen anzeigen#
```bash
# Kubernetes-Cluster-Informationen anzeigen
kubectl cluster-info
```

## Netzwerke erstellen
Benutzerdefiniertes Netzwerk erstellen
```bash
# Benutzerdefiniertes Kubernetes-Netzwerk erstellen
kubectl apply -f benutzerdefiniertes-netzwerk.yaml
```

## DNS-Konfiguration
DNS-Namen in Containern verwenden
```bash
# Beispiel-Pod mit DNS-Konfiguration
apiVersion: v1
kind: Pod
metadata:
  name: mein-pod
spec:
  containers:
  - name: mein-container
    image: nginx
```

## Kubernetes Role-based Access Control (RBAC)
RBAC-Rolle erstellen
```bash
# Beispiel-RBAC-Rolle für Anwendungen
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: anwendungsrolle
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

## Services und Load Balancing
Service für Anwendungen erstellen
```bash
# Beispiel-Service für eine Anwendung
apiVersion: v1
kind: Service
metadata:
  name: meine-anwendung-service
spec:
  selector:
    app: meine-anwendung
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

## Automatische Skalierung
Automatische Skalierung für Deployments konfigurieren
```bash
# Beispiel-Deployment mit automatischer Skalierung
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meine-anwendung-deployment
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
        image: meine-anwendung:latest
  autoscaling:
    horizontalPodAutoscaler:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: meine-anwendung-deployment
      minReplicas: 2
      maxReplicas: 5
      targetCPUUtilizationPercentage: 80
```

Diese Beispiele dienen als Grundlage für die Präsentation von Betriebsaspekten in Kubernetes, der Erstellung von Netzwerken, der DNS-Konfiguration, RBAC, Services, Load Balancing und der automatischen Skalierung. Passe die Konfigurationen und Befehle nach Bedarf an und betone die spezifischen Aspekte von Kubernetes, die für deine Präsentation relevant sind.