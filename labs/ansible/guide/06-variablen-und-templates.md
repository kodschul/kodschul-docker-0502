# 06 – Variablen und Templates

**Lernziel:** Playbooks flexibel machen – mit Variablen und Jinja2-Templates.
**Playbook:** `05-variables.yml`

---

## Warum Variablen?

Ohne Variablen müsstest du jedes Mal den Playbook-Code ändern,
wenn sich z.B. ein Port, ein Pfad oder ein Name ändert.

```yaml
# ❌ Ohne Variablen: alles hartcodiert
- name: Config schreiben
  ansible.builtin.copy:
    dest: /opt/myapp/config.ini
    content: "port=8080\nhost=db.intern"

# ✅ Mit Variablen: einmal definieren, überall verwenden
- name: Config schreiben
  ansible.builtin.copy:
    dest: "{{ install_dir }}/config.ini"
    content: "port={{ app_port }}\nhost={{ db_host }}"
```

---

## Variablen definieren

### Im Playbook (`vars:`)

```yaml
- name: Webserver einrichten
  hosts: servers
  vars:
    app_name: "MeinProjekt"
    app_port: 8080
    install_dir: "/opt/meinprojekt"
    db_host: "db.intern"

  tasks:
    - name: Verzeichnis anlegen
      ansible.builtin.file:
        path: "{{ install_dir }}"
        state: directory
```

### Im Inventory (`[group:vars]`)

```ini
# inventory/hosts.ini
[servers]
server1  ansible_host=10.20.0.11
server2  ansible_host=10.20.0.12

[servers:vars]
ansible_user=root
umgebung=produktion       # ← eigene Variable für alle Server
```

### Per Kommandozeile (`-e`)

```bash
# Variable beim Ausführen übergeben – höchste Priorität
ansible-playbook playbook.yml -e "app_name=TestApp"
ansible-playbook playbook.yml -e "app_port=9090 db_host=192.168.1.5"
```

---

## Jinja2-Template-Syntax

Ansible verwendet **Jinja2** für Variablen-Substitution.
Überall, wo `{{ }}` steht, wird der Variablenwert eingesetzt.

```yaml
msg: "Hallo von {{ inventory_hostname }}"
# → "Hallo von server1"

dest: "/opt/{{ app_name | lower }}"
# | lower ist ein Filter: wandelt in Kleinbuchstaben um
# → "/opt/meinprojekt"

msg: "RAM: {{ ansible_memtotal_mb }} MB"
# → "RAM: 1024 MB"
```

### Wichtige Jinja2-Filter

```yaml
{{ app_name | lower }}          # → "meinprojekt"
{{ app_name | upper }}          # → "MEINPROJEKT"
{{ app_name | default("App") }} # → Fallback wenn Variable leer
{{ liste | length }}            # → Anzahl Elemente
{{ liste | join(", ") }}        # → "alpha, beta, gamma"
{{ zahl | int }}                # → in Integer umwandeln
{{ text | trim }}               # → Leerzeichen am Rand entfernen
```

---

## Variablen in Dateien (Inhalt mit Variablen)

```yaml
- name: Config-Datei mit Variablen erstellen
  ansible.builtin.copy:
    dest: "{{ install_dir }}/config.ini"
    content: |
      [app]
      name = {{ app_name }}
      port = {{ app_port }}

      [database]
      host = {{ db_host }}
```

---

## Schleifen mit Variablen

```yaml
vars:
  team:
    - Alice
    - Bob
    - Carol

tasks:
  - name: Begrüßung für jedes Teammitglied
    ansible.builtin.debug:
      msg: "Willkommen, {{ item }}!"
    loop: "{{ team }}"
```

### Dictionaries (Wörterbücher)

```yaml
vars:
  datenbank:
    host: db.intern
    port: 5432
    name: produktion

tasks:
  - name: DB-Verbindungsinfo ausgeben
    ansible.builtin.debug:
      msg:
        - "Host : {{ datenbank.host }}"
        - "Port : {{ datenbank.port }}"
        - "Name : {{ datenbank.name }}"
```

