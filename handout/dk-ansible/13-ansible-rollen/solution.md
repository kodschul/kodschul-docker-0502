# Lösung: Ansible Rollen und Wiederverwendbarkeit

---

## Aufgabe 1

```bash
ansible-galaxy role init roles/common
# - Role roles/common was created successfully
```

```yaml
# roles/common/defaults/main.yml
common_packages:
  - curl
  - vim
  - git
  - htop
app_directory: /opt/app
motd_message: "Konfiguriert von Ansible"
```

```yaml
# roles/common/tasks/main.yml
---
- name: Pakete installieren
  ansible.builtin.package: # package: funktioniert für apt UND dnf
    name: "{{ common_packages }}"
    state: present

- name: App-Verzeichnis anlegen
  ansible.builtin.file:
    path: "{{ app_directory }}"
    state: directory
    mode: "0755"

- name: MOTD schreiben
  ansible.builtin.copy:
    content: "{{ motd_message }}\n"
    dest: /etc/motd
```

```bash
ansible-playbook -i inventory.ini site.yml
# TASK [common : Pakete installieren] → changed
# TASK [common : App-Verzeichnis anlegen] → changed
# TASK [common : MOTD schreiben] → changed
# PLAY RECAP: ok=4 changed=3
```

---

## Aufgabe 2

```jinja2
{# roles/common/templates/motd.j2 #}
{{ motd_message }}
Host: {{ inventory_hostname }}
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Datum: {{ ansible_date_time.date }}
```

```yaml
# roles/common/tasks/main.yml – Task ändern:
- name: MOTD aus Template deployen
  ansible.builtin.template:
    src: motd.j2
    dest: /etc/motd
```

```bash
ansible-playbook -i inventory.ini site.yml --diff
# --- before: /etc/motd
# +++ after: /etc/motd
# @@ -1 +1,4 @@
# -Konfiguriert von Ansible
# +Konfiguriert von Ansible
# +Host: localhost
# +OS: macOS 14.5
# +Datum: 2026-06-22
```

---

## Aufgabe 3

```yaml
# site.yml
---
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
# --- before: /etc/motd
# +++ after: /etc/motd
# @@ -1 +1,4 @@
# -Konfiguriert von Ansible
# +Willkommen auf dem Kurs-Server!   ← Playbook-Variable gewinnt

cat /etc/motd
# Willkommen auf dem Kurs-Server!
# Host: localhost
# OS: macOS 14.5
# Datum: 2026-06-22
```

**Variablen-Priorität bestätigt:** Playbook `vars:` überschreibt Role `defaults/main.yml`.
