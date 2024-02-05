# Docker Einführung: Volumes für persistente Datenspeicherung

## Ziel
In diesen Übungen lernst du, wie du Docker-Volumes für die persistente Datenspeicherung verwendest. Volumes ermöglichen es, Daten zwischen Containern zu teilen und Daten auch nach dem Stoppen von Containern zu erhalten.

## Voraussetzungen
- Docker ist auf deinem Computer installiert (siehe vorherige Übungen).

## Aufgaben

### 1. Docker Volume erstellen
Erstelle ein Docker-Volume

### 2. Docker-Container mit Volume starten
Starte einen Nginx-Container und binde das erstellte Volume an den Pfad /usr/share/nginx/html:

### 3. Dateien in ein Volume kopieren
Kopiere lokale Dateien in das Docker-Volume:

### 4. Daten im Volume ändern
Ändere Daten direkt im Docker-Volume:
```bash
echo "Neue Daten" > /usr/share/nginx/html/neue-datei.txt
```

### 5. Daten zwischen Containern teilen
Starte einen zweiten Container und teile das gleiche Volume:
```bash
docker run -d --name mein-nginx-container-zweiter -v mein-docker-volume:/usr/share/nginx/html nginx
```

### 6. Volume-Inspektion
Zeige Informationen über das erstellte Volume an:

### 7. Daten in einem benutzerdefinierten Zielverzeichnis speichern
Starte einen Container und speichere Daten in einem benutzerdefinierten Zielverzeichnis:

## Nützliche Ressourcen
# Docker Volumes: https://docs.docker.com/storage/volumes/

Herzlichen Glückwunsch! Du hast nun die Grundlagen für die Verwendung von Docker-Volumes zur persistente Datenspeicherung kennengelernt.