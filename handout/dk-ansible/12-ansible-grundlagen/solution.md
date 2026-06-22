# Lösung: Ansible Grundlagen

---

## Aufgabe 1

```bash
ansible-inventory -i inventory.ini --list
# {
#   "_meta": { "hostvars": { "localhost": {} } },
#   "all": { "children": ["ungrouped", "webservers"] },
#   "webservers": { "hosts": ["localhost"] }
# }

ansible all -i inventory.ini -m ping
# localhost | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }

ansible all -i inventory.ini -m command -a "hostname"
# localhost | CHANGED | rc=0 >>
# meinrechner.local

ansible all -i inventory.ini -m setup -a "filter=ansible_os_family"
# localhost | SUCCESS => {
#     "ansible_facts": { "ansible_os_family": "Darwin" }  # macOS
# }
```

---

## Aufgabe 2

```bash
ansible-playbook -i inventory.ini setup.yml --syntax-check
# playbook: setup.yml  ← keine Fehler

ansible-playbook -i inventory.ini setup.yml --check
# TASK [Verzeichnis anlegen] → ok (check mode, kein Schreiben)

ansible-playbook -i inventory.ini setup.yml

# PLAY RECAP:
# localhost : ok=5  changed=3  unreachable=0  failed=0
```

**Ausgabe des letzten Tasks:**

```
TASK [Ergebnis anzeigen] *****
ok: [localhost] => {
    "file_content.stdout": "Ansible-Kurs\nErstellt: 2026-06-22\nHost: localhost"
}
```

---

## Aufgabe 3

```bash
# Erstes Ausführen:
ansible-playbook -i inventory.ini setup.yml
# TASK [Zeile zu info.txt hinzufügen] → changed: [localhost]
# PLAY RECAP: ok=5  changed=4

# Zweites Ausführen (identisch):
ansible-playbook -i inventory.ini setup.yml
# TASK [Zeile zu info.txt hinzufügen] → ok: [localhost]
# PLAY RECAP: ok=6  changed=0   ← keine Änderungen!
```

**Antwort: changed vs. ok**

- `changed`: Task hat eine tatsächliche Änderung am System vorgenommen
- `ok`: Task wurde ausgeführt, System war bereits im gewünschten Zustand → **Idempotenz in Aktion**

`lineinfile` prüft vor dem Schreiben ob die Zeile bereits vorhanden ist. Wenn ja: keine Änderung, Status `ok`.
