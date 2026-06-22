# Übung: Docker Sicherheit

**Zeit:** 30 min

---

## Aufgabe 1 – Non-root und Read-only (10 min)

```bash
# 1. Prüfe als welcher User standard-Container laufen
docker run --rm alpine whoami
docker run --rm nginx whoami

# 2. Starte einen Container als User 1000
docker run --rm -u 1000:1000 alpine whoami
docker run --rm -u 1000:1000 alpine id

# 3. Read-only Filesystem testen
docker run --rm --read-only alpine sh -c "echo test > /test.txt"
# → Ergebnis?

# 4. Read-only mit tmpfs für /tmp
docker run --rm \
  --read-only \
  --tmpfs /tmp \
  alpine sh -c "echo 'ich darf /tmp schreiben' > /tmp/test.txt && cat /tmp/test.txt"
```

---

## Aufgabe 2 – Ressourcenlimits setzen (10 min)

```bash
# 1. Starte nginx mit 64 MB RAM-Limit und 0.2 CPU
docker run -d \
  --name limited-nginx \
  --memory 64m \
  --cpus 0.2 \
  nginx:alpine

# 2. Überprüfe die Limits
docker stats --no-stream limited-nginx
docker inspect limited-nginx | grep -E '"Memory"|"NanoCpus"'

# 3. Was passiert wenn das Limit überschritten wird?
# Starte einen Memory-Stress-Test (vorsichtig!)
docker run --rm --memory 32m \
  alpine sh -c "cat /dev/zero | head -c 64m > /dev/null"
# → Was ist der Exit Code?
echo "Exit: $?"
```

---

## Aufgabe 3 – Image-Scan (10 min)

Scanne das `python:3.10` Image auf Schwachstellen und vergleiche es mit `python:3.12-alpine`:

```bash
# Mit Docker Scout (falls in Docker Desktop verfügbar)
docker scout cves python:3.10 | head -50
docker scout cves python:3.12-alpine | head -50

# ODER mit Trivy
trivy image python:3.10 --severity HIGH,CRITICAL | tail -20
trivy image python:3.12-alpine --severity HIGH,CRITICAL | tail -20
```

**Fragen:**

- Wie viele HIGH/CRITICAL CVEs hat `python:3.10`?
- Wie viele hat `python:3.12-alpine`?
- Was ist der Hauptgrund für den Unterschied?
