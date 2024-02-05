# Docker Beispiele: Ressourcen bereitstellen und Netzwerke erstellen

In diesem Dokument findest du Beispiele, die du für Präsentationen verwenden kannst, um Docker-Ressourcen bereitzustellen und Netzwerke zu erstellen.

## Ressourcen bereitstellen

## Beispiel: CPU- und Speicherbegrenzung

Starte einen Container mit begrenzten Ressourcen (CPU und Speicher):

```bash
docker run -it --rm --name mein-container-mit-begrenzung --cpus=0.5 --memory=512m ubuntu:latest
```

## Beispiel: Container-Priorität
Starte mehrere Container mit unterschiedlichen Prioritäten:

```bash
docker run -d --name mein-container1 --cpu-shares=1024 nginx
docker run -d --name mein-container2 --cpu-shares=512 nginx
```

### Netzwerkoptionen in Docker
## Beispiel: Vorhandene Netzwerke anzeigen

```bash
docker network ls
```

## Beispiel: Benutzerdefiniertes Docker-Netzwerk erstellen
Erstelle ein benutzerdefiniertes Docker-Netzwerk:

```bash
docker network create mein-netzwerk
```

Starte einen Nginx-Container im erstellten Netzwerk:

```bash
docker run -d --name mein-nginx-container --network mein-netzwerk nginx
```

## Beispiel: Container-Kommunikation im Netzwerk
Starte einen zweiten Container im gleichen Netzwerk:

```bash
docker run -it --rm --name mein-ubuntu-container --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container
```

## Beispiel: Host-Netzwerkmodus
Starte einen Container im Host-Netzwerkmodus:

```bash
docker run -it --rm --name mein-ubuntu-container-host --network host ubuntu:latest
# Innerhalb des Containers
curl http://localhost:80
```

## Beispiel: Container mit spezifischem Port
Starte einen Container und binde ihn an einen spezifischen Port auf dem Host:

```bash
docker run -d --name mein-nginx-container-port -p 8080:80 nginx
```

## Beispiel: DNS-Namen in Containern verwenden
Starte einen Container und verwende einen DNS-Namen anstelle einer IP-Adresse:

```bash
docker run -it --rm --name mein-ubuntu-container-dns --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container-port
```

Diese Beispiele sollen als Grundlage für die Präsentation von Docker-Ressourcen und Netzwerkoptionen dienen. Du kannst sie nach Bedarf anpassen und erweitern, um die spezifischen Aspekte von Docker zu betonen, die für deine Präsentation relevant sind.