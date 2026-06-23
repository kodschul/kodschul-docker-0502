# 10 – Ansible Cheatsheet

Alle wichtigen Befehle und Muster auf einen Blick.

---

## Ad-hoc-Befehle

```bash
# Verbindung prüfen
ansible all -m ping
ansible servers -m ping
ansible server1 -m ping

# Befehl ausführen
ansible all -m command -a "hostname"
ansible all -m shell   -a "echo $HOSTNAME"

# Datei kopieren
ansible all -m copy -a "src=/tmp/file.txt dest=/tmp/file.txt"

# Paket installieren
ansible all -m apt -a "name=htop state=present"

# Service starten
ansible all -m service -a "name=nginx state=started"

# Facts sammeln
ansible server1 -m setup
ansible server1 -m setup -a "filter=ansible_distribution*"
ansible server1 -m setup -a "filter=ansible_default_ipv4"

# Inventory anzeigen
ansible-inventory --list
ansible-inventory --graph
ansible-inventory --host server1
```

---

## `ansible-playbook`-Flags

```bash
# Syntax-Check (kein SSH, kein Ausführen)
ansible-playbook playbook.yml --syntax-check

# Dry-run (prüft via SSH, ändert nichts)
ansible-playbook playbook.yml --check

# Dry-run mit Anzeige der Änderungen
ansible-playbook playbook.yml --check --diff

# Nur auf bestimmten Hosts ausführen
ansible-playbook playbook.yml --limit server1
ansible-playbook playbook.yml --limit "server1,server2"
ansible-playbook playbook.yml --limit "servers"

# Nur bestimmte Tags ausführen
ansible-playbook playbook.yml --tags install
ansible-playbook playbook.yml --tags "install,config"
ansible-playbook playbook.yml --skip-tags cleanup

# Variable überschreiben
ansible-playbook playbook.yml -e "app_port=9090"
ansible-playbook playbook.yml -e "env=staging app_name=demo"

# Ausführlichkeit erhöhen
ansible-playbook playbook.yml -v     # verbose
ansible-playbook playbook.yml -vv    # mehr Details
ansible-playbook playbook.yml -vvv   # SSH-Debug

# Mit Vault-Passwort
ansible-playbook playbook.yml --ask-vault-pass
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass

# Ab einem bestimmten Task starten
ansible-playbook playbook.yml --start-at-task "nginx installieren"

# Tasks auflisten ohne Ausführen
ansible-playbook playbook.yml --list-tasks
ansible-playbook playbook.yml --list-tags
ansible-playbook playbook.yml --list-hosts
```

---

## Playbook-Struktur

```yaml
---
- name: "Beschreibender Play-Name"
  hosts: servers              # Zielgruppe aus dem Inventory
  become: true                # sudo-Rechte
  gather_facts: true          # Facts sammeln (Standard: true)

  vars:                       # Variablen für diesen Play
    app_port: 8080
    install_dir: /opt/app

  pre_tasks:                  # laufen VOR roles:
    - name: System aktualisieren
      ansible.builtin.apt:
        update_cache: true

  roles:                      # Rollen einbinden
    - common
    - role: webserver
      vars:
        server_port: "{{ app_port }}"

  tasks:                      # Tasks nach den Rollen
    - name: Konfiguration schreiben
      ansible.builtin.template:
        src: app.conf.j2
        dest: "{{ install_dir }}/app.conf"
      notify: App neu starten  # Handler aufrufen

  post_tasks:                 # laufen nach allen tasks
    - name: Deployment verifizieren
      ansible.builtin.uri:
        url: "http://localhost:{{ app_port }}/health"

  handlers:
    - name: App neu starten
      ansible.builtin.service:
        name: myapp
        state: restarted
```

---

## Häufige Module

### Dateien & Verzeichnisse

```yaml
# Verzeichnis erstellen
ansible.builtin.file:
  path: /opt/app
  state: directory
  mode: "0755"
  owner: www-data

# Datei löschen
ansible.builtin.file:
  path: /tmp/old.txt
  state: absent

# Datei kopieren (Inhalt direkt)
ansible.builtin.copy:
  dest: /etc/app/config.txt
  content: "port=8080\n"
  mode: "0644"

# Datei kopieren (lokale Datei → Server)
ansible.builtin.copy:
  src: files/config.txt
  dest: /etc/app/config.txt

# Template rendern und kopieren
ansible.builtin.template:
  src: templates/nginx.conf.j2
  dest: /etc/nginx/nginx.conf

# Datei vom Server holen (umgekehrtes Copy)
ansible.builtin.fetch:
  src: /var/log/app.log
  dest: logs/{{ inventory_hostname }}-app.log
  flat: true

# Zeile in Datei einfügen (idempotent)
ansible.builtin.lineinfile:
  path: /etc/hosts
  line: "10.20.0.11 server1.lab"
  state: present
```

