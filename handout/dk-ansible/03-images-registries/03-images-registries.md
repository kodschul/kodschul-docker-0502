# 03 – Arbeiten mit Images und lokale Registries

**Block:** 90 min | **Tag 1**

---

## Was ist ein Image?

Ein Image ist ein **unveränderliches, geschichtetes Dateisystem** (read-only). Jede Schicht (Layer) entspricht einem Befehl im Dockerfile. Wenn ein Container gestartet wird, legt Docker eine beschreibbare Schicht oben drauf.

```
Container (read/write Layer)
────────────────────────────
Layer 4: COPY app/ /app/         ← Änderungen hier landen
Layer 3: RUN pip install -r req  ← gecacht bei unveränderter req.txt
Layer 2: COPY requirements.txt . ← invalidiert Layer 3+4 wenn geändert
Layer 1: FROM python:3.12-alpine ← Basis
```

---

## Lab 3.1 – Aufbau und Speichern von Images

### Images anzeigen und verwalten

```bash
docker images                          # lokale Images
docker images -a                       # inkl. Zwischenlayer
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
docker image inspect nginx:alpine      # Metadaten, Layer, Env
docker image history nginx:alpine      # Layer-Aufbau anzeigen
```

### Images laden und pushen

```bash
# Von Registry laden
docker pull nginx:alpine
docker pull python:3.12-slim
docker pull ubuntu:24.04

# Image taggen (für Registry)
docker tag nginx:alpine myregistry.local:5000/nginx:1.0

# In Registry pushen
docker push myregistry.local:5000/nginx:1.0

# Image als Datei exportieren
docker save nginx:alpine -o nginx.tar
docker save nginx:alpine | gzip > nginx.tar.gz

# Image aus Datei laden
docker load -i nginx.tar
```

---

## Lab 3.2 – Eigene Images erstellen

### Dockerfile – Grundstruktur

```dockerfile
# Basis-Image
FROM python:3.12-alpine

# Metadaten
LABEL maintainer="franz@example.com"
LABEL version="1.0"

# Arbeitsverzeichnis setzen
WORKDIR /app

# Dateien kopieren (Cache-optimiert: req zuerst)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App-Code kopieren
COPY . .

# Non-root User
RUN adduser -D appuser
USER appuser

# Port dokumentieren (nur Hinweis, kein Binding!)
EXPOSE 8000

# Start-Befehl
CMD ["python", "app.py"]
```

### Dockerfile-Anweisungen im Überblick

| Anweisung    | Bedeutung                                     |
| ------------ | --------------------------------------------- |
| `FROM`       | Basis-Image                                   |
| `WORKDIR`    | Arbeitsverzeichnis (wird angelegt wenn nötig) |
| `COPY`       | Dateien aus Build-Kontext ins Image           |
| `ADD`        | wie COPY, aber auch URLs + tar-Entpacken      |
| `RUN`        | Befehl beim Build ausführen (neuer Layer)     |
| `CMD`        | Standard-Startbefehl (überschreibbar)         |
| `ENTRYPOINT` | Fester Startpunkt (CMD = Argumente dazu)      |
| `ENV`        | Umgebungsvariable setzen                      |
| `ARG`        | Build-Argument (nur zur Build-Zeit)           |
| `EXPOSE`     | Port dokumentieren                            |
| `VOLUME`     | Mount-Punkt für Volumes                       |
| `LABEL`      | Metadaten                                     |

### CMD vs. ENTRYPOINT

```dockerfile
# CMD: alles überschreibbar
CMD ["python", "app.py"]
# docker run myimage python other.py  → führt "python other.py" aus

# ENTRYPOINT: fest, CMD = optionale Argumente
ENTRYPOINT ["python"]
CMD ["app.py"]
# docker run myimage        → python app.py
# docker run myimage test.py  → python test.py
```

### Image bauen

```bash
docker build -t myapp:1.0 .
docker build -t myapp:1.0 -f Dockerfile.prod .   # alternatives Dockerfile
docker build --no-cache -t myapp:1.0 .            # Cache ignorieren
docker build --build-arg VERSION=1.2 -t myapp .   # ARG übergeben

# Build-Ausgabe beobachten
docker build --progress=plain -t myapp .
```

### Multi-Stage Build

```dockerfile
# Stage 1: Compiler/Builder
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o server .

# Stage 2: Minimales Runtime-Image
FROM scratch AS production
COPY --from=builder /app/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
```

```bash
# Nur bis bestimmte Stage bauen
docker build --target builder -t myapp:debug .
docker build --target production -t myapp:1.0 .
```

---

## Lab 3.3 – Lokale Registry

### Eigene Registry starten

```bash
docker run -d \
  -p 5000:5000 \
  --name registry \
  --restart always \
  -v registry-data:/var/lib/registry \
  registry:2
```

### Image in lokale Registry pushen

```bash
# Image taggen mit Registry-Adresse
docker tag myapp:1.0 localhost:5000/myapp:1.0

# Pushen
docker push localhost:5000/myapp:1.0

# Von lokaler Registry laden
docker pull localhost:5000/myapp:1.0

# Registry-Inhalt anzeigen (API)
curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2/myapp/tags/list
```

### Harbor – Enterprise Registry

```yaml
# docker compose für Harbor (vereinfacht)
# Vollständige Installationsanleitung: https://goharbor.io/docs/
```

Harbor bietet zusätzlich:

- Vulnerability-Scanning (Trivy integriert)
- Role-based Access Control (RBAC)
- Image Replication zwischen Registries
- Content Trust (Image-Signierung)
- Quota-Management

---

## Zusammenfassung

```
Image aufgebaut aus Layers (read-only)
├── FROM       → Basis-Layer
├── RUN        → neuer Layer pro Befehl
└── COPY       → neuer Layer

Bauen
└── docker build -t name:tag .

Verteilen
├── docker push name:tag
├── docker pull name:tag
└── docker save / docker load

Lokale Registry
└── docker run -d -p 5000:5000 registry:2
```
