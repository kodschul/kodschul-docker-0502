# 00b – Linux Grundlagen für den Kurs

**Block:** 90 min | **Extra-Modul** (bei Bedarf: vor Tag 1 oder als Abendeinheit)

---

## Warum Linux?

Docker, Kubernetes und Ansible laufen auf Linux – oder nutzen Linux-Kernel-Mechanismen direkt. Wer die Basics kennt, versteht, was hinter `docker run`, `kubectl exec` und Ansible-Tasks passiert.

---

## Dateisystem-Struktur

```
/
├── bin/        → Systembefehle (ls, cp, mv …)
├── etc/        → Konfigurationsdateien
├── home/       → Heimverzeichnisse der Nutzer
├── var/        → variable Daten: Logs, Caches
├── tmp/        → temporäre Dateien
├── usr/        → installierte Software
└── proc/       → virtuelle Infos über laufende Prozesse
```

> **Bezug zu Docker:** Ein Container-Image ist nichts anderes als ein vollständiges Linux-Dateisystem – gepackt und schreibgeschützt.

---

## Navigation & Dateiverwaltung

```bash
pwd                        # aktuelles Verzeichnis anzeigen
ls -lah                    # Inhalt mit Details und versteckten Dateien
cd /etc/nginx              # Verzeichnis wechseln
cd -                       # zum letzten Verzeichnis zurück
mkdir -p projekt/src       # Ordner (mit Unterordnern) anlegen
rm -rf ordner/             # Ordner rekursiv löschen (Vorsicht!)
cp datei.txt kopie.txt     # Datei kopieren
mv alt.txt neu.txt         # Datei umbenennen / verschieben
touch leere-datei.txt      # leere Datei anlegen
cat datei.txt              # Inhalt ausgeben
less datei.txt             # Inhalt seitenweise lesen (q = beenden)
```

---

## Dateiberechtigungen

```bash
ls -l
# -rw-r--r-- 1 franz staff 1234 Jun 22 09:00 config.yml
#  ↑ Typ     ↑ Besitzer  ↑ Gruppe
#   rwx rwx rwx
#   │   │   └─ andere
#   │   └───── Gruppe
#   └───────── Besitzer
```

| Zeichen | Bedeutung | Wert |
| ------- | --------- | ---- |
| `r`     | lesen     | 4    |
| `w`     | schreiben | 2    |
| `x`     | ausführen | 1    |

```bash
chmod 755 skript.sh        # rwxr-xr-x
chmod +x skript.sh         # ausführbar machen
chown franz:staff datei    # Besitzer ändern
```

> **Bezug zu Docker:** `COPY --chmod=755` im Dockerfile setzt Berechtigungen direkt beim Build.

---

## Prozesse

```bash
ps aux                     # alle laufenden Prozesse
ps aux | grep nginx        # nach Prozess filtern
top                        # interaktive Prozessübersicht (q = beenden)
htop                       # erweiterte Übersicht (falls installiert)
kill 1234                  # Prozess mit PID 1234 beenden (SIGTERM)
kill -9 1234               # Prozess sofort beenden (SIGKILL)
```

> **Bezug zu Docker:** `docker stop` schickt SIGTERM; nach 10 Sekunden folgt SIGKILL. Dein Prozess sollte SIGTERM sauber behandeln.

---

## Text suchen und verarbeiten

```bash
grep "error" app.log                  # Zeilen mit "error" finden
grep -r "PORT" .                      # rekursiv in allen Dateien
grep -i "error" app.log               # Groß-/Kleinschreibung ignorieren
tail -f /var/log/syslog               # Log live verfolgen
tail -n 50 app.log                    # letzte 50 Zeilen
head -n 20 datei.txt                  # erste 20 Zeilen
wc -l datei.txt                       # Zeilen zählen
cut -d':' -f1 /etc/passwd             # Spalte 1 aus CSV extrahieren
awk '{print $1}' access.log           # erstes Feld jeder Zeile
sed 's/alt/neu/g' datei.txt           # Text ersetzen
```

---

## Umgebungsvariablen

```bash
echo $HOME                 # Wert einer Variable ausgeben
echo $PATH                 # Suchpfade für Befehle
export MY_VAR=hallo        # Variable für aktuelle Session setzen
printenv                   # alle Variablen anzeigen
env                        # alle Variablen (alternative)
```

**In einer Datei setzen (.env):**

```bash
# .env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
```

```bash
export $(cat .env | xargs)   # .env-Datei in aktuelle Shell laden
```

> **Bezug zu Docker Compose:** `env_file: .env` lädt genau dieses Format in den Container.

---

## Netzwerk

```bash
ip addr                    # IP-Adressen der Interfaces
ip route                   # Routing-Tabelle
curl http://localhost:8080 # HTTP-Request absetzen
curl -I https://google.com # nur HTTP-Header
wget -O - http://example.com  # Inhalt herunterladen
ss -tlnp                   # offene TCP-Ports (modern, ersetzt netstat)
netstat -tlnp              # offene TCP-Ports (klassisch)
ping google.com            # Erreichbarkeit testen
nslookup example.com       # DNS-Abfrage
```

> **Bezug zu Docker:** `docker inspect <container>` zeigt dieselben Netzwerkdaten wie `ip addr` – nur pro Container.

---

## Pakete installieren

```bash
# Debian / Ubuntu (apt)
apt update                 # Paketliste aktualisieren
apt install curl vim       # Pakete installieren
apt remove vim             # Paket entfernen
apt search nginx           # nach Paket suchen

# RHEL / Rocky / AlmaLinux (dnf)
dnf install curl vim
dnf update
```

---

## Shell-Skripte – Grundstruktur

```bash
#!/bin/bash
set -e          # Bei Fehler abbrechen
set -u          # Ungesetzte Variablen = Fehler

NAME="Welt"
echo "Hallo, $NAME!"

if [ -f "/etc/hosts" ]; then
  echo "Hosts-Datei gefunden"
fi

for i in 1 2 3; do
  echo "Durchlauf $i"
done
```

```bash
chmod +x skript.sh
./skript.sh
```

---

## SSH – Verbindung zu Remote-Hosts

```bash
ssh user@192.168.1.10            # Verbindung aufbauen
ssh -i ~/.ssh/id_rsa user@host  # mit bestimmtem Key
ssh-keygen -t ed25519            # neues Schlüsselpaar erzeugen
ssh-copy-id user@host            # Public Key auf Host kopieren
```

> **Bezug zu Ansible:** Ansible nutzt genau diesen SSH-Mechanismus – kein Agent, kein Daemon auf dem Ziel-Host nötig.

---

## Hilfreich in der Praxis

| Situation                              | Befehl                                   |
| -------------------------------------- | ---------------------------------------- | --------- |
| Wo liegt eine Binärdatei?              | `which docker` / `command -v kubectl`    |
| Was läuft auf Port 80?                 | `ss -tlnp                                | grep :80` |
| Wie viel Speicher ist frei?            | `df -h` / `free -h`                      |
| Welche Dateien wurden gerade geöffnet? | `lsof -p <pid>`                          |
| Letzter Befehl rückgängig?             | Kein Undo – daher: `man rm` vorher lesen |

---

## Zusammenfassung

```
Navigation     →  cd, ls, pwd, mkdir, rm
Dateien        →  cat, less, grep, tail, sed, awk
Rechte         →  chmod, chown
Prozesse       →  ps, kill, top
Netzwerk       →  ip, ss, curl, ping
Pakete         →  apt / dnf
SSH            →  ssh, ssh-keygen, ssh-copy-id
```
