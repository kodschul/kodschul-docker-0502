# 09 – Best Practices

**Lernziel:** Ansible-Playbooks professionell schreiben – wartbar, sicher und fehlertolerant.
**Playbook:** `13-best-practices.yml`

---

## 1. Fully Qualified Collection Names (FQCN)

Immer den vollständigen Modul-Namen schreiben – mit Namespace und Collection:

```yaml
# ❌ Kurzform (funktioniert, aber veraltet und mehrdeutig)
- apt:
    name: curl

# ✅ FQCN (empfohlen seit Ansible 2.10)
- ansible.builtin.apt:
    name: curl
```

Warum? Wenn du externe Collections installierst, könnten Modul-Namen kollidieren.
FQCN macht immer klar, welches Modul gemeint ist.

```
ansible.builtin.apt     → Ansible-Kern (builtin)
community.general.ufw   → Community-Collection
ansible.posix.authorized_key → POSIX-Collection
```

---

## 2. `changed_when` – keine falschen Positiv-Meldungen

Das `command`- und `shell`-Modul melden immer `changed=true`, egal was passiert.
Mit `changed_when` steuerst du das präzise:

```yaml
# ❌ Meldet immer changed – auch wenn nichts passiert ist
- ansible.builtin.command: date

# ✅ Korrekt: Datum lesen ändert nie etwas
- ansible.builtin.command: date
  register: datum
  changed_when: false

# ✅ Nur changed wenn der Exit-Code etwas bestimmtes ist
- ansible.builtin.shell: ./deploy.sh
  register: result
  changed_when: result.rc == 0 and "deployed" in result.stdout
```

---

## 3. `failed_when` – eigene Fehler-Bedingungen

```yaml
# ❌ Schlägt fehl bei jedem Nicht-Null-Exit-Code
- ansible.builtin.shell: check_service.sh

# ✅ Nur fehlschlagen wenn ein kritisches Stichwort auftaucht
- ansible.builtin.shell: check_service.sh
  register: result
  failed_when:
    - result.rc != 0
    - "'CRITICAL' in result.stdout"
```

---

## 4. Tags – selektiv ausführen

Tags erlauben es, nur Teile eines Playbooks auszuführen:

```yaml
tasks:
  - name: System aktualisieren
    ansible.builtin.apt:
      upgrade: dist
    tags: update           # ← Tag vergeben

  - name: nginx installieren
    ansible.builtin.apt:
      name: nginx
    tags:
      - install
      - webserver          # ← mehrere Tags möglich

  - name: Altes Verzeichnis löschen
    ansible.builtin.file:
      path: /tmp/old
      state: absent
    tags:
      - cleanup
      - never              # ← 'never': wird standardmäßig ÜBERSPRUNGEN
```

```bash
# Nur Update-Tasks ausführen
ansible-playbook playbook.yml --tags update

# Nur Install- und Webserver-Tasks
ansible-playbook playbook.yml --tags "install,webserver"

# Cleanup explizit ausführen (hat 'never'-Tag)
ansible-playbook playbook.yml --tags cleanup

# Update überspringen
ansible-playbook playbook.yml --skip-tags update

# Welche Tags existieren im Playbook?
ansible-playbook playbook.yml --list-tags
```

---

## 5. Blocks – Fehlerbehandlung wie try/catch

```yaml
tasks:
  - name: Deployment mit Fehlerbehandlung
    block:
      # Alles hier ist der "try"-Block
      - name: Config deployen
        ansible.builtin.copy:
          dest: /etc/app/config.yml
          src: config.yml

      - name: Service neu starten
        ansible.builtin.service:
          name: myapp
          state: restarted

    rescue:
      # Läuft nur wenn etwas im block fehlschlägt (wie "catch")
      - name: Rollback: alte Config wiederherstellen
        ansible.builtin.copy:
          dest: /etc/app/config.yml
          src: config.yml.bak

    always:
      # Läuft immer – egal ob Erfolg oder Fehler (wie "finally")
      - name: Deployment-Log schreiben
        ansible.builtin.copy:
          dest: /var/log/deploy.log
          content: "Deployment um {{ ansible_date_time.iso8601 }}"
```

---

## 6. `no_log` – Secrets verstecken

```yaml
- name: Datenbankpasswort setzen
  ansible.builtin.command: mysql -u root -p"{{ db_password }}" -e "..."
  no_log: true    # ← Parameter werden NICHT in der Ausgabe angezeigt
```

Ohne `no_log` würde das Passwort im Terminal und in Log-Dateien erscheinen.

---

## 7. `ansible.builtin.assert` – Voraussetzungen prüfen

Fail fast mit einer klaren Fehlermeldung, bevor etwas kaputt geht:

