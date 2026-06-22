# 09 – Kubernetes: Einführung und Grundlagen

**Block:** 90 min | **Tag 2**

---

## Lab 9.1 – Warum Kubernetes?

### Das Problem mit einzelnen Containern in Produktion

```
docker run myapp:1.0     → läuft auf einem Server
                           ↓
                         Server fällt aus → App weg
                         Traffic steigt   → kein Auto-Scaling
                         Update nötig     → Downtime
                         10 Server        → 10× manuell deployen
```

### Was Kubernetes löst

| Problem              | Kubernetes-Lösung                                 |
| -------------------- | ------------------------------------------------- |
| Server fällt aus     | Pod wird automatisch neu gestartet (Self-Healing) |
| Hoher Traffic        | Horizontal Pod Autoscaler (HPA)                   |
| Update ohne Downtime | Rolling Update mit Readiness-Check                |
| Viele Server         | Cluster-Scheduler verteilt Pods automatisch       |
| Konfiguration        | ConfigMaps und Secrets – zentral, deklarativ      |

> **Analogie:** Docker ist wie ein einzelnes Schiff. Kubernetes ist der Hafenkapitän, der Hunderte Schiffe koordiniert, Routen plant und bei Problemen eingreift.

---

## Lab 9.2 – Kubernetes-Eigenschaften im Überblick

### Deklaratives Modell

```yaml
# "Ich möchte 3 Replikas von myapp laufen haben"
spec:
  replicas: 3
```

Kubernetes sorgt dafür, dass immer 3 Replicas laufen – egal was passiert. Das ist der **gewünschte Zustand** (Desired State) vs. **aktueller Zustand** (Current State).

```
Desired State: replicas: 3
Current State: replicas: 2  (ein Pod gecrasht)
         ↓
Controller: startet neuen Pod → Current State = 3
```

### Kubernetes-Eigenschaften

- **Self-Healing**: Ausgefallene Pods werden neu gestartet
- **Auto-Scaling**: Pods je nach Last skalieren
- **Rolling Updates**: Zero-Downtime-Deployments
- **Service Discovery**: Pods finden sich über DNS
- **Load Balancing**: Traffic wird auf Pods verteilt
- **Secret Management**: Passwörter sicher verwalten
- **Storage Orchestration**: Volumes automatisch provisionieren

---

## Lab 9.3 – Architektur und Hauptkomponenten

### Cluster-Aufbau

```
Kubernetes Cluster
├── Control Plane (Master)
│   ├── API Server        → Einziger Einstiegspunkt (kubectl, Dashboard)
│   ├── etcd              → Verteilte Key-Value-DB (Cluster-State)
│   ├── Scheduler         → Entscheidet welcher Node einen Pod bekommt
│   └── Controller Manager → Überwacht und korrigiert Desired State
│
└── Worker Nodes (1..n)
    ├── kubelet           → Agent auf jedem Node, kommuniziert mit API Server
    ├── kube-proxy        → Netzwerk-Regeln für Services
    └── Container Runtime → containerd (führt Container aus)
```

### Die wichtigsten Kubernetes-Ressourcen

```
Pod
└── kleinste deploybare Einheit
└── ein oder mehrere Container
└── teilen sich Netzwerk + Storage

Deployment
└── verwaltet ReplicaSet → verwaltet Pods
└── Rolling Updates, Rollbacks
└── Desired State: "immer X Pods dieser Version"

Service
└── stabiler DNS-Name + IP für eine Gruppe von Pods
└── Load Balancing über alle Pods

ConfigMap / Secret
└── Konfiguration von App trennen
└── in Pods als ENV oder Volume eingebunden

Namespace
└── logische Trennung von Ressourcen
└── z.B. production / staging / monitoring
```

### Ressourcen-Hierarchie

```
Cluster
└── Namespace: production
    ├── Deployment: frontend
    │   └── ReplicaSet
    │       ├── Pod: frontend-abc123
    │       └── Pod: frontend-def456
    ├── Deployment: backend
    │   └── ReplicaSet
    │       └── Pod: backend-xyz789
    ├── Service: frontend-svc (→ Port 80)
    ├── Service: backend-svc  (→ Port 8080)
    ├── ConfigMap: app-config
    └── Secret: db-credentials
```

### kubectl – die wichtigsten Befehle

```bash
# Cluster-Info
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide    # mit IP, OS, Version

# Ressourcen anzeigen
kubectl get pods
kubectl get pods -A          # alle Namespaces
kubectl get pods -n kube-system  # bestimmter Namespace
kubectl get all              # alles im aktuellen Namespace

# Details
kubectl describe pod mypod
kubectl describe node mynode
kubectl describe deployment myapp

# Logs
kubectl logs mypod
kubectl logs -f mypod        # live follow
kubectl logs mypod -c container-name   # multi-container pod

# In Pod einsteigen
kubectl exec -it mypod -- bash
kubectl exec -it mypod -- sh    # wenn kein bash

# Ressourcen erstellen/aktualisieren
kubectl apply -f deployment.yml
kubectl apply -f ./k8s/         # ganzes Verzeichnis

# Ressourcen löschen
kubectl delete -f deployment.yml
kubectl delete pod mypod
kubectl delete deployment myapp
```

---

## Zusammenfassung

```
Kubernetes
├── Orchestriert Container auf einem Cluster
├── Deklaratives Modell: Desired State = was du willst
└── Controller sorgt für: Current State → Desired State

Architektur
├── Control Plane: API Server, etcd, Scheduler, Controller
└── Worker Nodes:  kubelet, kube-proxy, containerd

Kernressourcen
├── Pod         → kleinste Einheit
├── Deployment  → verwaltet Pods + Rolling Updates
├── Service     → stabiler Endpunkt
├── ConfigMap   → Konfiguration
└── Secret      → sensible Daten
```