---

## Jinja2 in Dateien: das `template`-Modul

Wenn du eine ganze Datei mit vielen Variablen hast, verwende das
`template`-Modul statt `copy`. Die Quell-Datei endet auf `.j2`:

```
# Datei: templates/nginx.conf.j2
server {
    listen {{ server_port }};
    server_name {{ server_name }};
    root {{ web_root }};
}
```

```yaml
- name: nginx-Config aus Template erzeugen
  ansible.builtin.template:
    src: templates/nginx.conf.j2   # .j2-Datei auf dem Control Node
    dest: /etc/nginx/nginx.conf    # Ziel auf dem Server
    mode: '0644'
```

**Unterschied `copy` vs. `template`:**

| Modul | Variablen-Substitution? | Verwendung |
|---|---|---|
| `copy` | Nur im `content:`-Block | Einfache Inhalte |
| `template` | In der ganzen .j2-Datei | Komplexe Konfigurationsdateien |

---

## Variablen-Priorität (von niedrig nach hoch)

```
1. role defaults (niedrigste Priorität)
2. inventory group_vars
3. inventory host_vars
4. playbook vars:
5. register-Variablen
6. -e auf der Kommandozeile  (höchste Priorität)
```

Ein `-e`-Parameter überschreibt **alles** – nützlich für Tests.

---

## Playbook anschauen und ausführen

```bash
ansible-playbook /playbooks/05-variables.yml
```

### Mit überschriebener Variable ausführen

```bash
# app_name von außen setzen
ansible-playbook /playbooks/05-variables.yml -e "app_name=MeinTestApp"

# Mehrere Variablen
ansible-playbook /playbooks/05-variables.yml -e "app_name=Demo app_version=2.0"
```

Prüfe das Ergebnis:
```bash
ansible all -m command -a "cat /opt/demo/config.ini"
```

---

## Übung

1. Führe `05-variables.yml` aus.
2. Führe es erneut aus mit: `-e "app_name=MeinApp"` – was ändert sich?
3. Öffne das Playbook in VS Code.
4. Füge eine neue Variable `admin_email: "admin@lab.local"` hinzu.
5. Erweitere die Config-Datei um eine Zeile:
   ```
   admin = {{ admin_email }}
   ```
6. Führe das Playbook aus und lies die Config:
   ```bash
   ansible all -m command -a "cat /opt/meinapp/config.ini"
   ```

---

## Verständnisfragen

**1. Welche Variablen-Quelle hat die höchste Priorität?**
> Der `-e`-Parameter auf der Kommandozeile (`ansible-playbook playbook.yml -e "var=wert"`).
> Er überschreibt **alles andere** – `vars:` im Playbook, Inventory-Variablen, Role Defaults.

**2. Was ist der Unterschied zwischen `copy` mit `content:` und `template`?**
> `copy` mit `content:` ersetzt Variablen nur in dem direkt angegebenen Text-Block.
> `template` liest eine **externe `.j2`-Datei** und ersetzt Variablen **im gesamten Datei-Inhalt**.
> Für komplexe Konfigurationsdateien (nginx.conf, my.cnf, ...) ist `template` die bessere Wahl.

**3. Was ist ein Jinja2-Filter? Nenne zwei Beispiele.**
> Ein Filter transformiert den Wert einer Variable mit `| filtername`.
> Beispiele: `{{ name | lower }}` → Kleinbuchstaben, `{{ name | default("Gast") }}` → Fallback-Wert,
> `{{ liste | length }}` → Anzahl der Elemente.

**4. Wie übergibst du einer Rolle beim Einbinden andere Variablen als ihre Defaults?**
> Im Playbook unter `role:` mit einem `vars:`-Block:
> ```yaml
> roles:
>   - role: webserver
>     vars:
>       server_port: 8080
>       site_title: "Meine Seite"
> ```

---

## Nächster Schritt

→ [07 – Services und Handler](07-services-und-handler.md)
