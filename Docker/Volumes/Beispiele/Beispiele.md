# Docker Beispiele: Volumes für persistente Datenspeicherung und Kommunikation

In diesem Dokument findest du Beispiele, die du für Präsentationen verwenden kannst, um Docker-Volumes für persistente Datenspeicherung zu nutzen und die Kommunikation innerhalb von Containern sowie zwischen Containern und dem Host-System zu zeigen.

## Volumes für persistente Datenspeicherung

### Beispiel: Docker-Volume erstellen und mit einem Container verbinden

1. Erstelle ein Docker-Volume:

```bash
docker volume create mein-docker-volume
```

2. Starte einen Nginx-Container und binde das erstellte Volume an den Pfad /usr/share/nginx/html:

```bash
docker run -d --name mein-nginx-container -v mein-docker-volume:/usr/share/nginx/html nginx
```

3. Kopiere lokale Dateien in das Docker-Volume:

```bash
docker cp lokale-dateien/. mein-nginx-container:/usr/share/nginx/html/
```

## Beispiel: Daten zwischen Containern teilen
Starte einen zweiten Container und teile das gleiche Volume:

```bash
docker run -d --name mein-nginx-container-zweiter -v mein-docker-volume:/usr/share/nginx/html nginx
```

### Kommunikation innerhalb von Containern
## Beispiel: Docker-Container mit einem Netzwerk verbinden
Erstelle ein benutzerdefiniertes Docker-Netzwerk:

```bash
docker network create mein-netzwerk
```

Starte einen Nginx-Container und füge ihn dem erstellten Netzwerk hinzu:

```bash
docker run -d --name mein-nginx-container-netzwerk --network mein-netzwerk nginx
```

Starte einen zweiten Container im gleichen Netzwerk und versuche, vom ersten Container aus darauf zuzugreifen:

```bash
docker run -it --rm --name mein-ubuntu-container --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container-netzwerk
```

### Kommunikation mit dem Host-System
## Beispiel: Host-Netzwerkmodus verwenden
Starte einen Container im Host-Netzwerkmodus:

```bash
docker run -it --rm --name mein-ubuntu-container-host --network host ubuntu:latest
# Innerhalb des Containers
curl http://localhost:80
```

## Beispiel: Portbindung mit dem Host-System
Starte einen Container und binde ihn an einen spezifischen Port auf dem Host:

```bash
docker run -d --name mein-nginx-container-port -p 8080:80 nginx
```

Öffne http://localhost:8080 im Browser, um die Nginx-Begrüßungsseite anzuzeigen.

## Beispiel: DNS-Namen auf dem Host-System verwenden
Starte einen Container und verwende einen DNS-Namen auf dem Host-System:

```bash
docker run -it --rm --name mein-ubuntu-container-dns --network host ubuntu:latest
# Innerhalb des Containers
ping localhost
```

Diese Beispiele sollen als Ausgangspunkt für die Präsentation von Docker-Volumes und Kommunikationsmöglichkeiten dienen. Du kannst sie nach Bedarf anpassen und erweitern, um die spezifischen Aspekte von Docker zu betonen, die für deine Präsentation relevant sind.