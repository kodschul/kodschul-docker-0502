# Übung: Arbeit mit Containern – die Grundlagen

**Zeit:** 30 min

---

## Aufgabe 1 – Container starten und inspizieren (10 min)

```bash
# 1. Starte einen PostgreSQL-Container mit diesen Parametern:
#    - Name: mydb
#    - Port: 5432 auf Host gemappt
#    - Umgebungsvariablen: POSTGRES_DB=kurs, POSTGRES_USER=admin, POSTGRES_PASSWORD=secret
#    - Im Hintergrund
docker run -d \
  --name mydb \
  # ... ergänzen

# 2. Prüfe ob der Container läuft
docker ps

# 3. Zeige die Logs des Containers an
docker logs mydb

# 4. Zeige die IP-Adresse des Containers
docker inspect mydb | grep IPAddress

# 5. Zeige den Ressourcenverbrauch (einmalig)
docker stats --no-stream mydb
```

---

## Aufgabe 2 – In Container einsteigen (10 min)

```bash
# 1. Öffne eine psql-Session im laufenden mydb-Container
docker exec -it mydb psql -U admin -d kurs

# In psql:
\l           -- alle Datenbanken anzeigen
\q           -- beenden

# 2. Führe einen einmaligen Befehl aus (ohne interaktive Shell)
docker exec mydb psql -U admin -d kurs -c "SELECT version();"

# 3. Schau welche Dateien im Daten-Verzeichnis liegen
docker exec mydb ls /var/lib/postgresql/data
```

---

## Aufgabe 3 – Logs, Stop, Cleanup (10 min)

```bash
# 1. Verfolge die Logs live (5 Sekunden, dann Ctrl+C)
docker logs -f mydb

# 2. Stoppe den Container
docker stop mydb

# 3. Was zeigt docker ps jetzt?
docker ps
docker ps -a

# 4. Starte ihn wieder
docker start mydb

# 5. Räume auf: Container stoppen und entfernen
docker rm -f mydb

# 6. Speicherverbrauch prüfen
docker system df
```
