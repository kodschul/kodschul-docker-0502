# Minikube: Einführung und Grundlagen

## Ziel
Diese Übungen führen dich in die Verwendung von Minikube ein, einer Lösung für die lokale Bereitstellung von Kubernetes-Clustern. Du wirst Minikube starten, einfache Kubernetes-Ressourcen erstellen und das Minikube-Dashboard verwenden.

## Voraussetzungen
- Docker ist auf deinem Computer installiert.

## Aufgaben

### 1. Minikube Installation
Installiere Minikube gemäß den Anweisungen in der [Minikube-Dokumentation](https://minikube.sigs.k8s.io/docs/start/).

### 2. Minikube starten
Starte Minikube und überprüfe den Status:
```bash
minikube start
minikube status
```

### 3. Minikube Dashboard
Öffne das Minikube-Dashboard in deinem Standard-Browser:

### 7. Minikube Stoppen
Stoppe Minikube, wenn du die Testumgebung nicht mehr benötigst:

### 8. Minikube SSH-Befehl
Verwende den Befehl `minikube ssh`, um eine SSH-Verbindung zur Minikube-VM herzustellen:

### 9. Erkunden der Minikube-VM
Einmal in der Minikube-VM-Shell kannst du verschiedene Befehle verwenden, um die Umgebung zu erkunden:

Zeige Informationen zur VM an:
```bash
uname -a
```

Überprüfe die Netzwerkkonfiguration:
```bash
ifconfig
```

Schau dir die laufenden Prozesse an:
```bash
ps aux
```

### 10. Anwendungsbeispiel
Ein einfaches Anwendungsbeispiel in der Minikube-VM:

Wechsle zum Verzeichnis, in dem Minikube das Kubernetes-Konfigurationsverzeichnis speichert:
```bash
cd /etc/kubernetes
```

Zeige den Inhalt des Verzeichnisses an:
```bash
ls
```

Verlasse die SSH-Sitzung:
```bash
exit
```

### Nützliche Ressourcen
[Minikube Dokumentation](https://minikube.sigs.k8s.io/docs/)
[Minikube Dokumentation - minikube ssh](https://minikube.sigs.k8s.io/docs/commands/ssh/)