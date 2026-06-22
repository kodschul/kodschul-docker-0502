# Lösung: Docker Networking

---

## Aufgabe 1

```bash
docker network ls
# bridge   bridge   local
# host     host     local
# none     null     local

docker run -d --name c1 alpine sleep 600
docker run -d --name c2 alpine sleep 600

docker inspect c1 | grep '"IPAddress"'
# "IPAddress": "172.17.0.2"
docker inspect c2 | grep '"IPAddress"'
# "IPAddress": "172.17.0.3"

docker exec c1 ping c2
# ping: bad address 'c2'  ← kein DNS im default bridge!

docker exec c1 ping 172.17.0.3
# PING 172.17.0.3: 56 data bytes  ← IP funktioniert ✅

docker rm -f c1 c2
```

**Antwort:** Im standard `bridge`-Netzwerk gibt es keinen eingebauten DNS-Resolver für Container-Namen. Nur in **custom bridge networks** funktioniert Name-Auflösung automatisch.

---

## Aufgabe 2

```bash
docker network create kurs-net
docker run -d --name server --network kurs-net nginx:alpine
docker run -it --rm --network kurs-net alpine sh

# Im alpine Container:
ping server
# PING server (172.18.0.2): 56 data bytes → funktioniert ✅

wget -O - http://server
# <!DOCTYPE html><html>... → nginx Antwort ✅

nslookup server
# Name: server
# Address: 172.18.0.2
exit
```

---

## Aufgabe 3

```yaml
# compose.yml
services:
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - public
      - internal

  backend:
    image: nginx:alpine # als Platzhalter
    networks:
      - internal # kein Port-Mapping → von außen nicht erreichbar

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secret
    networks:
      - internal

networks:
  public:
  internal:
    internal: true
```

```bash
docker compose up -d

curl http://localhost:8080
# Connection refused ← backend hat kein Port-Mapping ✅

docker compose exec frontend wget -q -O - http://backend
# nginx HTML ← frontend → backend über internes Netz ✅

docker compose exec frontend ping db
# Network unreachable ← frontend ist nicht im db-Netz ✅
```
