# Docker Grundlagen

## Ziel
Das Ziel dieser Übungen ist es, Docker zu installieren und die grundlegenden Schritte für die Verwendung von Docker zu verstehen.

## Voraussetzungen
- Ein Computer mit einem unterstützten Betriebssystem (Windows, macOS oder Linux).
- Internetverbindung für die Docker-Installation.

## Aufgaben

### 1. Docker Installation
Installiere Docker auf deinem Computer, indem du die entsprechende Anleitung für dein Betriebssystem befolgst:
- [Docker Desktop für Windows](https://docs.docker.com/desktop/install/windows/)
- [Docker Desktop für macOS](https://docs.docker.com/desktop/install/mac/)
- [Docker für Linux](https://docs.docker.com/desktop/install/linux/)

### 2. Überprüfung der Docker-Installation
Öffne ein Terminal (oder die Kommandozeile) und führe den folgenden Befehl aus, um sicherzustellen, dass Docker erfolgreich installiert wurde:
```bash
docker --version
```

### 3. Das erste Docker-Image herunterladen
Lade das offizielle "Hello World" Docker-Image herunter, um sicherzustellen, dass Docker richtig funktioniert:
```bash
docker run hello-world
```