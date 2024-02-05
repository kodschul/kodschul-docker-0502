# Kubernetes Einführung: Pods erstellen, verändern und verwalten

## Ziel
In diesen Übungen lernst du, wie du Pods erstellst, konfigurierst und verwaltest, die die kleinste bereitstellbare Einheit in Kubernetes darstellen.

## Voraussetzungen
- Kubernetes ist auf deinem Computer installiert (siehe vorherige Übungen).

## Aufgaben

### 1. Pod erstellen
Erstelle einen einfachen Pod mit einem NGINX-Container:

### 2. Pod-Konfiguration anzeigen
Zeige die Konfiguration des erstellten Pods an:

### 3. Pod-Logs anzeigen
Zeige die Logs des Pods an, um zu überprüfen, ob der NGINX-Container gestartet ist:

### 4. Pod in einen interaktiven Modus versetzen
Starte einen temporären interaktiven Container im Pod:
```bash
kubectl exec -it mein-nginx-pod -- /bin/bash
```

### 5. Pod aktualisieren
Aktualisiere die Image-Version des NGINX-Containers im Pod:
```bash
kubectl set image pod mein-nginx-pod nginx=nginx:1.19
```

### 6. Umgebungsvariablen in einem Pod
Erstelle einen Pod mit Umgebungsvariablen:

### 7. Ressourcenbegrenzung für einen Pod
Erstelle einen Pod mit begrenzten Ressourcen (CPU und Speicher):

### 8. Pod löschen
Lösche einen nicht mehr benötigten Pod: