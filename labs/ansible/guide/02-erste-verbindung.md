# 02 – Erste Verbindung & Ad-hoc-Befehle

**Lernziel:** Ansible mit einem Server sprechen lassen – ohne Playbook-Datei.
**Playbook:** `01-ping.yml`

---

## Was ist ein Ad-hoc-Befehl?

Ein Ad-hoc-Befehl führt **ein einzelnes Modul direkt in der Shell** aus –
ohne eine Playbook-Datei zu schreiben.
Ideal für schnelle Tests, Überprüfungen oder einmalige Aktionen.

```
ansible  <Ziel>  -m <Modul>  -a "<Argumente>"
   │        │        │              │
   │        │        │              └── Parameter für das Modul
   │        │        └── Modul-Name (z.B. ping, command, copy)
   │        └── Ziel: Gruppe, Hostname oder "all"
   └── das Programm
```

---

## Schritt 1 – Verbindung testen: das ping-Modul

> **Wichtig:** Das Ansible-`ping` schickt **kein** ICMP-Paket.
> Es verbindet sich per SSH, startet Python und erwartet `"pong"` zurück.
> Wenn es funktioniert → SSH + Python auf dem Server vorhanden.

```bash
# Im Control Node:
ansible all -m ping
```

Erwartete Ausgabe:
```
server1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
server2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Bedeutung der Farben / Schlüsselwörter:

| Schlüsselwort | Bedeutung |
|---|---|
| `SUCCESS` | Modul hat ohne Fehler ausgeführt |
| `changed: false` | Auf dem Server wurde nichts verändert |
| `UNREACHABLE` | SSH konnte nicht aufgebaut werden |
| `FAILED` | Modul hat einen Fehler gemeldet |

---

## Schritt 2 – Befehle ausführen

```bash
# Hostname abfragen
ansible all -m command -a "hostname"

# Betriebssystem abfragen
ansible all -m command -a "uname -a"

# Speichernutzung
ansible all -m command -a "free -m"

# Festplattenbelegung
ansible all -m command -a "df -h /"

# Nur auf einem Server
ansible server1 -m command -a "whoami"
```

### `command` vs. `shell`

```bash
# command: führt das Programm direkt aus (sicherer)
ansible all -m command -a "ls /tmp"

# shell: führt über /bin/sh aus – Pipes, Variablen etc. möglich
ansible all -m shell -a "echo $HOSTNAME"
ansible all -m shell -a "ls /tmp | grep ansible"
```

---

## Schritt 3 – Ziele einschränken

```bash
# Alle Server
ansible all -m ping

# Nur die Gruppe "servers"
ansible servers -m ping

# Nur server1
ansible server1 -m ping

# Alle AUSSER server2
ansible 'all,!server2' -m ping
```

---

## Schritt 4 – Inventory anzeigen

```bash
# Liste aller Hosts
ansible all --list-hosts

# Inventory als Baumstruktur
ansible-inventory --graph

# Alle Variablen für server1
ansible-inventory --host server1
```

---

## Dein erstes Playbook lesen

Öffne (auf deinem Windows-Rechner in VS Code):
```
labs/ansible/playbooks/01-ping.yml
```

Lies die Kommentare – das Playbook tut genau das, was du gerade
als Ad-hoc-Befehle gemacht hast, nur formalisiert in YAML:

```yaml
- name: "Lab 01 — Verify connectivity to all managed nodes"
  hosts: servers          # Zielgruppe
  gather_facts: false     # keine automatischen Infos sammeln

  tasks:

    - name: Ping the server via Ansible
      ansible.builtin.ping:       # Modul: ping

    - name: Run a simple shell command
      ansible.builtin.command: echo "Hello from {{ inventory_hostname }}!"
      register: hello_output      # Ausgabe in Variable speichern
      changed_when: false

    - name: Show the output
      ansible.builtin.debug:
        msg: "{{ hello_output.stdout }}"   # Variable ausgeben
```

### Aufbau eines Tasks

```yaml
    - name: Beschreibender Name (erscheint in der Ausgabe)
      ansible.builtin.MODUL:      # Modul auswählen
        parameter1: wert1         # Modul-Parameter
        parameter2: wert2
      register: ergebnis          # optional: Ausgabe speichern
      changed_when: false         # optional: nie als "geändert" markieren
```

---

## Playbook ausführen

```bash
ansible-playbook /playbooks/01-ping.yml
```

### Die PLAY RECAP lesen

```
PLAY RECAP *****************************************************
server1 : ok=3  changed=0  unreachable=0  failed=0
server2 : ok=3  changed=0  unreachable=0  failed=0
```

| Spalte | Bedeutung |
|---|---|
| `ok` | Tasks, die ohne Fehler liefen (und nichts änderten) |
| `changed` | Tasks, die etwas auf dem Server verändert haben |
| `unreachable` | Server nicht erreichbar (SSH-Problem) |
| `failed` | Tasks mit Fehler |

---

## Nützliche Flags

```bash
# Sehr ausführliche Ausgabe (zeigt die SSH-Kommandos)
ansible-playbook /playbooks/01-ping.yml -v

# Noch ausführlicher (zeigt Modul-Parameter)
ansible-playbook /playbooks/01-ping.yml -vv

# Debug-Level (zeigt alles, sehr viel Output)
ansible-playbook /playbooks/01-ping.yml -vvv

# Nur auf server1 ausführen
ansible-playbook /playbooks/01-ping.yml --limit server1

# Dry-Run: zeigt was passieren WÜRDE, ändert nichts
ansible-playbook /playbooks/01-ping.yml --check
```

---

## Übung

1. Führe `ansible all -m ping` aus.
2. Führe `ansible server1 -m command -a "hostname"` aus.
3. Führe das Playbook aus: `ansible-playbook /playbooks/01-ping.yml`
4. Führe es ein zweites Mal aus. Was siehst du? Ändert sich die `changed`-Zahl?

---

## Verständnisfragen

**1. Was testet `ansible all -m ping` wirklich?**
> Es schickt **kein ICMP-Paket** (kein Netzwerk-Ping).
> Ansible verbindet sich per SSH, startet Python auf dem Server und erwartet `"pong"` zurück.
> Ein Erfolg beweist: SSH-Verbindung funktioniert + Python ist vorhanden.

**2. Was bedeutet `changed: false` in der Ausgabe?**
> Der Task hat auf dem Server **nichts verändert**.
> Das `ping`-Modul liest nur und ändert nie etwas – daher immer `changed: false`.

**3. Was ist der Unterschied zwischen `command` und `shell`?**
> `command` führt das Programm **direkt** aus, ohne Shell-Interpreter. Sicherer, aber keine Pipes oder `$VARIABLE`.
> `shell` führt den Befehl über `/bin/sh` aus – Pipes (`|`), Umleitungen (`>`) und Umgebungsvariablen funktionieren.
> Faustregel: `command` verwenden, `shell` nur wenn Pipes/Variablen nötig.

**4. Was bedeuten `ok`, `changed`, `failed` im PLAY RECAP?**
> - `ok` → Task lief, Zustand war bereits korrekt → keine Änderung
> - `changed` → Task hat etwas auf dem Server verändert
> - `failed` → Task hat einen Fehler gemeldet, Playbook stoppt
> - `unreachable` → SSH-Verbindung konnte nicht aufgebaut werden

---

## Nächster Schritt

→ [03 – Dateien und Tasks](03-dateien-und-tasks.md)
