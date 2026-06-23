# 08 – Rollen (Roles)

**Lernziel:** Playbooks in wiederverwendbare, strukturierte Einheiten aufteilen.
**Playbook:** `08-roles.yml`

---

## Das Problem mit langen Playbooks

Wenn du 5 verschiedene Server-Typen hast (Webserver, Datenbankserver,
Monitoring, Load Balancer, Cache), wird ein einzelnes Playbook schnell
unübersichtlich:

```yaml
# ❌ Ein riesiges Playbook
tasks:
  - name: nginx installieren     # Webserver-Zeug
  - name: nginx konfigurieren
  - name: nginx starten
  - name: postgres installieren  # Datenbank-Zeug
  - name: postgres konfigurieren
  - name: postgres starten
  - name: redis installieren     # Cache-Zeug
  ...  # 200 Tasks in einer Datei
```

---

## Die Lösung: Rollen

Eine Rolle ist ein **eigenständiges Paket** für einen bestimmten Zweck.
Statt alles in ein Playbook zu packen, erstellst du z.B.:

```
roles/
├── webserver/    → alles für nginx
├── database/     → alles für PostgreSQL
└── common/       → Basis-Pakete für alle Server
```

Das Playbook kombiniert dann einfach nur noch:

```yaml
# ✅ Kurzes, lesbares Playbook
- name: Webserver einrichten
  hosts: webservers
  roles:
    - common
    - webserver
```

---

## Ordnerstruktur einer Rolle

```
roles/webserver/
├── tasks/
│   └── main.yml        ← die Aufgaben (Tasks)
├── handlers/
│   └── main.yml        ← Handler (z.B. "Reload nginx")
├── defaults/
│   └── main.yml        ← Standard-Variablen (niedrigste Priorität)
├── vars/
│   └── main.yml        ← fixe Rollen-Variablen (hohe Priorität)
├── templates/
│   └── nginx.conf.j2   ← Jinja2-Templates
├── files/
│   └── index.html      ← statische Dateien
└── meta/
    └── main.yml        ← Metadaten und Abhängigkeiten
```

Ansible lädt automatisch alle `main.yml`-Dateien – du musst nichts
explizit importieren.

---

## Eine Rolle erstellen

### Manuell

```bash
mkdir -p roles/meinerolle/{tasks,handlers,defaults,templates,files}
touch roles/meinerolle/tasks/main.yml
touch roles/meinerolle/handlers/main.yml
touch roles/meinerolle/defaults/main.yml
```

### Mit ansible-galaxy (empfohlen)

```bash
ansible-galaxy role init roles/meinerolle
# Erstellt die komplette Ordnerstruktur automatisch
```

---

## Die `common`-Rolle im Labor

Schau dir die Rolle an (im VS Code):

```
playbooks/roles/common/
├── tasks/main.yml      → installiert Basis-Pakete, erstellt Verzeichnis
└── defaults/main.yml   → definiert Variablen wie "managed_dir"
```

```yaml
# roles/common/defaults/main.yml
managed_by: "Ansible"
managed_dir: "/opt/managed"
```

```yaml
# roles/common/tasks/main.yml
- name: "[common] Baseline-Pakete installieren"
  ansible.builtin.apt:
    name:
      - curl
      - vim
      - tree
      - htop
    state: present

- name: "[common] Managed-Verzeichnis erstellen"
  ansible.builtin.file:
    path: "{{ managed_dir }}"   # Variable aus defaults/main.yml
    state: directory
    mode: '0755'
```

---

## Die `webserver`-Rolle im Labor

```
playbooks/roles/webserver/
├── tasks/main.yml       → nginx installieren, konfigurieren, starten
├── handlers/main.yml    → "Reload nginx"
├── defaults/main.yml    → Standardwerte für Port, Titel, Farbe
└── templates/
    ├── nginx.conf.j2    → nginx-Konfiguration
    └── index.html.j2    → die Webseite
```

Der Schlüssel: **dieselbe Rolle**, aber **verschiedene Werte**:

```yaml
# Playbook 08-roles.yml

# Play 2: server1 bekommt die Rolle mit blauen Farben
- hosts: server1
  roles:
    - role: webserver
      vars:
        site_title: "Server 1 – Ansible Role"
        body_color: "#1e3a5f"     # dunkelblau

# Play 3: server2 bekommt dieselbe Rolle mit grünen Farben
- hosts: server2
  roles:
    - role: webserver
      vars:
        site_title: "Server 2 – Same Role, Different Config"
        body_color: "#1e5f3a"     # dunkelgrün
```

Eine Rolle schreiben, zweimal mit anderen Parametern einsetzen.

---

## Variablen-Priorität in Rollen

```
defaults/main.yml          ← niedrigste Priorität (Fallback)
     ↓
vars/main.yml              ← fixe Rollen-Variablen
     ↓
Playbook vars:             ← überschreibt defaults
     ↓
-e auf der Kommandozeile   ← höchste Priorität
```

