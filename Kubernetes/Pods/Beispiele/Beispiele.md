# Kubernetes Pods: Erstellen, Verändern und Verwalten
In Kubernetes sind Pods die kleinste Einheit, in der Container laufen. Hier sind Beispiele zum Erstellen, Verändern und Verwalten von Pods sowie zur Pod-Konfiguration.

## Pods erstellen
Einfachen Pod erstellen
```bash
# Beispiel-Pod
apiVersion: v1
kind: Pod
metadata:
  name: mein-erster-pod
spec:
  containers:
  - name: mein-container
    image: nginx:latest

# Pod erstellen
kubectl apply -f mein-erster-pod.yaml
```

## Pods verändern
Ressourcen eines laufenden Pods ändern
```bash
# Ressourcen eines Pods ändern
kubectl edit pod mein-erster-pod
```

Container in einem Pod hinzufügen
```bash
# Container zu einem laufenden Pod hinzufügen
kubectl exec -it mein-erster-pod -- /bin/sh
```

## Pods verwalten
Laufende Pods anzeigen
```bash
# Alle laufenden Pods anzeigen
kubectl get pods
```

Pod-Logs anzeigen
```bash
# Logs eines Pods anzeigen
kubectl logs mein-erster-pod
```

Pod löschen
```bash
# Pod löschen
kubectl delete pod mein-erster-pod
```

## Pod-Konfiguration
Umgebungsvariablen in einem Pod verwenden
```bash
# Beispiel-Pod mit Umgebungsvariablen
apiVersion: v1
kind: Pod
metadata:
  name: mein-pod-mit-umgebungsvariablen
spec:
  containers:
  - name: mein-container
    image: nginx:latest
    env:
    - name: MEINE_UMGEBUNGSVARIABLE
      value: "Hallo, Kubernetes!"
```

Ressourcenbeschränkungen für einen Pod setzen
```bash
# Beispiel-Pod mit Ressourcenbeschränkungen
apiVersion: v1
kind: Pod
metadata:
  name: mein-pod-mit-ressourcenbeschraenkungen
spec:
  containers:
  - name: mein-container
    image: nginx:latest
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "64Mi"
        cpu: "250m"
```

Diese Beispiele dienen als Einführung in die Erstellung, Veränderung und Verwaltung von Kubernetes Pods sowie zur Pod-Konfiguration. Passe die Konfigurationen und Befehle nach Bedarf an und betone die spezifischen Aspekte von Pods, die für deine Präsentation relevant sind.