# 02 – Arbeit mit Containern – die Grundlagen

**Block:** 90 min | **Tag 1**

---

## Container-Lebenszyklus

```
docker pull    →  Image lokal verfügbar
docker run     →  Container erstellen + starten
docker stop    →  Container stoppen (SIGTERM → SIGKILL)
docker start   →  gestoppten Container wieder starten
docker rm      →  Container löschen
docker rmi     →  Image löschen
```

---

## Lab 2.1 – Container über die CLI steuern

### Erster Container

```bash
# Einfachster Start
docker run hello-world

# Interaktiv (Terminal + Shell)
docker run -it ubuntu bash

# Im Hintergrund (detached)
docker run -d nginx

# Name vergeben
docker run -d --name mein-nginx nginx

# Port weiterleiten: Host:Container
docker run -d -p 8080:80 --name webserver nginx
# → http://localhost:8080
```

### Häufige `run`-Flags

| Flag                       | Bedeutung                                  |
| -------------------------- | ------------------------------------------ |
| `-d`                       | detached – im Hintergrund laufen           |
| `-it`                      | interaktiv mit Terminal                    |
| `--name`                   | Container benennen                         |
| `-p 8080:80`               | Port-Mapping Host:Container                |
| `-e KEY=VALUE`             | Umgebungsvariable setzen                   |
| `-v /host:/container`      | Volume mounten                             |
| `--rm`                     | Container nach Beenden automatisch löschen |
| `--restart unless-stopped` | Neustart-Politik                           |

```bash
# Umgebungsvariablen übergeben
docker run -d \
  -e POSTGRES_PASSWORD=geheim \
  -e POSTGRES_DB=myapp \
  -p 5432:5432 \
  --name db \
  postgres:16-alpine
```

---

## Lab 2.2 – Verwaltung und Inspektion

### Container anzeigen

```bash
docker ps                     # laufende Container
docker ps -a                  # alle (auch gestoppte)
docker ps -q                  # nur IDs (für Scripting)
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Logs lesen

```bash
docker logs webserver             # alle Logs ausgeben
docker logs -f webserver          # live folgen (follow)
docker logs --tail 50 webserver   # letzte 50 Zeilen
docker logs --since 10m webserver # Logs der letzten 10 Minuten
```

### In Container einsteigen

```bash
docker exec -it webserver bash        # neue Shell öffnen
docker exec webserver ls /etc/nginx   # einmaliger Befehl
docker exec -it db psql -U postgres   # direkt psql öffnen
```

### Container inspizieren

```bash
docker inspect webserver              # vollständige JSON-Infos
docker inspect webserver | grep IPAddress  # IP herausfiltern
docker stats                          # Live CPU/RAM aller Container
docker stats --no-stream              # einmalige Ausgabe
docker top webserver                  # Prozesse im Container
```

### Container stoppen und entfernen

```bash
docker stop webserver             # SIGTERM, dann SIGKILL
docker stop -t 30 webserver       # 30s Wartezeit vor SIGKILL
docker kill webserver             # sofort SIGKILL
docker rm webserver               # gestoppten Container löschen
docker rm -f webserver            # laufenden Container erzwungen löschen
docker rm $(docker ps -aq)        # alle gestoppten Container löschen
```

---

## Lab 2.3 – Docker-Alternativen

### Podman

```bash
# Drop-in Replacement für Docker (kompatible CLI)
podman run -d -p 8080:80 nginx
podman ps
podman logs <container>

# Rootless: kein Daemon, kein root nötig
# Pods: mehrere Container als Einheit (wie K8s Pods)
```

| Aspekt         | Docker                            | Podman              |
| -------------- | --------------------------------- | ------------------- |
| Daemon         | ja (dockerd läuft im Hintergrund) | nein (daemonless)   |
| Root           | standardmäßig root                | rootless by default |
| Kompatibilität | OCI-Standard                      | OCI-Standard        |
| Pods           | nur via Compose/K8s               | nativ unterstützt   |
| macOS          | Docker Desktop                    | Podman Desktop      |

### Weitere Tools

| Tool        | Zweck                                               |
| ----------- | --------------------------------------------------- |
| **nerdctl** | Docker-kompatible CLI für containerd                |
| **crictl**  | CLI für CRI-kompatible Runtimes (K8s-Debugging)     |
| **Buildah** | Image bauen ohne Daemon                             |
| **Skopeo**  | Images zwischen Registries kopieren und inspizieren |

### `docker system` – Aufräumen

```bash
docker system df                  # Speicherverbrauch anzeigen
docker system prune               # ungenutzte Ressourcen entfernen
docker system prune -a            # ALLE ungenutzten Images entfernen
docker image prune                # nur ungetaggte Images
docker volume prune               # ungenutzte Volumes
docker network prune              # ungenutzte Netzwerke
```

---

## Zusammenfassung

```
Starten     docker run -d -p 8080:80 --name web nginx
Anzeigen    docker ps / docker ps -a
Logs        docker logs -f web
Einsteigen  docker exec -it web bash
Inspizieren docker inspect web / docker stats
Stoppen     docker stop web
Entfernen   docker rm web
Aufräumen   docker system prune
```
