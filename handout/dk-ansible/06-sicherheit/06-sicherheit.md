# 06 – Docker Sicherheit

**Block:** 90 min | **Tag 2**

---

## Warum Container-Sicherheit?

Container teilen sich den Host-Kernel. Ein kompromittierter Container kann – ohne zusätzliche Absicherung – auf andere Container, Host-Prozesse oder das Netzwerk zugreifen.

```
Angriffsflächen
├── Images: Schwachstellen in Basis-Images oder Dependencies
├── Runtime: privilege escalation, container escape
├── Secrets: hardcodierte Passwörter, ENV-Variablen in Logs
├── Netzwerk: offene Ports, fehlende NetworkPolicies
└── Registry: manipulierte Images (Supply Chain)
```

---

## Lab 6.1 – Grundlagen der Docker-Sicherheit

### Prinzip der geringsten Rechte

```dockerfile
# ❌ Container läuft als root
FROM alpine
RUN apk add curl
CMD ["sh"]

# ✅ Non-root User
FROM alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

```bash
# Aktuellen User im Container prüfen
docker run --rm alpine whoami          # root (!)
docker run --rm -u 1000:1000 alpine whoami  # 1000

# Read-only Filesystem
docker run --rm --read-only alpine sh -c "echo x > /test"
# → Read-only file system

# Read-only mit tmpfs für schreibbare Bereiche
docker run --rm \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/run \
  nginx:alpine
```

### Capabilities einschränken

Linux-Capabilities teilen root-Rechte in granulare Privilegien auf. Docker gewährt Containern standardmäßig ~14 von 40+ Capabilities.

```bash
# Alle Capabilities entfernen, nur nötige hinzufügen
docker run --rm \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  nginx:alpine

# Aktuelle Capabilities eines Containers
docker inspect mycontainer | grep CapAdd
docker inspect mycontainer | grep CapDrop

# Welche Capabilities hat ein Prozess?
docker exec mycontainer cat /proc/1/status | grep Cap
```

### Seccomp-Profile

```bash
# Standard: Docker-Default-Seccomp-Profil (erlaubt ~300 Syscalls)
# Strenger: eigenes Profil

# Seccomp komplett deaktivieren (nur für Debugging!)
docker run --rm --security-opt seccomp=unconfined alpine sh

# Eigenes Profil nutzen
docker run --rm --security-opt seccomp=./mein-profil.json alpine sh
```

---

## Lab 6.2 – Containerisolierung und Ressourcenbeschränkungen

### Ressourcen limitieren

```bash
# Speicher begrenzen
docker run -d --memory 256m --name web nginx
docker run -d --memory 256m --memory-swap 256m nginx   # kein Swap

# CPU begrenzen
docker run -d --cpus 0.5 nginx         # max 50% einer CPU
docker run -d --cpu-shares 512 nginx   # relative Gewichtung (default: 1024)

# Beides zusammen
docker run -d \
  --name backend \
  --memory 512m \
  --memory-swap 512m \
  --cpus 1.0 \
  myapp:1.0

# Limits eines laufenden Containers prüfen
docker stats --no-stream backend
docker inspect backend | grep -A5 "HostConfig" | grep -E "Memory|Cpu"
```

### Privileged vs. Rootless

```bash
# ❌ privileged: voller Kernel-Zugang, fast keine Isolation
docker run --privileged myimage    # nur wenn unbedingt nötig

# ✅ rootless Docker: Docker-Daemon läuft ohne root
# Installation: dockerd-rootless-setuptool.sh install
# Danach: reguläre docker-Befehle, daemon hat keine root-Rechte

# User Namespace Remapping
# In /etc/docker/daemon.json:
# { "userns-remap": "default" }
# → Container-root wird auf unprivilegiertem Host-User gemappt
```

### Netzwerkisolierung

```yaml
# compose.yml: Backend von außen unerreichbar
services:
  frontend:
    ports:
      - "80:80"
    networks:
      - public
      - internal

  backend:
    # kein ports-Mapping!
    networks:
      - internal # nur über frontend erreichbar

  db:
    networks:
      - internal # nur über backend erreichbar

networks:
  public:
  internal:
    internal: true # kein Internet-Zugang
```

---

## Lab 6.3 – Security Scanning und weitere Tools

### Image-Scanning mit Docker Scout

```bash
# Scout ist in Docker Desktop integriert
docker scout cves nginx:alpine           # CVEs anzeigen
docker scout cves --exit-code myapp:1.0  # Exit 1 wenn CVEs vorhanden
docker scout recommendations myapp:1.0   # besseres Basis-Image vorschlagen
docker scout quickview myapp:1.0         # Kurzübersicht
```

### Trivy – Open Source Scanner

```bash
# Installation
brew install aquasecurity/trivy/trivy

# Image scannen
trivy image nginx:alpine
trivy image --severity HIGH,CRITICAL myapp:1.0

# Dockerfile scannen
trivy config ./Dockerfile

# Compose-Datei scannen
trivy config compose.yml

# Nur kritische Findings, JSON-Output für CI
trivy image --format json \
  --severity CRITICAL \
  --exit-code 1 \
  myapp:1.0
```

### Secrets-Management

```bash
# ❌ Secrets in ENV → sichtbar in docker inspect, docker history
docker run -e DB_PASSWORD=geheim myapp

# ✅ Docker Secrets (Swarm) oder externe Lösungen
# Für Compose lokal: Secrets aus Dateien
```

```yaml
# compose.yml mit Secrets
services:
  db:
    image: postgres:16-alpine
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt # Datei nicht ins Git!
```

### Docker Bench Security

```bash
# CIS Docker Benchmark – automatische Überprüfung
docker run --rm -it \
  --net host \
  --pid host \
  --userns host \
  --cap-add audit_control \
  -v /etc:/etc:ro \
  -v /lib/systemd/systemd:/lib/systemd/systemd:ro \
  -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
```

---

## Sicherheits-Checkliste

```
Images
  ☐ Minimales Basis-Image (alpine/distroless)
  ☐ Keine Secrets im Dockerfile oder Image
  ☐ CVE-Scan vor Deployment
  ☐ Konkrete Versionen gepinnt

Runtime
  ☐ Non-root User (USER-Anweisung)
  ☐ --read-only Filesystem wo möglich
  ☐ --cap-drop ALL + nur nötige --cap-add
  ☐ Speicher- und CPU-Limits gesetzt
  ☐ Kein --privileged

Netzwerk
  ☐ Port-Binding auf 127.0.0.1 oder intern
  ☐ Separate Netzwerke (public/internal)
  ☐ Unnötige Ports nicht exponiert

Secrets
  ☐ Keine hardcodierten Passwörter
  ☐ .env nicht in Git
  ☐ Docker Secrets oder Vault nutzen
```
