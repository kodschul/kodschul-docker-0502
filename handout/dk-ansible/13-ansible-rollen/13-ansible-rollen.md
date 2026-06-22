# 13 – Wiederverwendbare Ansible-Strukturen

**Block:** 90 min | **Tag 3**

---

## Lab 13.1 – Rollen und Wiederverwendbarkeit

### Was ist eine Rolle?

Eine Rolle ist eine **strukturierte, wiederverwendbare Sammlung** von Tasks, Variablen, Templates und Dateien – für einen bestimmten Zweck (z.B. "nginx installieren und konfigurieren").

```
roles/
└── nginx/
    ├── tasks/
    │   └── main.yml        ← Aufgaben (Tasks)
    ├── handlers/
    │   └── main.yml        ← Handler (bei Änderung)
    ├── templates/
    │   └── nginx.conf.j2   ← Jinja2-Templates
    ├── files/
    │   └── index.html      ← statische Dateien
    ├── vars/
    │   └── main.yml        ← interne Variablen (hohe Priorität)
    ├── defaults/
    │   └── main.yml        ← Standardwerte (niedrige Priorität)
    └── meta/
        └── main.yml        ← Abhängigkeiten zu anderen Rollen
```

### Rolle erstellen

```bash
# Struktur automatisch anlegen
ansible-galaxy role init roles/nginx
ansible-galaxy role init roles/postgresql
```

### Rolle nutzen

```yaml
# site.yml
---
- name: Webserver einrichten
  hosts: webservers
  become: yes
  roles:
    - nginx # einfache Einbindung
    - role: postgresql # mit Variablen überschreiben
      vars:
        pg_version: "16"
    - role: common
      tags: common
```

### Beispiel: nginx-Rolle

```yaml
# roles/nginx/defaults/main.yml
nginx_port: 80
nginx_server_name: "localhost"
nginx_worker_processes: "auto"
nginx_document_root: /var/www/html
```

```yaml
# roles/nginx/tasks/main.yml
---
- name: nginx installieren
  ansible.builtin.apt:
    name: nginx
    state: present
    update_cache: yes

- name: nginx konfigurieren
  ansible.builtin.template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: nginx reload

- name: nginx starten
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: yes
```

```yaml
# roles/nginx/handlers/main.yml
---
- name: nginx reload
  ansible.builtin.service:
    name: nginx
    state: reloaded
```

```nginx
# roles/nginx/templates/nginx.conf.j2
worker_processes {{ nginx_worker_processes }};

events {
    worker_connections 1024;
}

http {
    server {
        listen {{ nginx_port }};
        server_name {{ nginx_server_name }};
        root {{ nginx_document_root }};
    }
}
```

### Ansible Galaxy – fertige Rollen

```bash
# Rolle aus Galaxy installieren
ansible-galaxy role install geerlingguy.nginx
ansible-galaxy role install geerlingguy.postgresql

# In requirements.yml definieren (empfohlen)
cat requirements.yml
# roles:
#   - name: geerlingguy.nginx
#   - name: geerlingguy.docker
#     version: "6.1.0"

# Alle Rollen aus requirements.yml installieren
ansible-galaxy install -r requirements.yml
```

---

## Lab 13.2 – Variablen und Templates

### Variablen-Priorität (vereinfacht, niedrig → hoch)

```
1. Role defaults (defaults/main.yml)
2. Inventory vars
3. Playbook vars
4. Role vars (vars/main.yml)
5. Task vars (vars: im Task)
6. Extra vars (-e auf CLI)       ← höchste Priorität
```

```bash
# Extra vars überschreiben alles
ansible-playbook site.yml -e "nginx_port=8080"
ansible-playbook site.yml -e "@overrides.yml"   # aus Datei
```

### Host und Group Variablen

```
inventory/
├── inventory.ini
├── host_vars/
│   ├── web1.yml       ← Variablen nur für web1
│   └── db1.yml
└── group_vars/
    ├── all.yml        ← für alle Hosts
    ├── webservers.yml ← für Gruppe webservers
    └── dbservers.yml
```

```yaml
# group_vars/webservers.yml
nginx_port: 80
app_user: www-data
deploy_path: /var/www

# group_vars/all.yml
ntp_server: pool.ntp.org
timezone: Europe/Berlin
```

### Jinja2-Templates

