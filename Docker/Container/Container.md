# Docker: Steuerung von Containern und Befehle
Die Steuerung von Containern und die Verwendung von Docker-Befehlen sind zentrale Aspekte bei der Arbeit mit Docker. Hier sind einige grundlegende Beispiele, um Docker-Container zu steuern und nützliche Befehle anzuwenden.

## Container erstellen und starten
Einfachen Nginx-Container erstellen und starten

```bash
docker run -d --name mein-nginx-container -p 8080:80 nginx
```
Öffne http://localhost:8080 im Browser, um die Nginx-Begrüßungsseite anzuzeigen.

## Container stoppen und starten
Container stoppen:

```bash
docker stop mein-nginx-container
```

Container starten:

```bash
docker start mein-nginx-container
```

## Umgebungsvariablen setzen und anzeigen
Container mit Umgebungsvariable erstellen:

```bash
docker run -d --name mein-container -e MEINE_VARIABLE=Wert ubuntu:latest
```

Umgebungsvariablen im Container anzeigen:

```bash
docker exec mein-container env
```

## Container-Logs anzeigen
Zeige die Logs eines Containers an:

```bash
docker logs mein-nginx-container
```

## Container in den Hintergrund verschieben
Interaktiven Container im Hintergrund starten:

```bash
docker run -itd --name mein-hintergrund-container ubuntu:latest
```

Mit dem laufenden Container verbinden:

```bash
docker exec -it mein-hintergrund-container /bin/bash
```

## Ressourcenbegrenzung für Container
Container mit begrenzten Ressourcen (CPU und Speicher) starten:

```bash
docker run -it --rm --name mein-container-mit-begrenzung --cpus=0.5 --memory=512m ubuntu:latest
```

## Nützliche Ressourcen
### Docker CLI-Referenz: https://docs.docker.com/engine/reference/commandline/cli/
### Docker Befehlsübersicht: https://docs.docker.com/engine/reference/commandline/

Diese Zusammenstellung bietet grundlegende Beispiele zur Steuerung von Containern und zur Verwendung von Docker-Befehlen. Du kannst diese Befehle an deine spezifischen Anforderungen anpassen und erweitern.