### Pakete

```yaml
# Paket installieren (Ubuntu/Debian)
ansible.builtin.apt:
  name: nginx
  state: present
  update_cache: true

# Mehrere Pakete
ansible.builtin.apt:
  name:
    - nginx
    - curl
    - vim
  state: present

# Paket entfernen
ansible.builtin.apt:
  name: telnet
  state: absent
  purge: true

# Paket-Cache aktualisieren
ansible.builtin.apt:
  update_cache: true
  cache_valid_time: 3600    # Cache gilt 1 Stunde
```

### Services

```yaml
# Starten + Autostart
ansible.builtin.service:
  name: nginx
  state: started
  enabled: true

# Stoppen
ansible.builtin.service:
  name: nginx
  state: stopped

# Neustarten (immer)
ansible.builtin.service:
  name: nginx
  state: restarted

# Konfiguration neu laden (kein Verbindungsabbruch)
ansible.builtin.service:
  name: nginx
  state: reloaded
```

### Befehle

```yaml
# Direkter Befehl (kein Shell-Interpreter)
ansible.builtin.command: /usr/bin/myapp --init
register: result
changed_when: false

# Mit Shell-Features (Pipes, Variablen)
ansible.builtin.shell: |
  cat /etc/os-release | grep VERSION
register: os_info
changed_when: false

# Nur ausführen wenn Datei NICHT existiert (idempotent)
ansible.builtin.command: /usr/local/bin/setup.sh
args:
  creates: /opt/app/.initialized
```

### Debuggen & Ausgeben

```yaml
# Variable ausgeben
ansible.builtin.debug:
  var: ansible_hostname

# Nachricht ausgeben
ansible.builtin.debug:
  msg: "Server {{ inventory_hostname }} läuft auf {{ ansible_distribution }}"

# Nur bei Verbosity-Level >= 1 ausgeben (-v Flag)
ansible.builtin.debug:
  msg: "Debug-Info"
  verbosity: 1
```

---

## Variablen & Jinja2

```yaml
# Variable definieren
vars:
  app_name: "MeineApp"
  app_port: 8080
  server_list:
    - server1
    - server2
  db_config:
    host: db.intern
    port: 5432

# Variable verwenden
dest: "/opt/{{ app_name | lower }}"
content: "port={{ app_port }}"

# Wichtige Filter
{{ name | lower }}              # Kleinbuchstaben
{{ name | upper }}              # Großbuchstaben
{{ name | default("Fallback") }} # Fallback wenn leer
{{ liste | length }}            # Anzahl Elemente
{{ liste | join(", ") }}        # "alpha, beta, gamma"
{{ zahl | int }}                # in Integer umwandeln
{{ text | replace("alt","neu") }} # ersetzen
{{ dict | dict2items }}         # Dict → Liste von key/value
{{ "2026-06-23" | to_datetime }} # String → Datum

# Bedingung in Jinja2
{{ "ja" if ansible_distribution == "Ubuntu" else "nein" }}

# Variable zur Laufzeit setzen
ansible.builtin.set_fact:
  meine_var: "{{ ansible_hostname }}-v2"
```

---

## Schleifen

```yaml
# Einfache Liste
loop:
  - alpha
  - beta
  - gamma
# → {{ item }} = alpha, beta, gamma

# Liste von Dicts
loop:
  - { name: alice, uid: 1001 }
  - { name: bob,   uid: 1002 }
# → {{ item.name }}, {{ item.uid }}

# Variable als Liste
loop: "{{ server_list }}"

# Mit Index
loop: "{{ ['a','b','c'] | zip(range(3)) | list }}"

# loop_control: Schleifenvariable umbenennen
loop_control:
  loop_var: server    # statt "item"
  label: "{{ server }}"  # kürzere Ausgabe
```

---

## Conditionals

```yaml
# Einfache Bedingung
when: ansible_distribution == "Ubuntu"

# UND (beide müssen wahr sein)
when:
  - ansible_distribution == "Ubuntu"
  - ansible_memtotal_mb >= 512

# ODER
when: ansible_distribution == "Ubuntu" or ansible_distribution == "Debian"

# Negation
when: ansible_distribution != "CentOS"

# Variable existiert und ist nicht leer
when: my_var is defined and my_var | length > 0

# Task war changed
when: some_task.changed

# String enthält
when: "'nginx' in ansible_facts.packages"
```

