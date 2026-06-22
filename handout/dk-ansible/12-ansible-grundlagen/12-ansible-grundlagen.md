# 12 – Grundlagen und Aufbau von Ansible

**Block:** 90 min | **Tag 3**

---

## Was ist Ansible?

Ansible ist ein **agentenloses Automatisierungswerkzeug** für Konfigurationsmanagement, Deployment und Orchestrierung. Es kommuniziert über SSH – kein Agent, kein Daemon auf dem Ziel-Host nötig.

```
Ansible Control Node (dein Rechner)
├── SSH-Verbindung
│     ├── → Host 1 (Ubuntu)
│     ├── → Host 2 (Rocky Linux)
│     └── → Host 3 (Debian)
└── führt temporäre Python-Module aus, räumt auf
```

> **Analogie:** Ansible ist wie ein Dirigent – er kennt alle Musiker (Hosts), weiß was jeder tun soll (Tasks), und koordiniert alles von einem Pult aus.

---

## Lab 12.1 – Das agentenlose Konzept

### Voraussetzungen

```bash
# Control Node (nur hier wird Ansible installiert)
pip install ansible               # oder:
brew install ansible              # macOS

# Managed Hosts brauchen nur:
# - SSH-Zugang
# - Python 3 (meist vorinstalliert)
# - sudo-Rechte (für privilegierte Tasks)

# Verbindung testen
ansible all -i "host1,host2," -m ping

# Mit passwort
ansible all -i inventory.ini -m ping --ask-pass
```

### Vorteile gegenüber anderen Tools

| Aspekt        | Ansible        | Chef/Puppet     | Salt      |
| ------------- | -------------- | --------------- | --------- |
| Agent nötig   | nein (SSH)     | ja              | optional  |
| Lernkurve     | niedrig (YAML) | hoch (Ruby/DSL) | mittel    |
| Pull vs. Push | Push           | Pull            | Push+Pull |
| Idempotenz    | eingebaut      | eingebaut       | eingebaut |

---

## Lab 12.2 – YAML-basierte Playbooks

### Playbook-Struktur

```yaml
# site.yml – ein vollständiges Playbook
---
- name: Webserver einrichten # beschreibender Name des Plays
  hosts: webservers # Zielgruppe aus Inventory
  become: yes # sudo-Rechte
  vars:
    nginx_port: 80
    app_user: www-data

  tasks:
    - name: nginx installieren
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: yes

    - name: nginx starten und aktivieren
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes

    - name: nginx-Konfiguration kopieren
      ansible.builtin.template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: "0644"
      notify: nginx neu laden # → Handler aufrufen

  handlers:
    - name: nginx neu laden
      ansible.builtin.service:
        name: nginx
        state: reloaded
```

### Playbook ausführen

```bash
# Syntax prüfen
ansible-playbook site.yml --syntax-check

# Dry-run (kein tatsächliche Änderung)
ansible-playbook site.yml --check

# Diff anzeigen
ansible-playbook site.yml --check --diff

# Ausführen
ansible-playbook -i inventory.ini site.yml

# Nur bestimmte Tags ausführen
ansible-playbook site.yml --tags nginx

# Bestimmte Hosts überspringen
ansible-playbook site.yml --limit "!db-servers"

# Verbose-Ausgabe
ansible-playbook site.yml -v    # -vv oder -vvv für mehr Details
```

---

## Lab 12.3 – Inventories

### Statisches Inventory (INI-Format)

```ini
# inventory.ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[dbservers]
db1 ansible_host=192.168.1.20 ansible_user=dbadmin

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3

[webservers:vars]
nginx_port=80
```

### YAML-Inventory

```yaml
# inventory.yml
all:
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11
    dbservers:
      hosts:
        db1:
          ansible_host: 192.168.1.20
```

### Inventory-Befehle

```bash
# Inventory prüfen
ansible-inventory -i inventory.ini --list
ansible-inventory -i inventory.ini --graph

# Ping gegen alle Hosts
ansible all -i inventory.ini -m ping

# Nur eine Gruppe
ansible webservers -i inventory.ini -m ping
```

---

## Lab 12.4 – Module und Tasks

### Häufig verwendete Module

```yaml
# Paketinstallation
- name: Pakete installieren
  ansible.builtin.apt: # Ubuntu/Debian
    name:
      - nginx
      - curl
      - git
    state: present
    update_cache: yes

- name: Pakete installieren (RHEL)
  ansible.builtin.dnf:
    name: nginx
    state: present

# Service-Management
- name: Service starten
  ansible.builtin.service:
    name: nginx
    state: started # started | stopped | restarted | reloaded
    enabled: yes # Autostart beim Boot

# Datei-Operationen
- name: Verzeichnis anlegen
  ansible.builtin.file:
    path: /var/www/myapp
    state: directory # directory | file | absent | link | touch
    owner: www-data
    group: www-data
    mode: "0755"

- name: Datei kopieren
  ansible.builtin.copy:
    src: files/index.html
    dest: /var/www/html/index.html

- name: Template deployen
  ansible.builtin.template:
    src: templates/app.conf.j2 # Jinja2-Template
    dest: /etc/app/app.conf

# Benutzer und Gruppen
- name: Benutzer anlegen
  ansible.builtin.user:
    name: appuser
    groups: sudo
    shell: /bin/bash
    create_home: yes

# SSH-Key deployen
- name: SSH-Key hinzufügen
  ansible.builtin.authorized_key:
    user: ubuntu
    key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"
    state: present

# Befehle ausführen (nur wenn kein Modul existiert)
- name: Eigenes Skript ausführen
  ansible.builtin.command:
    cmd: /opt/scripts/setup.sh
    creates: /opt/.setup-done # idempotent: nur wenn Datei fehlt
```

### Conditionals und Loops

```yaml
# Bedingung
- name: nginx nur auf Ubuntu installieren
  ansible.builtin.apt:
    name: nginx
  when: ansible_os_family == "Debian"

# Loop
- name: Mehrere Pakete installieren
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - curl
    - git

# Loop mit Dictionary
- name: Benutzer anlegen
  ansible.builtin.user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - { name: alice, groups: sudo }
    - { name: bob, groups: www-data }
```

---

## Zusammenfassung

```
Ansible
├── agentelos (nur SSH + Python auf Hosts)
├── deklarativ (YAML-Playbooks)
└── idempotent (Tasks prüfen vor Ausführung)

Playbook
├── plays     → Gruppe von Hosts + Tasks
├── tasks     → einzelne Aktionen
└── handlers  → Tasks bei Änderung aufrufen

Inventory
├── INI oder YAML
├── Gruppen und Variablen
└── ansible-inventory --list

Module
├── apt / dnf    → Pakete
├── service      → Services
├── file / copy  → Dateien
└── user         → Benutzer
```