```jinja2
{# templates/app.conf.j2 #}

# Generiert von Ansible – nicht manuell bearbeiten!
# Host: {{ inventory_hostname }}
# Stand: {{ ansible_date_time.date }}

[server]
host = {{ ansible_default_ipv4.address }}
port = {{ app_port | default(8080) }}
env  = {{ app_environment | upper }}

{% if enable_ssl | default(false) %}
ssl_cert = /etc/ssl/certs/{{ inventory_hostname }}.crt
ssl_key  = /etc/ssl/private/{{ inventory_hostname }}.key
{% endif %}

[database]
{% for db in databases %}
{{ db.name }} = {{ db.host }}:{{ db.port }}
{% endfor %}
```

### Ansible Facts nutzen

```yaml
# Facts werden automatisch gesammelt (gather_facts: yes)
- debug:
    msg: "OS: {{ ansible_os_family }}, IP: {{ ansible_default_ipv4.address }}"

# Facts manuell abfragen
ansible web1 -i inventory.ini -m setup
ansible web1 -i inventory.ini -m setup -a "filter=ansible_memory_mb"
```

---

## Lab 13.3 – Standardpakete und Infrastrukturkomponenten

### Beispiel: Samba-Rolle

```yaml
# roles/samba/tasks/main.yml
---
- name: Samba installieren
  ansible.builtin.apt:
    name:
      - samba
      - samba-common
    state: present

- name: Samba-Konfiguration deployen
  ansible.builtin.template:
    src: smb.conf.j2
    dest: /etc/samba/smb.conf
  notify: samba restart

- name: Samba-Benutzer anlegen
  ansible.builtin.shell:
    cmd: "echo -e '{{ item.password }}\n{{ item.password }}' | smbpasswd -a {{ item.name }}"
  loop: "{{ samba_users }}"
  no_log: true # Passwörter nicht in Logs anzeigen!

- name: Samba starten
  ansible.builtin.service:
    name: smbd
    state: started
    enabled: yes
```

### Beispiel: SSH-Keys verteilen

```yaml
# roles/ssh-keys/tasks/main.yml
---
- name: SSH-Keys für Benutzer deployen
  ansible.builtin.authorized_key:
    user: "{{ item.user }}"
    key: "{{ item.key }}"
    state: present
  loop: "{{ ssh_keys }}"
```

```yaml
# group_vars/all.yml
ssh_keys:
  - user: ubuntu
    key: "ssh-ed25519 AAAA... franz@laptop"
  - user: ubuntu
    key: "ssh-ed25519 AAAA... admin@ci-server"
```

### Ansible Vault – Secrets verschlüsseln

```bash
# Datei verschlüsseln
ansible-vault encrypt group_vars/all/secrets.yml

# Verschlüsselte Datei bearbeiten
ansible-vault edit group_vars/all/secrets.yml

# Einzelne Variable verschlüsseln
ansible-vault encrypt_string 'geheim123' --name 'db_password'
# → db_password: !vault | $ANSIBLE_VAULT;1.1;AES256 ...

# Playbook mit Vault ausführen
ansible-playbook site.yml --ask-vault-pass
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

```yaml
# secrets.yml (verschlüsselt in Git speicherbar)
db_password: "{{ vault_db_password }}"
ldap_bind_password: "{{ vault_ldap_bind_password }}"
```

### Beispiel: LDAP / Active Directory

```yaml
# roles/ldap-client/tasks/main.yml
---
- name: LDAP-Client-Pakete installieren
  ansible.builtin.apt:
    name:
      - libpam-ldapd
      - libnss-ldapd
      - nslcd
    state: present

- name: LDAP-Konfiguration deployen
  ansible.builtin.template:
    src: nslcd.conf.j2
    dest: /etc/nslcd.conf
    mode: "0600"
  notify: nslcd restart

- name: nsswitch.conf anpassen
  ansible.builtin.lineinfile:
    path: /etc/nsswitch.conf
    regexp: "^passwd:"
    line: "passwd: compat ldap"
```

---

## Zusammenfassung

```
Rollen
├── ansible-galaxy role init → Struktur anlegen
├── defaults/main.yml  → überschreibbare Defaults
├── tasks/main.yml     → Aufgaben
├── templates/*.j2     → Jinja2-Templates
└── handlers/main.yml  → bei Änderung aufrufen

Variablen
├── group_vars/all.yml      → alle Hosts
├── group_vars/<gruppe>.yml → Gruppe
├── host_vars/<host>.yml    → einzelner Host
└── -e "key=value"          → höchste Priorität

Templates (Jinja2)
├── {{ variable }}
├── {% if ... %} / {% endif %}
└── {% for item in liste %} / {% endfor %}

Vault
├── ansible-vault encrypt
├── ansible-vault edit
└── --ask-vault-pass beim Ausführen
```
