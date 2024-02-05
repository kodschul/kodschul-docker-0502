# Docker Beispiele: Docker-Registries, Images und Dockerfiles

In diesem Dokument findest du Beispiele, die du für Präsentationen verwenden kannst, um Docker-Registries einzurichten, Docker-Images zu erstellen, zu verwalten und zu verteilen sowie Dockerfiles zu verwenden, um Images zu erstellen und anzupassen.

## Docker-Registries einrichten

### Beispiel: Docker Hub

1. Melde dich auf [Docker Hub](https://hub.docker.com/) an oder erstelle ein Konto.
2. Erstelle ein neues Repository, z. B. "mein-docker-repo".
3. Verwende die Docker-CLI, um ein Docker-Image zu erstellen und auf Docker Hub hochzuladen:

```bash
# Docker Image erstellen
docker build -t dein-docker-benutzername/mein-docker-repo:tag .

# Docker Image auf Docker Hub pushen
docker push dein-docker-benutzername/mein-docker-repo:tag
```

### Docker-Images erstellen, verwalten und verteilen
## Beispiel: Basis-Image verwenden
Erstelle ein einfaches Dockerfile, das auf einem offiziellen Ubuntu-Image basiert:

```bash
# Verwende ein vorhandenes Docker-Image als Basis
FROM ubuntu:latest

# Füge einen Ausdruck hinzu
CMD ["echo", "Hallo, Docker!"]
```

Baue und starte das Image:

```bash
# Docker Image erstellen
docker build -t mein-ubuntu-image .

# Docker Container starten
docker run mein-ubuntu-image
```

## Beispiel: Image-Versionen verwalten
Benutze Tags, um Versionen von Docker-Images zu verwalten:

```bash
# Docker Image mit Tag erstellen
docker build -t mein-ubuntu-image:1.0 .

# Docker Image mit anderem Tag erstellen
docker build -t mein-ubuntu-image:2.0 .
```

### Mit Dockerfiles Images erstellen und anpassen
## Beispiel: Node.js-Anwendung
Erstelle ein einfaches Dockerfile für eine Node.js-Anwendung:


```bash
# Verwende ein offizielles Node.js-Image als Basis
FROM node:14

# Setze das Arbeitsverzeichnis im Container
WORKDIR /usr/src/app

# Kopiere die Abhängigkeiten und den Code in das Arbeitsverzeichnis
COPY package*.json ./
RUN npm install
COPY . .

# Exponiere den Port
EXPOSE 3000

# Starte die Anwendung
CMD ["npm", "start"]
```

Baue und starte das Image:

```bash
# Docker Image erstellen
docker build -t mein-nodejs-image .

# Docker Container starten
docker run -p 3000:3000 mein-nodejs-image
```

Diese Beispiele sollen als Ausgangspunkt für Präsentationen dienen und können entsprechend den Anforderungen und Inhalten angepasst werden. Du kannst die Befehle und Strukturen verwenden, um die grundlegenden Konzepte von Docker-Registries, Images und Dockerfiles zu erklären.
