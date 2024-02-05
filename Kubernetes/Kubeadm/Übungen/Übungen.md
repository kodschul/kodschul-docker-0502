# Kubernetes Installation mit kubeadm auf dem eigenen Rechner

## Ziel
In diesen Übungen lernst du, Kubernetes mit kubeadm auf deinem eigenen Rechner zu installieren. Kubeadm ist ein Tool, das die Bereitstellung von Kubernetes-Clustern vereinfacht.

## Voraussetzungen
- Docker ist auf deinem Computer installiert.

## Aufgaben

### 1. kubeadm, kubectl und kubelet installieren
Installiere die Kubernetes-Komponenten kubeadm, kubectl und kubelet auf deinem Rechner:

### 2. Kubernetes-Cluster mit kubeadm initialisieren
Initialisiere den Master-Node des Kubernetes-Clusters:
```bash
sudo kubeadm init
```

### 3. kubectl-Konfiguration einrichten
Richte die kubectl-Konfiguration für deinen Benutzer ein:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 4. Cluster-Status überprüfen
Überprüfe den Status des Kubernetes-Clusters:
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

### 5. Flannel CNI-Plugin installieren
Installiere das Container Network Interface (CNI)-Plugin Flannel, um die Kommunikation zwischen den Pods im Cluster zu ermöglichen:
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### 6. Cluster deinitialisieren
Um den Kubernetes-Cluster zu deinitialisieren (Achtung: Dies löscht alle Clusterdaten):
```bash
sudo kubeadm reset
```