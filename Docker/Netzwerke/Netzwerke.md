# Docker: Ressourcen bereitstellen und Netzwerke erstellen
Die Bereitstellung von Ressourcen und die Verwaltung von Netzwerken sind wichtige Aspekte bei der Arbeit mit Docker. Hier sind grundlegende Beispiele für die Bereitstellung von Ressourcen und das Erstellen von Docker-Netzwerken.

## Ressourcen bereitstellen
## CPU- und Speicherbegrenzung
Container mit begrenzten Ressourcen (CPU und Speicher) starten:

```bash
docker run -it --rm --name mein-container-mit-begrenzung --cpus=0.5 --memory=512m ubuntu:latest
```

## Container-Priorität
Mehrere Container mit unterschiedlichen Prioritäten starten:

```bash
docker run -d --name mein-container1 --cpu-shares=1024 nginx
docker run -d --name mein-container2 --cpu-shares=512 nginx
```

## Netzwerkoptionen in Docker
Vorhandene Netzwerke anzeigen
Zeige die Liste der vorhandenen Docker-Netzwerke an:

```bash
docker network ls
```

## Benutzerdefiniertes Docker-Netzwerk erstellen
1. Benutzerdefiniertes Docker-Netzwerk erstellen:
```bash
docker network create mein-netzwerk
```

2. Nginx-Container im erstellten Netzwerk starten:
```bash
docker run -d --name mein-nginx-container --network mein-netzwerk nginx
```

## Container-Kommunikation im Netzwerk
Zweiten Container im gleichen Netzwerk starten:

```bash
docker run -it --rm --name mein-ubuntu-container --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container
```

## Host-Netzwerkmodus
Container im Host-Netzwerkmodus starten:

```bash
docker run -it --rm --name mein-ubuntu-container-host --network host ubuntu:latest
# Innerhalb des Containers
curl http://localhost:80
```

## Container mit spezifischem Port
Container starten und an einen spezifischen Port auf dem Host binden:

```bash
docker run -d --name mein-nginx-container-port -p 8080:80 nginx
```

## DNS-Namen in Containern verwenden
Container starten und DNS-Namen anstelle von IP-Adressen verwenden:

```bash
docker run -it --rm --name mein-ubuntu-container-dns --network mein-netzwerk ubuntu:latest
# Innerhalb des Containers
ping mein-nginx-container-port
```

## Nützliche Ressourcen
### Docker Netzwerke: https://docs.docker.com/network/
### Docker Ressourcen und Leistung: https://docs.docker.com/config/containers/resource_constraints/

Diese Zusammenstellung bietet grundlegende Beispiele zur Bereitstellung von Ressourcen und zur Erstellung von Docker-Netzwerken. Du kannst diese Befehle an deine spezifischen Anforderungen anpassen und erweitern.