Alles, was in `defaults/` steht, kann **von außen überschrieben** werden.
Alles in `vars/` ist "intern" und soll i.d.R. nicht überschrieben werden.

---

## Rollen aus Ansible Galaxy

Ansible Galaxy ist ein öffentliches Repository mit tausenden fertigen Rollen:

```bash
# Fertige nginx-Rolle von geerlingguy installieren
ansible-galaxy role install geerlingguy.nginx

# PostgreSQL-Rolle
ansible-galaxy role install geerlingguy.postgresql

# Installierte Rollen anzeigen
ansible-galaxy role list

# Rollen aus einer requirements.yml-Datei installieren
ansible-galaxy role install -r requirements.yml
```

```yaml
# requirements.yml
- name: geerlingguy.nginx
  version: "3.2.0"
- name: geerlingguy.postgresql
```

---

## Playbook anschauen und ausführen

```bash
ansible-playbook /playbooks/08-roles.yml
```

Nach dem Ausführen:

```bash
# Beide Seiten aufrufen (von server2 aus)
ansible server2 -m command -a "curl -s http://10.20.0.11/"   # server1's Seite
ansible server2 -m command -a "curl -s http://10.20.0.12/"   # server2's Seite

# Wurde die Marker-Datei von "common" angelegt?
ansible all -m command -a "cat /etc/ansible-managed"

# Das Managed-Verzeichnis
ansible all -m command -a "ls /opt/managed"
```

---

## Übung

1. Führe `08-roles.yml` aus.
2. Öffne `playbooks/roles/webserver/templates/index.html.j2` in VS Code.
3. Füge eine neue Zeile hinzu, z.B.:
   ```html
   <p><strong>Kernel :</strong> {{ ansible_kernel }}</p>
   ```
4. Führe das Playbook erneut aus – der Handler sollte feuern.
5. Prüfe die Seite:
   ```bash
   ansible all -m command -a "curl -s http://localhost/"
   ```
6. **Bonus:** Erstelle eine dritte Rolle namens `monitoring` mit nur einem Task,
   der `htop` installiert. Binde sie in das Playbook ein.

---

## Rückblick: Was du gelernt hast

| Lektion | Konzept |
|---|---|
| 01 | Ansible, Control Node, Managed Node, Inventory |
| 02 | Ad-hoc-Befehle, ping-Modul, PLAY RECAP |
| 03 | Tasks, file/copy-Module, register, Schleifen |
| 04 | Facts, `{{ ansible_... }}`, `when:` Conditionals |
| 05 | apt-Modul, Idempotenz, `changed` vs. `ok` |
| 06 | Variablen, Jinja2-Filter, template-Modul, `-e` |
| 07 | service-Modul, Handler, `notify:` |
| 08 | Rollen, Ordnerstruktur, defaults, Galaxy |

---

## Verständnisfragen

**1. Was ist der Unterschied zwischen `defaults/main.yml` und `vars/main.yml` in einer Rolle?**
> `defaults/` hat die **niedrigste Priorität** – diese Werte sind als Fallback gedacht und können
> von Playbook-Variablen, Inventory-Variablen oder `-e` überschrieben werden.
> `vars/` hat **hohe Priorität** und ist für interne Rollen-Konstanten gedacht, die nicht überschrieben werden sollen.

**2. Wie bindest du eine Rolle mit anderen Variablen als ihren Defaults ein?**
> Mit `role:` und einem `vars:`-Block im Playbook:
> ```yaml
> roles:
>   - role: webserver
>     vars:
>       site_title: "Meine Seite"
>       body_color: "#336699"
> ```

**3. Was macht `ansible-galaxy role init roles/meinerolle`?**
> Es erstellt automatisch die **komplette Ordnerstruktur** einer Ansible-Rolle:
> `tasks/`, `handlers/`, `defaults/`, `vars/`, `templates/`, `files/`, `meta/`
> mit leeren `main.yml`-Dateien, bereit zum Befüllen.

**4. Welchen Vorteil hat eine Rolle gegenüber einem einzelnen großen Playbook?**
> - **Wiederverwendbarkeit**: Dieselbe Rolle auf beliebig viele Server anwenden
> - **Übersichtlichkeit**: Jede Rolle hat einen klaren Zweck
> - **Testbarkeit**: Rollen können isoliert getestet werden
> - **Teilbarkeit**: Rollen können über Ansible Galaxy geteilt werden

---

## Nächste Themen

- **09 – Samba** → Dateifreigaben mit Ansible konfigurieren
- **10 – LDAP** → OpenLDAP-Verzeichnis aufbauen und abfragen
- **11 – SSH-Keys** → Schlüssel auf viele Server verteilen und widerrufen
- **12 – SSL-Zertifikate** → Eigene CA aufbauen und Zertifikate ausrollen
