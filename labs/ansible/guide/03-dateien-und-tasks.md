# 03 – Dateien und Tasks

**Lernziel:** Dateien auf Servern erstellen, lesen und mit Schleifen vervielfältigen.
**Playbook:** `02-files.yml`

---

## Wie funktionieren Tasks?

Ein Playbook besteht aus einer geordneten Liste von Tasks.
Ansible führt sie **von oben nach unten** aus – auf allen Ziel-Hosts gleichzeitig.

```
Play: "Datei-Management"
   │
   ├── Task 1: Verzeichnis erstellen     → läuft auf server1 UND server2
   ├── Task 2: Datei schreiben           → läuft auf server1 UND server2
   ├── Task 3: Datei lesen               → läuft auf server1 UND server2
   └── Task 4: Datei-Liste ausgeben      → läuft auf server1 UND server2
```

---

## Modul: `file` – Verzeichnisse und Dateien verwalten

```yaml
- name: Verzeichnis anlegen
  ansible.builtin.file:
    path: /opt/meinprojekt      # Pfad
    state: directory            # "directory" = Verzeichnis anlegen
    mode: '0755'                # Berechtigungen (rwxr-xr-x)

- name: Datei löschen
  ansible.builtin.file:
    path: /tmp/alteдатei.txt
    state: absent               # "absent" = löschen, falls vorhanden

- name: Symlink erstellen
  ansible.builtin.file:
    src: /etc/nginx/sites-available/meineseite
    dest: /etc/nginx/sites-enabled/meineseite
    state: link
```

**Wichtige `state`-Werte:**

| state | Bedeutung |
|---|---|
| `directory` | Verzeichnis erstellen (wie `mkdir -p`) |
| `file` | Datei muss existieren (erstellt sie nicht, prüft nur) |
| `absent` | Löschen, egal ob Datei oder Verzeichnis |
| `link` | Symbolischen Link erstellen |
| `touch` | Datei erstellen / Zeitstempel aktualisieren |

---

## Modul: `copy` – Dateien schreiben

```yaml
# Variante A: Inhalt direkt im Playbook
- name: Konfigurationsdatei schreiben
  ansible.builtin.copy:
    dest: /etc/meinapp/config.txt
    content: |
      Zeile 1
      Zeile 2 mit Variable: {{ inventory_hostname }}
    mode: '0644'

# Variante B: Lokale Datei hochladen
- name: Skript auf den Server kopieren
  ansible.builtin.copy:
    src: files/deploy.sh        # liegt auf dem Control Node
    dest: /usr/local/bin/deploy.sh
    mode: '0755'

# Variante C: Datei auf dem Server kopieren (remote_src)
- name: Backup erstellen
  ansible.builtin.copy:
    src: /etc/nginx/nginx.conf  # liegt auf dem Server selbst
    dest: /etc/nginx/nginx.conf.bak
    remote_src: true
```

---

## Modul: `command` + `register` – Ausgaben lesen

`register` speichert die Ausgabe eines Tasks in eine Variable.
Diese Variable kannst du dann in anderen Tasks weiterverwenden.

```yaml
- name: Datei-Inhalt lesen
  ansible.builtin.command: cat /etc/meinapp/config.txt
  register: dateiinhalt         # Ausgabe in Variable "dateiinhalt" speichern
  changed_when: false           # "cat" verändert nichts → nie als "changed" markieren

- name: Inhalt ausgeben
  ansible.builtin.debug:
    msg: "{{ dateiinhalt.stdout }}"           # die gesamte Ausgabe als String
    # oder:
    # msg: "{{ dateiinhalt.stdout_lines }}"   # als Liste von Zeilen
```

**Felder einer `register`-Variable:**

| Feld | Inhalt |
|---|---|
| `.stdout` | Ausgabe als String |
| `.stdout_lines` | Ausgabe als Liste (eine Zeile = ein Listenelement) |
| `.stderr` | Fehlerausgabe |
| `.rc` | Return Code (0 = Erfolg) |
| `.changed` | Wurde etwas verändert? |

---

## Schleifen mit `loop`

Mit `loop` kannst du den gleichen Task mehrfach ausführen –
mit jeweils einem anderen Wert.

