# Docker: Volumes für persistente Datenspeicherung und Kommunikation
Die Verwendung von Volumes für persistente Datenspeicherung und die Kommunikation innerhalb von Containern sowie zwischen Containern und dem Host-System sind wesentliche Aspekte bei der Arbeit mit Docker. Hier sind grundlegende Beispiele für diese Konzepte.

## Volumes für persistente Datenspeicherung
## Docker-Volume erstellen und mit einem Container verbinden
Docker-Volume erstellen:

```bash
docker volume create mein-docker-volume
```

Nginx-Container starten und das erstellte Volume an den Pfad /usr/share/nginx/html binden:
bash

```bash
docker run -d --name mein-nginx-container -v mein-docker-volume:/usr/share/nginx/html nginx
```

Lokale Dateien in das Docker-Volume kopieren:

```bash
docker cp lokale-dateien/. mein-nginx-container:/usr/share/nginx/html/
```

## Daten zwischen Containern teilen
Zweiten Container starten und dasselbe Volume teilen:

```bash
docker run -d --name mein-nginx-container-zweiter -v mein-docker-volume:/usr/share/nginx/html nginx
```

## Kommunikation innerhalb von Containern
## Docker-Container mit einem Netzwerk verbinden
Benutzerdefiniertes Docker-Netzwerk erstellen:

```bash
docker network create mein-netzwerk
```

Nginx-Container starten und dem erstellten Netzwerk hinzufügen:

```bash
docker run -d --name mein-nginx-container-netzwerk --network mein-netzwerk nginx
```

Zweiten Container im gleichen Netzwerk starten und versuchen, vom ersten Container aus darauf zuzugreifen

```bash
docker run -it --rm --name mein-ubuntu-container --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container-netzwerk
```

## Kommunikation mit dem Host-System
## Host-Netzwerkmodus verwenden
Container im Host-Netzwerkmodus starten:

```bash
docker run -it --rm --name mein-ubuntu-container-host --network host ubuntu:latest
# Innerhalb des Containers
curl http://localhost:80
```

## Portbindung mit dem Host-System
Container starten und an einen spezifischen Port auf dem Host binden:

```bash
docker run -d --name mein-nginx-container-port -p 8080:80 nginx
```
Öffne http://localhost:8080 im Browser, um die Nginx-Begrüßungsseite anzuzeigen.

## DNS-Namen auf dem Host-System verwenden
Container starten und DNS-Namen auf dem Host-System verwenden:

```bash
docker run -it --rm --name mein-ubuntu-container-dns --network host ubuntu:latest
# Innerhalb des Containers
ping localhost
```

## Nützliche Ressourcen
### Docker Volumes: https://docs.docker.com/storage/volumes/
### Docker Networking: https://docs.docker.com/network/

Diese Zusammenstellung bietet grundlegende Beispiele für die Verwendung von Volumes zur persistenden Datenspeicherung und die Kommunikation innerhalb von Containern sowie zwischen Containern und dem Host-System. Du kannst diese Befehle an deine spezifischen Anforderungen anpassen und erweitern.