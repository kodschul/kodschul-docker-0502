# Zusammenfassung zu Pods in Kubernetes
## Einführung
In Kubernetes sind Pods die kleinste ausführbare Einheit. Ein Pod ist eine Gruppe von einem oder mehreren Containern, die auf einem gemeinsamen Netzwerk- und Speicherplatz laufen. Sie repräsentieren die grundlegende Ausführungseinheit auf einem Kubernetes-Cluster.

## Schritte zur Arbeit mit Pods
## 1. Pods erstellen
Um einen Pod zu erstellen, benötigst du eine YAML-Datei, die die Pod-Konfiguration definiert. Hier ist ein einfaches Beispiel:
```bash
apiVersion: v1
kind: Pod
metadata:
  name: mein-erster-pod
spec:
  containers:
  - name: mein-container
    image: nginx:latest
```

Verwende den Befehl kubectl create:
```bash
kubectl create -f mein-pod.yaml
```

## 2. Pods anzeigen
Um alle Pods im Cluster anzuzeigen, verwende:
```bash
kubectl get pods
```

## 3. Pod-Konfiguration aktualisieren
Ändere die YAML-Datei und aktualisiere den Pod mit:
```bash
kubectl apply -f mein-aktualisierter-pod.yaml
```

## 4. Pod-Logs anzeigen
Siehe die Logs eines Containers in einem Pod:
```bash
kubectl logs mein-erster-pod
```

## 5. Interaktive Shell in einen Pod öffnen
Öffne eine interaktive Shell in einem laufenden Pod:
```bash
kubectl exec -it mein-erster-pod -- /bin/bash
```

## 6. Ressourcenbedarf für Pods festlegen
Definiere Ressourcenanforderungen in der Pod-Konfiguration:
```bash
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

## 7. Pod löschen
Entferne einen Pod:
```bash
kubectl delete pod mein-erster-pod
```

Die Arbeit mit Pods in Kubernetes erfordert die Definition von YAML-Konfigurationsdateien, um ihre Eigenschaften und das gewünschte Verhalten zu spezifizieren. Diese YAML-Dateien können dann verwendet werden, um Pods zu erstellen, zu aktualisieren oder zu löschen.