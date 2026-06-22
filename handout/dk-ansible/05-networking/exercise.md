# Übung: Docker Networking

**Zeit:** 30 min

---

## Aufgabe 1 – Standard-Netzwerk erkunden (10 min)

```bash
# 1. Standard-Netzwerke anzeigen
docker network ls

# 2. Starte zwei Alpine-Container im default bridge-Netzwerk
docker run -d --name c1 alpine sleep 600
docker run -d --name c2 alpine sleep 600

# 3. Finde die IP-Adressen beider Container
docker inspect c1 | grep IPAddress
docker inspect c2 | grep IPAddress

# 4. Versuche von c1 aus c2 über den Namen zu pingen
docker exec c1 ping c2
# → Ergebnis notieren

# 5. Versuche es mit der IP
docker exec c1 ping <IP-von-c2>
# → Ergebnis notieren

# Aufräumen
docker rm -f c1 c2
```

**Frage:** Warum funktioniert Name-Lookup im default bridge-Netz nicht?

---

## Aufgabe 2 – Custom Network mit DNS (10 min)

```bash
# 1. Eigenes Netzwerk erstellen
docker network create kurs-net

# 2. Zwei Container im neuen Netzwerk starten
docker run -d --name server --network kurs-net nginx:alpine
docker run -it --rm --network kurs-net alpine sh

# Im Alpine-Container:
ping server           # → sollte funktionieren
wget -O - http://server   # → nginx HTML
nslookup server       # → IP anzeigen
exit
```

---

## Aufgabe 3 – Netzwerktrennung mit Compose (10 min)

Erstelle eine `compose.yml`, die:

- `frontend` mit Port 80 nach außen exponiert
- `backend` **nicht** direkt von außen erreichbar ist
- `db` nur vom `backend` erreichbar ist

Nutze zwei Netzwerke: `public` und `internal`.

```bash
docker compose up -d
docker compose ps

# Teste: ist backend direkt von außen erreichbar?
curl http://localhost:8080   # sollte NICHT funktionieren (kein Port-Mapping)

# Teste: kann frontend das backend erreichen?
docker compose exec frontend wget -O - http://backend:8080

# Teste: kann frontend direkt die db erreichen?
docker compose exec frontend ping db   # sollte fehlschlagen (anderes Netz)
```
