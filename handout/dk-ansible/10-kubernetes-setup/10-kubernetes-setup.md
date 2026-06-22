# 10 – Kubernetes: Aufbau der Arbeitsumgebung

**Block:** 90 min | **Tag 3**

---

## Lab 10.1 – Arbeitsbereich und Konfiguration

### kubeconfig – wie kubectl weiß mit welchem Cluster es spricht

```bash
# kubeconfig anzeigen
kubectl config view
kubectl config view --minify   # nur aktiver Kontext

# Dateipfad
cat ~/.kube/config

# Struktur der kubeconfig
# clusters:    → welche Cluster gibt es
# users:       → Credentials für Cluster
# contexts:    → Kombination aus Cluster + User + Namespace
# current-context: → aktiv genutzter Kontext
```

### Contexts verwalten

```bash
# Alle Contexts anzeigen
kubectl config get-contexts

# Aktuellen Context anzeigen
kubectl config current-context

# Context wechseln
kubectl config use-context docker-desktop
kubectl config use-context minikube

# Namespace im Context setzen (kein -n mehr nötig)
kubectl config set-context --current --namespace=production

# kubectx + kubens (komfortablere Tools)
brew install kubectx
kubectx                    # Contexts anzeigen und wechseln
kubens                     # Namespaces anzeigen und wechseln
kubens production          # Namespace wechseln
```

### Namespaces einrichten

```bash
# Namespace anlegen
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# YAML-Variante
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
EOF

# Ressourcen in Namespace anzeigen
kubectl get all -n production
kubectl get all --all-namespaces   # oder: -A
```

---

## Lab 10.2 – Installationsoptionen und Setup

### Docker Desktop Kubernetes

```bash
# Einschalten: Docker Desktop → Settings → Kubernetes → Enable Kubernetes
# → Automatisch: kubectl konfiguriert, minikube-ähnlicher lokaler Cluster

kubectl config get-contexts
# docker-desktop   docker-desktop   docker-desktop   default

kubectl get nodes
# NAME             STATUS   ROLES           AGE
# docker-desktop   Ready    control-plane   1m
```

### minikube

```bash
# Installation
brew install minikube

# Cluster starten
minikube start
minikube start --driver=docker --cpus=2 --memory=4g

# Status
minikube status
minikube dashboard   # Web-UI im Browser

# Add-ons aktivieren
minikube addons list
minikube addons enable metrics-server
minikube addons enable ingress

# Cluster löschen
minikube delete
```

### kind (Kubernetes in Docker)

```bash
# Installation
brew install kind

# Cluster aus YAML erstellen (Multi-Node)
cat <<EOF > kind-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

kind create cluster --name kurs --config kind-config.yml
kind get clusters
kind delete cluster --name kurs
```

| Tool               | Nodes          | Use Case                  | Ressourcen  |
| ------------------ | -------------- | ------------------------- | ----------- |
| Docker Desktop K8s | 1 (all-in-one) | Einfachster Einstieg      | gering      |
| minikube           | 1 (oder mehr)  | Lokal, Add-ons, Dashboard | mittel      |
| kind               | Multi-Node     | CI/CD, Multi-Node testen  | gering      |
| k3d                | Multi-Node     | Schnell, k3s-basiert      | sehr gering |

---

## Lab 10.3 – Das Kubernetes Dashboard

### Dashboard installieren

```bash
# Offizielles Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# ServiceAccount für Zugang erstellen
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Token generieren
kubectl -n kubernetes-dashboard create token admin-user

# Proxy starten
kubectl proxy
# → http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### kubectl Port-Forward als Alternative

```bash
# Direkt einen Service weiterleiten
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443
# → https://localhost:8443
```

### Alternativ: k9s (Terminal-basiertes Dashboard)

```bash
brew install k9s
k9s                    # startet direkt
k9s -n production      # bestimmter Namespace
# Shortcuts: : für Command-Mode, / für Suche, d für Describe, l für Logs
```

---

## Zusammenfassung

```
kubectl konfigurieren
└── ~/.kube/config → Cluster, Users, Contexts
└── kubectl config use-context <name>
└── kubectx / kubens für komfortablen Wechsel

Lokale Cluster
├── Docker Desktop  → einfachster Start
├── minikube        → Add-ons, Dashboard, Multi-Node
└── kind            → Multi-Node, CI-freundlich

Monitoring
├── kubectl dashboard → offizielles Web-UI
└── k9s              → Terminal-Dashboard
```
