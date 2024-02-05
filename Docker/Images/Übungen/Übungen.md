# Docker Images

## Ziel
Die folgenden Übungen führen dich in die Erstellung und Anpassung von Docker-Images mithilfe von Dockerfiles ein. Außerdem lernst du, wie Docker-Registries eingerichtet werden und wie Images verwaltet werden.

## Voraussetzungen
- Docker ist auf deinem Computer installiert (siehe vorherige Übungen).

## Aufgaben

### 1. Docker-Registries einrichten
Erstelle ein Konto auf [Docker Hub](https://hub.docker.com/) und richte einen eigenen Docker-Registry ein. Führe die folgenden Schritte durch:
- Melde dich auf Docker Hub an.
- Erstelle ein neues Repository (z.B., "mein-docker-repo").

### 2. Dockerfiles Einführung
Verstehe die Grundlagen von Dockerfiles, die für die Definition von Docker-Images verwendet werden. Ein Dockerfile besteht aus Anweisungen zum Erstellen eines Images. Beispiel:
```Dockerfile
# Verwende ein vorhandenes Docker-Image als Basis

# Füge Dateien oder Anweisungen hinzu

# Setze Umgebungsvariable

# Öffne den Port

# Starte die Anwendung
```

### 3. Mit Dockerfiles Images erstellen und anpassen
Erstelle ein einfaches Dockerfile für eine Node.js-Anwendung. Baue und starte das Image mit den folgenden Befehlen:
```bash
# Wechsle in das Verzeichnis mit dem Dockerfile

# Baue das Docker-Image
```
Überprüfe die Anwendung, indem du http://localhost:3000 in deinem Browser aufrufst.

### 4. Image auf Docker Hub pushen
Pushe das erstellte Image auf Docker Hub:
```bash
# Melde dich auf Docker Hub an
docker login

# Tagge das lokale Image mit dem Repository-Namen
docker tag mein-nodejs-image dein-docker-benutzername/mein-docker-repo:tag

# Pushe das Image auf Docker Hub
docker push dein-docker-benutzername/mein-docker-repo:tag
```

## Nützliche Ressourcen
# Docker Dokumentation zu Dockerfiles: https://docs.docker.com/engine/reference/builder/
# Docker Hub: https://hub.docker.com/

Herzlichen Glückwunsch! Du hast nun die Grundlagen für die Erstellung und Anpassung von Docker-Images sowie die Verwendung von Docker-Registries kennengelernt.