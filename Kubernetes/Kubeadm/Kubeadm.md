# Zusammenfassung zu kubeadm
## Einführung
Kubeadm ist ein Befehlszeilentool, das die Einrichtung von Kubernetes-Clustern vereinfacht. Es ermöglicht eine schnelle Bereitstellung von Kubernetes auf verschiedenen Plattformen. Kubeadm ist Teil des Kubernetes-Projekts und fokussiert sich auf einfache und robuste Möglichkeiten, um Cluster zu initialisieren und Worker-Nodes hinzuzufügen.

## Einführung
Kubeadm ist ein Befehlszeilentool, das die Einrichtung von Kubernetes-Clustern vereinfacht. Es ermöglicht eine schnelle Bereitstellung von Kubernetes auf verschiedenen Plattformen. Kubeadm ist Teil des Kubernetes-Projekts und fokussiert sich auf einfache und robuste Möglichkeiten, um Cluster zu initialisieren und Worker-Nodes hinzuzufügen.

## Schritte zur Verwendung von kubeadm
## 1. Kubernetes Cluster initialisieren
Verwende den folgenden Befehl, um ein neues Kubernetes-Cluster mit kubeadm zu initialisieren:
```bash
kubeadm init
```
Nach dem erfolgreichen Abschluss dieses Befehls erhältst du einen Befehl zum Hinzufügen von Worker-Nodes zum Cluster. Dieser Befehl enthält einen Token und den Adresse des Kubernetes-Masters.

## 2. Worker-Nodes hinzufügen
Führe den bereitgestellten Befehl auf den Worker-Nodes aus, um sie dem Cluster hinzuzufügen. Beispiel:
```bash
kubeadm join <Master-Node-Adresse>:<Port> --token <Token> --discovery-token-ca-cert-hash <Hash-Wert>
```

## 3. Konfiguration für den lokalen Gebrauch holen
Nachdem der Cluster initialisiert wurde, lade die Kubernetes-Konfigurationsdatei für den lokalen Gebrauch herunter:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 4. CNI-Netzwerkplugin installieren
Kubernetes benötigt ein Container-Netzwerk-Interface (CNI). Wähle ein CNI-Plugin aus und installiere es. Zum Beispiel Flannel:
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## Nützliche Befehle
Cluster-Status anzeigen:
```bash
kubectl cluster-info
```
Nodes im Cluster anzeigen:
```bash
kubectl get nodes
```
Kubernetes Dashboard installieren:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```

Kubeadm bietet eine einfache Methode zur Bereitstellung von Kubernetes-Clustern und ist besonders für Test- und Entwicklungsumgebungen geeignet. Es automatisiert viele der manuellen Schritte, die für die Einrichtung eines Kubernetes-Clusters erforderlich sind, und erleichtert somit die Arbeit mit Kubernetes erheblich.