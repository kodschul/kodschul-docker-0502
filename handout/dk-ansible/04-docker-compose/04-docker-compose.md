# 04 – Komplexe Anwendungen mit Docker Compose

**Block:** 2 × 90 min | **Tag 1 (Teil 1) + Tag 2 (Teil 2)**

---

## Was ist Docker Compose?

Docker Compose ermöglicht es, **mehrere Container als eine Anwendung** zu definieren, zu starten und zu verwalten – alles deklarativ in einer YAML-Datei.

```
ohne Compose                        mit Compose
──────────────────────────          ─────────────────────
docker run -d --name db \           docker compose up -d
  -e POSTGRES_PASSWORD=x \
  postgres:16                       → startet db + backend +
                                      frontend mit einem Befehl
docker run -d --name backend \
  --link db:db \
  -p 8080:8080 myapp

docker run -d --name frontend \
  -p 3000:3000 myfrontend
```

---

## Lab 4.1 – Einführung in Docker Compose

### compose.yml – Grundaufbau

```yaml
# compose.yml (empfohlener Dateiname ab 2024)
services:
  servicename: # frei wählbarer Name
    image: nginx:alpine # fertiges Image ODER
    build: ./ordner # Dockerfile in diesem Ordner
    ports:
      - "8080:80"
    environment:
      - KEY=VALUE
    volumes:
      - ./local:/container
    depends_on:
      - anderer-service

volumes: # Named Volumes definieren
  db-data:

networks: # Custom Networks definieren
  internal:
```

### Grundlegende Compose-Befehle

```bash
docker compose up              # starten (foreground)
docker compose up -d           # starten (im Hintergrund)
docker compose up --build      # Images neu bauen vor Start
docker compose down            # stoppen + Container entfernen
docker compose down -v         # auch Volumes löschen
docker compose ps              # Status aller Services
docker compose logs            # Logs aller Services
docker compose logs -f backend # Logs eines Services live
docker compose exec backend bash  # Shell in Service
docker compose restart backend    # einzelnen Service neustarten
docker compose pull            # neueste Images laden
```

### Erstes vollständiges Beispiel

```yaml
# compose.yml
services:
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=db
      - DB_PORT=5432
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=secret
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "user", "-d", "myapp"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  db-data:
```

---

## Lab 4.2 – Multi-Container-Anwendungen

### Service Discovery im Compose-Netzwerk

Compose erstellt automatisch ein **gemeinsames Netzwerk**. Services können sich **über den Service-Namen** ansprechen:

```python
# backend/app.py
import os
import psycopg2

conn = psycopg2.connect(
    host=os.environ.get("DB_HOST", "db"),   # "db" = Service-Name
    port=os.environ.get("DB_PORT", 5432),
    database="myapp",
    user="user",
    password="secret"
)
```

```bash
# DNS-Auflösung im Container testen
docker compose exec backend ping db
docker compose exec backend nslookup db
```

### Skalierung einzelner Services

```bash
# Mehrere Instanzen eines Services starten
docker compose up -d --scale backend=3

# Achtung: Port-Binding muss angepasst werden (kein fester Host-Port)
ports:
  - "8080-8082:8080"   # Range statt fester Port
```

### Reihenfolge und Healthchecks

```yaml
depends_on:
  db:
    condition: service_healthy # wartet auf health: healthy
  redis:
    condition: service_started # wartet nur auf Start (default)
  migrate:
    condition: service_completed_successfully # wartet auf Exit 0
```

### Build-Konfiguration

```yaml
services:
  backend:
    build:
      context: ./backend # Build-Kontext (Verzeichnis)
      dockerfile: Dockerfile.prod # alternatives Dockerfile
      target: production # Multi-Stage-Target
      args:
        - BUILD_VERSION=1.2.3 # Build-Arguments
      cache_from:
        - myapp:cache
```

---

## Lab 4.3 – Datenvolumes, Persistenz und .env

### Volumes – drei Typen

```yaml
services:
  app:
    volumes:
      # 1. Bind Mount: Host-Verzeichnis einbinden (Dev)
      - ./src:/app/src

      # 2. Named Volume: von Docker verwaltet (Prod)
      - db-data:/var/lib/postgresql/data

      # 3. tmpfs: nur im RAM (sensible Daten)
      - type: tmpfs
        target: /tmp

volumes:
  db-data: # Named Volume deklarieren
    driver: local
```

```bash
docker volume ls              # alle Volumes anzeigen
docker volume inspect db-data # Details
docker volume rm db-data      # Volume löschen (Daten weg!)
```

### Umgebungsvariablen mit .env

```bash
# .env (nie ins Git committen!)
POSTGRES_PASSWORD=geheim123
POSTGRES_DB=myapp
APP_PORT=8080
TAG=2.1.0
```

```yaml
# compose.yml – automatisch gelesen aus .env
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}

  backend:
    image: myapp:${TAG:-latest} # Fallback mit :-
    ports:
      - "${APP_PORT}:8080"

  # Alternativ: env_file für viele Variablen
  worker:
    image: myapp-worker:${TAG:-latest}
    env_file:
      - .env
      - .env.local # lokale Überschreibungen
```

```bash
# Werte prüfen bevor Start
docker compose config      # vollständige compose.yml mit aufgelösten Werten
docker compose convert     # alias für config
```

### Mehrere Compose-Dateien (Override Pattern)

```bash
# Basis + Entwicklungs-Override
docker compose -f compose.yml -f compose.dev.yml up

# Basis + Produktions-Override
docker compose -f compose.yml -f compose.prod.yml up
```

```yaml
# compose.dev.yml – nur Überschreibungen
services:
  backend:
    volumes:
      - ./backend:/app # Code live mounten in Dev
    environment:
      - DEBUG=true
    command: python -m flask run --reload
```

---

## Zusammenfassung

```
compose.yml definiert Services, Volumes, Networks
├── services      → Container-Konfigurationen
├── volumes       → persistente Datenspeicher
└── networks      → Netzwerktrennung

Starten         docker compose up -d
Stoppen         docker compose down
Logs            docker compose logs -f
Shell           docker compose exec service bash
Konfiguration   docker compose config

.env            → Variablen automatisch eingelesen
override        → compose.dev.yml / compose.prod.yml
```
