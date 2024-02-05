# Docker Einführung: Netzwerkoptionen und Netzwerke

## Ziel
Die nachfolgenden Übungen führen dich durch grundlegende Netzwerkoptionen in Docker und zeigen, wie du eigene Docker-Netzwerke erstellst.

## Voraussetzungen
- Docker ist auf deinem Computer installiert (siehe vorherige Übungen).

## Aufgaben

### 1. Vorhandene Netzwerke anzeigen
Zeige die Liste der vorhandenen Docker-Netzwerke an:
```bash
docker network ls
```

### 2. Ein benutzerdefiniertes Netzwerk erstellen
Erstelle ein benutzerdefiniertes Docker-Netzwerk

### 3. Container mit einem benutzerdefinierten Netzwerk starten
Starte einen Nginx-Container und füge ihn zum benutzerdefinierten Netzwerk hinzu

### 4. Container-Kommunikation im Netzwerk
Starte einen zweiten Container im gleichen Netzwerk und versuche, vom ersten Container auf den zweiten zuzugreifen:
```bash
# Innerhalb des Containers
ping mein-nginx-container
```

### 5. Container aus einem Netzwerk entfernen
Entferne einen Container aus einem Netzwerk:

### 6. Host-Netzwerkmodus
Starte einen Container im Host-Netzwerkmodus und vergleiche den Netzwerkzugriff mit einem Container im Bridge-Modus:

### 7. Container mit spezifischem Port
Starte einen Container und binde ihn an einen spezifischen Port auf dem Host:

### 8. Netzwerkpräfixe
Zeige die Netzwerkpräfixe von Containern an:
```bash
docker network inspect mein-netzwerk
```

## Nützliche Ressourcen
# Docker Netzwerke: https://docs.docker.com/network/

Herzlichen Glückwunsch! Du hast nun die grundlegenden Netzwerkoptionen in Docker kennengelernt und eigene Docker-Netzwerke erstellt.