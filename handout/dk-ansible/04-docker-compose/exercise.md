# Übung: Docker Compose

**Zeit:** 2 × 30 min (je ein Block pro Tag)

---

## Block 1 – Teil 1: Erste compose.yml (30 min)

### Aufgabe 1 – Einfache App mit Compose starten (15 min)

Erstelle folgende Struktur:

```
compose-app/
├── compose.yml
├── backend/
│   ├── Dockerfile
│   └── app.py
└── .env
```

**backend/app.py:**

```python
from flask import Flask, jsonify
import os, psycopg2

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({"status": "ok", "env": os.environ.get("APP_ENV", "dev")})

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

**backend/Dockerfile:**

```dockerfile
FROM python:3.12-alpine
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir flask psycopg2-binary
COPY . .
EXPOSE 8080
CMD ["python", "app.py"]
```

**.env:**

```
APP_ENV=development
POSTGRES_PASSWORD=secret
POSTGRES_DB=myapp
```

**Aufgabe:** Schreibe eine `compose.yml` mit:

- `backend`: aus `./backend` gebaut, Port 8080, nutzt `.env`
- `db`: postgres:16-alpine, Passwort + DB aus `.env`, mit Healthcheck

```bash
docker compose up -d
docker compose ps
curl http://localhost:8080
docker compose logs db
```

---

### Aufgabe 2 – depends_on mit Healthcheck (15 min)

Erweitere die `compose.yml`: `backend` soll erst starten, wenn `db` healthy ist.

```bash
docker compose down
docker compose up -d
docker compose ps   # beobachte: backend wartet auf db
docker compose logs --follow
```

---

## Block 2 – Teil 2: Override & Volumes (30 min)

### Aufgabe 3 – Dev vs. Prod Override (15 min)

Erstelle eine `compose.dev.yml`:

```yaml
services:
  backend:
    volumes:
      - ./backend:/app # Live-Code-Sync
    environment:
      - FLASK_DEBUG=1
    command: python -m flask run --host=0.0.0.0 --port=8080 --reload
```

```bash
# Starte mit Dev-Override
docker compose -f compose.yml -f compose.dev.yml up -d

# Ändere etwas in backend/app.py und prüfe ob Neustart passiert
```

### Aufgabe 4 – Volume-Persistenz testen (15 min)

```bash
# 1. Starte den Stack
docker compose up -d

# 2. Lege in der DB eine Tabelle an
docker compose exec db psql -U postgres -d myapp -c \
  "CREATE TABLE test (id serial PRIMARY KEY, name text);"
docker compose exec db psql -U postgres -d myapp -c \
  "INSERT INTO test (name) VALUES ('persistiert!');"

# 3. Stoppe und entferne Container (aber NICHT Volumes!)
docker compose down

# 4. Starte neu
docker compose up -d

# 5. Ist die Tabelle noch da?
docker compose exec db psql -U postgres -d myapp -c "SELECT * FROM test;"

# 6. Jetzt MIT Volume löschen:
docker compose down -v
docker compose up -d
# → Tabelle weg
```