```yaml
- name: Voraussetzungen prüfen
  ansible.builtin.assert:
    that:
      - ansible_distribution == "Ubuntu"
      - ansible_memtotal_mb >= 512
    fail_msg: "Dieses Playbook benötigt Ubuntu mit min. 512 MB RAM!"
    success_msg: "Voraussetzungen erfüllt."
```

---

## 8. Naming Convention

**Beschreibende Task-Namen** helfen beim Lesen langer Ausgaben:

```yaml
# ❌ Schlecht
- name: Task 1
- name: apt
- name: config

# ✅ Gut: [BEREICH | AKTION | WAS/WO]
- name: "SETUP    | nginx installieren"
- name: "CONFIG   | nginx.conf deployen nach /etc/nginx/"
- name: "VERIFY   | nginx antwortet auf Port 80"
- name: "CLEANUP  | temporäre Dateien löschen"
```

---

## 9. `ansible-vault` – Secrets verschlüsseln

Passwörter und Keys **niemals** im Klartext in Playbooks:

```bash
# Einzelne Variable verschlüsseln
ansible-vault encrypt_string 'meinGeheimesPasswort' --name db_password
# → db_password: !vault | $ANSIBLE_VAULT;1.1;AES256 ...

# Ganze Datei verschlüsseln
ansible-vault encrypt group_vars/all/secrets.yml

# Verschlüsselte Datei editieren
ansible-vault edit group_vars/all/secrets.yml

# Playbook mit Vault ausführen
ansible-playbook playbook.yml --ask-vault-pass
# oder:
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

---

## 10. `ansible-lint` – Playbooks statisch prüfen

```bash
# Installation (auf dem Control Node oder lokal)
pip install ansible-lint

# Playbook prüfen
ansible-lint playbook.yml

# Alle Playbooks im Verzeichnis prüfen
ansible-lint playbooks/
```

`ansible-lint` findet häufige Fehler:
- Fehlende FQCN
- Tasks ohne `name:`
- `become: yes` ohne Begründung
- `shell:` wo `command:` reicht

---

## 11. Projektstruktur für größere Projekte

```
mein-ansible-projekt/
├── ansible.cfg           ← Konfiguration
├── inventory/
│   ├── production/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── staging/
│       └── hosts.yml
├── roles/
│   ├── common/
│   ├── webserver/
│   └── database/
├── group_vars/
│   └── all/
│       ├── vars.yml      ← nicht-geheime Variablen
│       └── secrets.yml   ← mit ansible-vault verschlüsselt
├── playbooks/
│   ├── site.yml          ← Haupt-Playbook
│   ├── webservers.yml
│   └── databases.yml
└── requirements.yml      ← externe Rollen/Collections
```

---

## Playbook ausführen

```bash
# Nur Preflight-Checks
ansible-playbook /playbooks/13-best-practices.yml --tags preflight

# Setup und Verify (ohne Cleanup)
ansible-playbook /playbooks/13-best-practices.yml --tags "setup,verify"

# Alles inklusive Cleanup
ansible-playbook /playbooks/13-best-practices.yml --tags "setup,verify,cleanup"

# Dry-run mit Diff-Ansicht
ansible-playbook /playbooks/13-best-practices.yml --check --diff
```

---

## Verständnisfragen

**1. Warum sollte man FQCN verwenden statt der Kurzform?**
> FQCN (`ansible.builtin.apt` statt `apt`) verhindert Namens-Kollisionen wenn externe
> Collections installiert sind und macht klar, aus welcher Collection das Modul stammt.
> `ansible-lint` warnt, wenn FQCN fehlt.

**2. Wann verwende ich `changed_when: false` und wann `changed_when: result.rc == 0`?**
> `changed_when: false` → wenn der Task **nie** etwas ändert (z.B. `date`, `cat`, `uptime`).
> `changed_when: bedingung` → wenn der Task **manchmal** ändert und du es präzise steuern willst.

**3. Was ist der Unterschied zwischen `rescue:` und `always:` in einem Block?**
> `rescue:` läuft **nur bei Fehler** im Block (wie `catch`).
> `always:` läuft **immer** – egal ob Erfolg oder Fehler (wie `finally`).

**4. Wozu dient der Tag-Wert `never`?**
> Ein Task mit `tags: never` wird beim normalen Ausführen **immer übersprungen**.
> Er läuft nur wenn er **explizit** mit `--tags cleanup` (oder dem jeweiligen Namen) aufgerufen wird.
> Ideal für destruktive Aktionen wie Löschen oder Reset.

---

## Nächster Schritt

→ [10 – Cheatsheet](10-cheatsheet.md)
