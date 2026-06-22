# Lösung: Neuigkeiten 2025/2026

---

## Aufgabe 1 – Erwartete Ausgaben

```bash
docker version
# Client: Docker Engine - Community
# Version: 27.x.x  (oder Docker Desktop 4.3x.x)
# API version: 1.47+

docker compose version
# Docker Compose version v2.x.x  ← muss V2 sein

kubectl version --client
# Client Version: v1.32.x oder neuer

which docker-compose
# → kein Ergebnis (leer) = korrekt, V1 ist entfernt
```

---

## Aufgabe 2 – `docker debug`

```bash
docker run -d --name test-nginx nginx:alpine
docker debug test-nginx
# Startet eine Shell im Container über das Debug-Image
# /usr/share/nginx/html/index.html  → vorhanden
# /etc/nginx/nginx.conf             → vollständige Konfiguration

exit
docker rm -f test-nginx
```

**Warum funktioniert das?**  
`docker debug` mountet ein separates Toolset-Image über den laufenden Container. Das Original-Image wird nicht verändert.

---

## Aufgabe 3 – `compose watch`

```yaml
# compose.yml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    develop:
      watch:
        - path: ./html
          action: sync
          target: /usr/share/nginx/html
```

```bash
mkdir html
echo "<h1>Hello Watch</h1>" > html/index.html
docker compose watch

# In einem zweiten Terminal:
echo "<h1>Updated!</h1>" > html/index.html
curl http://localhost:8080
# → <h1>Updated!</h1>
```

> `action: sync` kopiert Dateien direkt in den Container ohne Neustart.  
> `action: rebuild` würde das Image neu bauen (z.B. wenn `package.json` sich ändert).
