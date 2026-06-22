# Übung: Linux Grundlagen

**Zeit:** 30 min

---

## Aufgabe 1 – Orientierung im Dateisystem (5 min)

Öffne ein Terminal und beantworte folgende Fragen **nur mit Linux-Befehlen**:

1. In welchem Verzeichnis bist du gerade?
2. Welche Dateien befinden sich in `/etc` und enthalten das Wort `host` im Namen?
3. Wie viel Speicherplatz ist auf deinem System noch frei?

---

## Aufgabe 2 – Datei und Verzeichnis (10 min)

```bash
# 1. Erstelle folgende Struktur unter ~/kurs/
#    kurs/
#    ├── docker/
#    │   └── notes.txt
#    └── ansible/
#        └── notes.txt

# 2. Schreibe "Docker ist cool" in docker/notes.txt
# 3. Kopiere docker/notes.txt nach ansible/notes.txt
# 4. Ersetze "Docker" durch "Ansible" in ansible/notes.txt (mit sed)
# 5. Gib beide Dateien aus und vergleiche
```

---

## Aufgabe 3 – Prozesse und Ports (10 min)

1. Starte einen einfachen Webserver im Hintergrund:

```bash
python3 -m http.server 9090 &
```

2. Finde den Prozess mit `ps aux | grep python`
3. Überprüfe, dass Port 9090 offen ist: `ss -tlnp | grep 9090`
4. Rufe den Server auf: `curl http://localhost:9090`
5. Beende den Prozess mit `kill <PID>`

---

## Aufgabe 4 – Umgebungsvariablen (5 min)

1. Erstelle eine Datei `.env` mit folgendem Inhalt:

```
APP_PORT=8080
APP_ENV=development
APP_NAME=MeinProjekt
```

2. Lade die Variablen in deine Shell: `export $(cat .env | xargs)`
3. Gib alle drei Werte aus mit `echo`
4. Was passiert wenn du ein neues Terminal öffnest – sind die Variablen noch da?