---

## Roles & Scaffolding

```bash
# ─── Rollen-Scaffolding ──────────────────────────────────────
# ansible-galaxy role init ist der EINZIGE eingebaute Scaffolding-Befehl.
# Für Playbooks gibt es KEINEN eingebauten Generator – die schreibt man von Hand.

# Rolle erstellen (legt komplette Ordnerstruktur an)
ansible-galaxy role init roles/myrole

# Erzeugt:
# roles/myrole/
# ├── tasks/main.yml
# ├── handlers/main.yml
# ├── defaults/main.yml
# ├── vars/main.yml
# ├── templates/
# ├── files/
# ├── meta/main.yml
# └── README.md

# Collection erstellen (für größere Pakete)
ansible-galaxy collection init mynamespace.mycollection

# Externe Rollen installieren
ansible-galaxy role install geerlingguy.nginx
ansible-galaxy role install -r requirements.yml

# Installierte Rollen anzeigen
ansible-galaxy role list
```

---

## ansible-vault

```bash
# Datei verschlüsseln
ansible-vault encrypt secrets.yml

# Datei entschlüsseln
ansible-vault decrypt secrets.yml

# Verschlüsselte Datei anzeigen
ansible-vault view secrets.yml

# Verschlüsselte Datei editieren
ansible-vault edit secrets.yml

# Einzelne Variable verschlüsseln
ansible-vault encrypt_string 'meinPasswort' --name db_password

# Passwort ändern
ansible-vault rekey secrets.yml

# Playbook mit Vault ausführen
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

---

## ansible-lint

```bash
# Installieren
pip install ansible-lint

# Einzelnes Playbook prüfen
ansible-lint playbook.yml

# Verzeichnis prüfen
ansible-lint playbooks/

# Spezifische Regel ignorieren
ansible-lint playbook.yml --warn-list fqcn

# Mit Konfigurationsdatei (.ansible-lint)
cat .ansible-lint
# warn_list:
#   - yaml[line-length]
```

---

## Nützliche Umgebungsvariablen

```bash
# Inventory setzen
export ANSIBLE_INVENTORY=/inventory/hosts.yml

# Host-Key-Prüfung deaktivieren
export ANSIBLE_HOST_KEY_CHECKING=False

# SSH-Verbindungen wiederverwenden (schneller)
export ANSIBLE_PIPELINING=True

# Standard-Remote-User
export ANSIBLE_REMOTE_USER=root

# Vault-Passwort aus Datei
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass

# Log-Datei
export ANSIBLE_LOG_PATH=/tmp/ansible.log
```

---

## Schnell-Referenz: State-Werte

| Modul | State | Bedeutung |
|---|---|---|
| `file` | `directory` | Verzeichnis erstellen |
| `file` | `file` | Datei muss existieren |
| `file` | `absent` | Löschen |
| `file` | `link` | Symlink erstellen |
| `file` | `touch` | Erstellen / Timestamp aktualisieren |
| `apt` | `present` | Installieren (falls nicht da) |
| `apt` | `absent` | Entfernen |
| `apt` | `latest` | Installieren oder upgraden |
| `service` | `started` | Starten (falls gestoppt) |
| `service` | `stopped` | Stoppen |
| `service` | `restarted` | Immer neu starten |
| `service` | `reloaded` | Konfiguration neu laden |

---

## Scaffolding – die ehrliche Antwort

> **Gibt es einen Befehl, der Playbooks automatisch erstellt?**

**Nein** – für Playbooks gibt es keinen eingebauten Generator.
Nur für **Rollen** gibt es `ansible-galaxy role init`.

Alternativen:
- `ansible-galaxy role init` → Rollen-Ordnerstruktur (eingebaut ✅)
- `ansible-galaxy collection init` → Collection-Struktur (eingebaut ✅)
- [Cookiecutter](https://github.com/cookiecutter/cookiecutter) mit Ansible-Templates → Community-Tool
- Eigenes Template-Verzeichnis im Team pflegen → pragmatische Lösung

**Empfehlung für Playbooks:** Halte ein `template.yml` im Projekt:

```yaml
---
# template.yml — Kopieren und umbenennen
- name: ""
  hosts: servers
  gather_facts: true

  vars: {}

  tasks:
    - name: ""
      ansible.builtin.debug:
        msg: "TODO"
```

Dann einfach:
```bash
cp playbooks/template.yml playbooks/mein-neues-playbook.yml
```
