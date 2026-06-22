# Übung: Ansible Grundlagen

**Zeit:** 30 min

---

## Aufgabe 1 – Inventory und Ping (10 min)

Erstelle eine `inventory.ini`:

```ini
[webservers]
localhost ansible_connection=local
```

```bash
# 1. Inventory prüfen
ansible-inventory -i inventory.ini --list

# 2. Verbindung testen
ansible all -i inventory.ini -m ping

# 3. Ad-hoc: Hostname abfragen
ansible all -i inventory.ini -m command -a "hostname"

# 4. Ad-hoc: Uptime
ansible all -i inventory.ini -m command -a "uptime"

# 5. Facts sammeln
ansible all -i inventory.ini -m setup -a "filter=ansible_os_family"
ansible all -i inventory.ini -m setup -a "filter=ansible_distribution*"
```

---

## Aufgabe 2 – Erstes Playbook (10 min)

Erstelle `setup.yml`:

```yaml
---
- name: System-Infos anzeigen
  hosts: all
  gather_facts: yes

  tasks:
    - name: Betriebssystem ausgeben
      ansible.builtin.debug:
        msg: "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"

    - name: Verzeichnis anlegen
      ansible.builtin.file:
        path: /tmp/ansible-kurs
        state: directory
        mode: "0755"

    - name: Info-Datei erstellen
      ansible.builtin.copy:
        content: |
          Ansible-Kurs
          Erstellt: {{ ansible_date_time.date }}
          Host: {{ inventory_hostname }}
        dest: /tmp/ansible-kurs/info.txt

    - name: Datei-Inhalt ausgeben
      ansible.builtin.command:
        cmd: cat /tmp/ansible-kurs/info.txt
      register: file_content

    - name: Ergebnis anzeigen
      ansible.builtin.debug:
        var: file_content.stdout
```

```bash
# Syntax prüfen
ansible-playbook -i inventory.ini setup.yml --syntax-check

# Dry-run
ansible-playbook -i inventory.ini setup.yml --check

# Ausführen
ansible-playbook -i inventory.ini setup.yml
```

---

## Aufgabe 3 – Idempotenz testen (10 min)

Füge dem Playbook einen weiteren Task hinzu:

```yaml
- name: Zeile zu info.txt hinzufügen (nur wenn fehlt)
  ansible.builtin.lineinfile:
    path: /tmp/ansible-kurs/info.txt
    line: "Ansible ist idempotent!"
    state: present
```

```bash
# Playbook zweimal ausführen und die Ausgabe vergleichen
ansible-playbook -i inventory.ini setup.yml
ansible-playbook -i inventory.ini setup.yml

# Frage: Was ist der Unterschied zwischen "changed" und "ok"?
```
