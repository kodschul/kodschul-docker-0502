# Docker Beispiele: Steuerung von Containern und Befehle

In diesem Dokument findest du Beispiele, die du für Präsentationen verwenden kannst, um die Steuerung von Docker-Containern und grundlegende Befehle zu demonstrieren.

## Steuerung von Containern

## Beispiel: Container erstellen und starten

1. Erstelle und starte einen einfachen Nginx-Container:

```bash
docker run -d --name mein-nginx-container -p 8080:80 nginx
```

Öffne http://localhost:8080 im Browser, um die Nginx-Begrüßungsseite anzuzeigen.

## Beispiel: Container stoppen und starten

```bash
docker stop mein-nginx-container
docker start mein-nginx-container
```

## Beispiel: Umgebungsvariablen setzen und anzeigen

```bash
docker run -d --name mein-container -e MEINE_VARIABLE=Wert ubuntu:latest
docker exec mein-container env
```

### Grundlegende Befehle
## Beispiel: Container-Logs anzeigen

```bash
docker logs mein-nginx-container
```

## Beispiel: Container in den Hintergrund verschieben

```bash
docker run -itd --name mein-hintergrund-container ubuntu:latest
docker exec -it mein-hintergrund-container /bin/bash
```

## Beispiel: Ressourcenbegrenzung für Container

```bash
docker run -it --rm --name mein-container-mit-begrenzung --cpus=0.5 --memory=512m ubuntu:latest
```

## Beispiel: Container stoppen und löschen

```bash
docker stop mein-nginx-container
docker rm mein-nginx-container
```

## Beispiel: Docker-Netzwerkoptionen

```bash
docker network create mein-netzwerk
docker run -d --name mein-nginx-container-netzwerk --network mein-netzwerk nginx
```

## Beispiel: Docker-Volume verwenden

```bash
docker volume create mein-docker-volume
docker run -d --name mein-nginx-container-volume -v mein-docker-volume:/usr/share/nginx/html nginx
```

Diese Beispiele sollen als Anleitung für die Präsentation von Docker-Befehlen und die Steuerung von Containern dienen. Du kannst sie anpassen und erweitern, um die spezifischen Aspekte von Docker zu betonen, die für deine Präsentation relevant sind.