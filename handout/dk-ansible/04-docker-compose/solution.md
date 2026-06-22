# Lösung: Docker Compose

---

## Aufgabe 1 + 2 – compose.yml

```yaml
# compose.yml
services:
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: postgres
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres", "-d", "${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  db-data:
```

```bash
docker compose up -d
# [+] Running 2/2
#  ✔ Container db       Healthy
#  ✔ Container backend  Started

docker compose ps
curl http://localhost:8080
# {"env":"development","status":"ok"}

docker compose logs db
# LOG: database system is ready to accept connections
```

---

## Aufgabe 3 – compose.dev.yml

```yaml
# compose.dev.yml
services:
  backend:
    volumes:
      - ./backend:/app
    environment:
      - FLASK_DEBUG=1
    command: python -m flask run --host=0.0.0.0 --port=8080 --reload
```

```bash
docker compose -f compose.yml -f compose.dev.yml up -d

# app.py ändern → Flask-Reload-Meldung in Logs
docker compose logs -f backend
# * Detected change in '/app/app.py', reloading
```

---

## Aufgabe 4 – Volume-Persistenz

```bash
docker compose up -d

docker compose exec db psql -U postgres -d myapp -c \
  "CREATE TABLE test (id serial PRIMARY KEY, name text);"
docker compose exec db psql -U postgres -d myapp -c \
  "INSERT INTO test (name) VALUES ('persistiert!');"

docker compose down    # Container weg, Volume bleibt

docker compose up -d
docker compose exec db psql -U postgres -d myapp -c "SELECT * FROM test;"
# id |    name
# ---+-------------
#  1 | persistiert!   ← Daten sind noch da!

docker compose down -v    # Volume auch löschen
docker compose up -d
docker compose exec db psql -U postgres -d myapp -c "SELECT * FROM test;"
# ERROR:  relation "test" does not exist  ← Daten weg
```

**Fazit:** `docker compose down` entfernt Container, aber behält Named Volumes. Erst `-v` löscht auch Volumes.