```yaml
- name: Mehrere Pakete installieren
  ansible.builtin.apt:
    name: "{{ item }}"          # {{ item }} = aktueller Schleifenwert
    state: present
  loop:
    - curl
    - vim
    - tree
```

```yaml
- name: Mehrere Dateien erstellen
  ansible.builtin.copy:
    dest: "/tmp/datei-{{ item }}.txt"
    content: "Inhalt von Datei {{ item }}\n"
  loop:
    - alpha
    - beta
    - gamma
```

> `{{ item }}` ist der Platzhalter für den aktuellen Schleifenwert.
> Ansible führt den Task für jedes Element in der `loop`-Liste aus.

---

## Playbook anschauen und ausführen

Lies das Playbook durch – alle Konzepte oben findest du darin wieder:

```bash
# Im Control Node:
ansible-playbook /playbooks/02-files.yml
```

Prüfe danach das Ergebnis:

```bash
# Verzeichnis und Dateien auf server1 anschauen
ansible server1 -m command -a "ls -la /opt/ansible-lab/"

# Inhalt der hello.txt lesen
ansible server1 -m command -a "cat /opt/ansible-lab/hello.txt"

# Was steht in den Loop-Dateien?
ansible all -m command -a "cat /opt/ansible-lab/alpha.txt"
```

---

## Idempotenz selbst erleben

Führe das Playbook ein zweites Mal aus:

```bash
ansible-playbook /playbooks/02-files.yml
```

Beobachtung:
- Beim ersten Mal: `changed=5` oder ähnlich
- Beim zweiten Mal: `changed=0`

Das ist **Idempotenz** – Ansible prüft zuerst, ob die gewünschte Datei
schon mit dem richtigen Inhalt existiert. Nur wenn etwas abweicht, wird es
geändert. So ist das Playbook sicher, mehrmals auszuführen.

---

## Übung

1. Führe `02-files.yml` aus.
2. Öffne die Datei in VS Code: `playbooks/02-files.yml`
3. Ändere den Inhalt der `hello.txt` (den `content:`-Block im 2. Task).
4. Führe das Playbook erneut aus. Was steht jetzt in `changed=`?
5. Füge einen weiteren Eintrag in die `loop:`-Liste hinzu (z.B. `delta`).
6. Führe das Playbook erneut aus und prüfe mit:
   ```bash
   ansible all -m command -a "ls /opt/ansible-lab/"
   ```

---

## Verständnisfragen

**1. Was speichert `register` und welche Felder hat die Variable?**
> `register` speichert die gesamte Ausgabe eines Tasks in einer benannten Variable.
> Wichtige Felder: `.stdout` (Ausgabe als Text), `.stdout_lines` (Ausgabe als Liste),
> `.stderr` (Fehlerausgabe), `.rc` (Return Code: 0 = Erfolg), `.changed` (wurde etwas geändert?).

**2. Wofür steht `{{ item }}` in einer `loop:`-Schleife?**
> `{{ item }}` ist der Platzhalter für den **aktuellen Wert** aus der `loop:`-Liste.
> Ansible führt den Task für jedes Element einmal aus und ersetzt `{{ item }}` durch den jeweiligen Wert.

**3. Was bedeutet Idempotenz – und was ist der praktische Vorteil?**
> Idempotenz bedeutet: Ein Playbook kann **beliebig oft ausgeführt** werden und erzeugt immer dasselbe Ergebnis.
> Ansible prüft den aktuellen Zustand und ändert nur, was vom gewünschten Zustand abweicht.
> Vorteil: Playbooks sind sicher wiederholbar – z.B. nach einem Fehler, als Cronjob oder zur Drift-Korrektur.

**4. Was ist der Unterschied zwischen `copy` mit `content:` und `copy` mit `src:`?**
> `content:` schreibt den Dateiinhalt **direkt im Playbook** auf den Server.
> `src:` kopiert eine **Datei vom Control Node** (lokal auf deinem Rechner) auf den Server.
> Für viele Variablen in der Datei besser: `template`-Modul mit einer `.j2`-Datei.

---

## Nächster Schritt

→ [04 – Facts und Conditionals](04-facts-und-conditionals.md)
