# Lösung: Arbeit mit Containern – die Grundlagen

---

## Aufgabe 1

```bash
docker run -d \
  --name mydb \
  -p 5432:5432 \
  -e POSTGRES_DB=kurs \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  postgres:16-alpine

docker ps
# CONTAINER ID  IMAGE              COMMAND     STATUS   PORTS                    NAMES
# abc123        postgres:16-alpine  ...        Up 5s    0.0.0.0:5432->5432/tcp   mydb

docker logs mydb
# LOG: database system is ready to accept connections

docker inspect mydb | grep '"IPAddress"'
# "IPAddress": "172.17.0.2"

docker stats --no-stream mydb
# mydb  ~10-15 MiB RAM
```

---

## Aufgabe 2

```bash
docker exec -it mydb psql -U admin -d kurs
# psql (16.x)
# kurs=#

\l
#    Name    |  Owner   | Encoding
# -----------+----------+----------
#  kurs      | admin    | UTF8
# (1 row)

\q

docker exec mydb psql -U admin -d kurs -c "SELECT version();"
# PostgreSQL 16.x on aarch64-unknown-linux-musl ...

docker exec mydb ls /var/lib/postgresql/data
# PG_VERSION  base  global  pg_hba.conf  postgresql.conf ...
```

---

## Aufgabe 3

```bash
docker logs -f mydb
# Ctrl+C zum Beenden

docker stop mydb
# mydb

docker ps       # → leer (kein laufender Container)
docker ps -a    # → mydb mit Status "Exited (0)"

docker start mydb
docker ps       # → mydb läuft wieder

docker rm -f mydb
# mydb

docker system df
# Images: X GB
# Containers: 0 B  (alle entfernt)
```
