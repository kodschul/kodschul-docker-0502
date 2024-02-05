# Docker Container

## Ziel
Die nachfolgenden Übungen führen dich durch grundlegende Befehle zur Steuerung von Docker-Containern und zeigen, wie du Container erstellst, startest und verwaltest.

## Voraussetzungen
- Docker ist auf deinem Computer installiert (siehe vorherige Übungen).

## Aufgaben

### 1. Docker-Container erstellen und starten
Erstelle und starte einen einfachen Docker-Container mit dem offiziellen Nginx-Image:
```bash
docker run -d --name mein-nginx-container -p 8080:80 nginx
```
Öffne http://localhost:8080 in deinem Browser, um die Nginx-Begrüßungsseite anzuzeigen.

### 2. Container stoppen und starten
Stoppe den erstellten Container und starte ihn erneut:

### 3. Umgebungsvariablen in Containern setzen
Erstelle einen Container mit einer Umgebungsvariable:

Überprüfe, ob die Umgebungsvariable im Container gesetzt ist:
```bash
docker exec mein-container-mit-env env
```

### 4. Dateien zwischen Host und Container kopieren
Kopiere eine lokale Datei in einen laufenden Container:

### 5. Container-Logs anzeigen
Zeige die Logs eines Containers an:

### 6. Container in den Hintergrund verschieben
Starte einen interaktiven Container im Hintergrund:

Verbinde dich mit dem laufenden Container:
```bash
docker exec -it mein-hintergrund-container /bin/bash
```

### 7. Ressourcenbegrenzung für Container
Starte einen Container mit begrenzten Ressourcen (CPU und Speicher):

### 8. Container stoppen und löschen
Stoppe und lösche Container, die nicht mehr benötigt werden:

## Nützliche Ressourcen
# Docker CLI-Referenz: https://docs.docker.com/engine/reference/commandline/cli/

Herzlichen Glückwunsch! Du hast nun die grundlegenden Befehle zur Steuerung von Docker-Containern kennengelernt.