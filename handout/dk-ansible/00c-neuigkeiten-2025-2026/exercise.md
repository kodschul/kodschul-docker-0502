# Übung: Neuigkeiten 2025/2026 entdecken

**Zeit:** 20 min

---

## Aufgabe 1 – Versionen prüfen (5 min)

Prüfe, was auf deinem System installiert ist:

```bash
docker version
docker compose version
kubectl version --client
```

**Fragen:**

- Welche Docker Engine-Version läuft?
- Ist `docker-compose` (V1) noch installiert? (`which docker-compose`)
- Nutzt du Kubernetes aus Docker Desktop oder ein anderes Setup?

---

## Aufgabe 2 – `docker debug` ausprobieren (5 min)

```bash
# Starte einen nginx-Container
docker run -d --name test-nginx nginx:alpine

# Öffne eine Debug-Shell (auch wenn kein bash im Image ist)
docker debug test-nginx

# Im Debug-Shell:
ls /usr/share/nginx/html
cat /etc/nginx/nginx.conf
exit

# Aufräumen
docker rm -f test-nginx
```

> Beobachte: Du bekommst eine Shell, obwohl `nginx:alpine` kein `bash` enthält.

---

## Aufgabe 3 – `compose watch` vorbereiten (10 min)

Ergänze eine `compose.yml` um den `watch`-Block:

```yaml
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
docker compose watch &

# Ändere die index.html und beobachte ob der Container aktualisiert wird
echo "<h1>Updated!</h1>" > html/index.html
curl http://localhost:8080
```
