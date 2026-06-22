# Übung: Ansible Rollen und Wiederverwendbarkeit

**Zeit:** 30 min

---

## Aufgabe 1 – Rolle erstellen (15 min)

Erstelle eine Ansible-Rolle `common`, die grundlegende System-Konfigurationen vornimmt:

```bash
# Struktur anlegen
ansible-galaxy role init roles/common
```

**Aufgaben für die Rolle** (`roles/common/tasks/main.yml`):

1. Nützliche Pakete installieren: `curl`, `vim`, `git`, `htop`
2. Arbeitsverzeichnis `/opt/app` anlegen
3. Datei `/etc/motd` mit dem Inhalt `"Konfiguriert von Ansible"` schreiben

**Defaults** (`roles/common/defaults/main.yml`):

```yaml
common_packages:
  - curl
  - vim
  - git
  - htop
app_directory: /opt/app
motd_message: "Konfiguriert von Ansible"
```

**Playbook** (`site.yml`):

```yaml
---
- name: Basissetup
  hosts: all
  become: yes
  roles:
    - common
```

```bash
ansible-playbook -i inventory.ini site.yml
```

---

## Aufgabe 2 – Template nutzen (10 min)

Erweitere die `common`-Rolle um ein Jinja2-Template für `/etc/motd`:

**`roles/common/templates/motd.j2`:**

```
{{ motd_message }}
Host: {{ inventory_hostname }}
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Datum: {{ ansible_date_time.date }}
```

Ändere den Task von `copy` auf `template`:

```yaml
- name: MOTD aus Template deployen
  ansible.builtin.template:
    src: motd.j2
    dest: /etc/motd
```

```bash
ansible-playbook -i inventory.ini site.yml --diff
# → Zeigt den genauen Datei-Inhalt der geschrieben wird
```

---

## Aufgabe 3 – Variablen überschreiben (5 min)

Überschreibe `motd_message` auf Playbook-Ebene:

```yaml
# site.yml
- name: Basissetup
  hosts: all
  become: yes
  vars:
    motd_message: "Willkommen auf dem Kurs-Server!"
  roles:
    - common
```

```bash
ansible-playbook -i inventory.ini site.yml --diff
# Welcher Wert steht jetzt in /etc/motd?
cat /etc/motd
```
