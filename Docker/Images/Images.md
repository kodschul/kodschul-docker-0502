# Docker-Registries einrichten, Docker-Images erstellen, verwalten und verteilen, Mit Dockerfiles Images erstellen und anpassen

##Docker-Registries einrichten
Docker Registries dienen dazu, Docker-Images zu speichern, zu organisieren und zu verteilen. Der bekannteste ist der Docker Hub, aber du kannst auch private Registries verwenden.

## 1. Docker Hub
1. Melde dich auf Docker Hub an oder erstelle ein Konto.

2. Erstelle ein neues Repository, z. B. "mein-docker-repo".

3. Verwende die Docker-CLI, um ein Docker-Image zu erstellen und auf Docker Hub hochzuladen:

# Docker Image erstellen

```bash
# Docker Image erstellen
docker build -t dein-docker-benutzername/mein-docker-repo:tag .

# Docker Image auf Docker Hub pushen
docker push dein-docker-benutzername/mein-docker-repo:tag
```

## 2. Privates Docker Registry
Du kannst auch ein privates Docker Registry einrichten. Docker Registry ist die offizielle Implementierung.

1. Installiere und starte das Registry:
```bash
docker run -d -p 5000:5000 --name mein-docker-registry registry
```

2. Baue ein Image und tagge es für das Registry:
```bash
docker build -t localhost:5000/mein-image:tag .
```

3. Pushe das Image zum privaten Registry:
```bash
docker push localhost:5000/mein-image:tag
```

## Docker-Images erstellen, verwalten und verteilen
## 1. Basis-Image verwenden
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

## 2. Image-Versionen verwalten
Benutze Tags, um Versionen von Docker-Images zu verwalten:

```bash
# Docker Image mit Tag erstellen
docker build -t mein-ubuntu-image:1.0 .

# Docker Image mit anderem Tag erstellen
docker build -t mein-ubuntu-image:2.0 .
```

## 3. Docker-Image auf Festplatte speichern
Speichere ein Docker-Image als TAR-Datei:

```bash
docker save -o mein-image.tar mein-ubuntu-image:1.0
```

## 4. Docker-Image von Festplatte laden
Lade ein zuvor gespeichertes Docker-Image von der Festplatte:

```bash
docker load -i mein-image.tar
```

## Mit Dockerfiles Images erstellen und anpassen
## 1. Node.js-Anwendung
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

Diese Zusammenstellung bietet eine Anleitung zur Einrichtung von Docker-Registries, zur Erstellung, Verwaltung und Verteilung von Docker-Images sowie zur Verwendung von Dockerfiles zur Anpassung von Images. Die bereitgestellten Links führen zu weiterführenden Informationen und Ressourcen.