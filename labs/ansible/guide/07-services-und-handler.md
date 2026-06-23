# 07 – Services und Handler

**Lernziel:** Dienste steuern und Änderungen gezielt auf Reaktionen folgen lassen.
**Playbook:** `07-services.yml`

---

## Das `service`-Modul

Mit `service` kannst du Systemdienste starten, stoppen, neu starten
und für den Autostart beim Booten konfigurieren.

```yaml
- name: nginx starten
  ansible.builtin.service:
    name: nginx
    state: started     # starte, falls nicht läuft (idempotent)

- name: nginx stoppen
  ansible.builtin.service:
    name: nginx
    state: stopped

- name: nginx neu starten
  ansible.builtin.service:
    name: nginx
    state: restarted   # IMMER neu starten – auch wenn schon läuft

- name: nginx Konfiguration neu laden
  ansible.builtin.service:
    name: nginx
    state: reloaded    # SIGHUP: Konfiguration neu laden, keine Verbindungsunterbrechung

- name: nginx beim Booten starten
  ansible.builtin.service:
    name: nginx
    state: started
    enabled: true      # Autostart aktivieren (wie systemctl enable)
```

### `restarted` vs. `reloaded`

| | `restarted` | `reloaded` |
|---|---|---|
| Prozess | wird beendet und neu gestartet | bleibt laufen, liest Konfiguration neu |
| Verbindungen | werden unterbrochen | bleiben bestehen |
| Wann verwenden | bei Binär-Updates | bei Konfigurationsänderungen |

---

## Handler – Reaktionen auf Änderungen

> **Problem ohne Handler:**
> Du änderst die nginx-Konfiguration und willst nginx danach neu laden.
> Aber: Das Playbook läuft vielleicht 10 Tasks. Du willst nginx nicht
> bei jedem Task neu laden – nur wenn sich die Konfiguration wirklich geändert hat.

> **Lösung: Handler**

Ein Handler ist ein **spezieller Task**, der nur ausgeführt wird, wenn er
**explizit benachrichtigt** wurde – und zwar **einmal am Ende des Plays**,
egal wie viele Tasks ihn benachrichtigt haben.

```yaml
handlers:
  - name: Reload nginx           # ← Name des Handlers (beliebig wählbar)
    ansible.builtin.service:
      name: nginx
      state: reloaded

tasks:
  - name: Konfigurationsdatei aktualisieren
    ansible.builtin.copy:
      dest: /etc/nginx/sites-available/meineseite
      content: "server { listen 80; }"
    notify: Reload nginx          # ← Handler aufrufen, wenn Task changed=true

  - name: Andere Konfiguration schreiben
    ansible.builtin.copy:
      dest: /etc/nginx/nginx.conf
      content: "worker_processes auto;"
    notify: Reload nginx          # ← auch dieser Task benachrichtigt nginx
    # nginx wird TROTZDEM nur EINMAL neu geladen – am Ende des Plays
```

### Ablauf visualisiert

```
Play startet
  │
  ├── Task 1: nginx installieren         → ok (schon da)
  ├── Task 2: Config schreiben           → CHANGED → merkt: "Reload nginx"
  ├── Task 3: index.html schreiben       → CHANGED → merkt: "Reload nginx"
  ├── Task 4: nginx starten              → ok
  │
  └── HANDLER "Reload nginx" ausführen  → einmal, am Ende
      (egal dass 2 Tasks ihn benachrichtigt haben)
```

**Wenn Task 2 und Task 3 nicht `changed` wären:**
```
  ├── Task 2: Config schreiben    → ok (keine Änderung)
  ├── Task 3: index.html          → ok (keine Änderung)
  │
  └── kein Handler ausführen     → nginx läuft unterbrechungsfrei weiter
```

---

## Service-Facts

```yaml
- name: Service-Informationen sammeln
  ansible.builtin.service_facts:

- name: nginx-Status anzeigen
  ansible.builtin.debug:
    msg: "nginx Status: {{ ansible_facts.services['nginx'].state }}"

- name: Nginx nur neu starten wenn läuft
  ansible.builtin.service:
    name: nginx
    state: restarted
  when: "'nginx' in ansible_facts.services"
```

---

## Dienst-Status per Ad-hoc prüfen

```bash
# Status eines Dienstes prüfen
ansible all -m command -a "service nginx status"

# Alle laufenden Dienste anzeigen
ansible all -m command -a "service --status-all"

# Prüfen ob Port 80 offen ist
ansible all -m command -a "ss -tlnp"
```

---

## Playbook anschauen und ausführen

```bash
ansible-playbook /playbooks/07-services.yml
```

Beobachte besonders:
- Task "Deploy custom nginx index.html" → beim ersten Mal `changed`
- Ganz unten: "RUNNING HANDLER [Reload nginx]" → wird ausgeführt

Führe das Playbook **ein zweites Mal** aus:
- Die index.html ist jetzt unverändert → `ok` statt `changed`
- Handler wird **nicht** ausgeführt (kein `RUNNING HANDLER`)

### Seite im Browser-Test

```bash
# Von server2 aus die Seite von server1 abrufen
ansible server2 -m command -a "curl -s http://10.20.0.11/"
```

---

## Übung

1. Führe `07-services.yml` aus.
2. Ändere in VS Code den Inhalt der index.html im Playbook
   (den `content:`-Block beim Task "Deploy custom nginx index.html").
3. Führe das Playbook erneut aus.
4. Beobachte: der Task ist `changed`, der Handler läuft erneut.
5. Prüfe die neue Seite:
   ```bash
   ansible all -m command -a "curl -s http://localhost/"
   ```
6. Füge einen zweiten Handler hinzu (z.B. "Restart nginx")
   und benachrichtige ihn von einem anderen Task.

---

## Verständnisfragen

**1. Was ist der Unterschied zwischen `state: restarted` und `state: reloaded`?**
> `restarted` → Prozess wird **beendet und neu gestartet**. Laufende Verbindungen werden unterbrochen.
> `reloaded` → Prozess bleibt laufen, liest die Konfiguration **ohne Neustart** neu ein (SIGHUP).
> Für reine Konfigurationsänderungen (z.B. nginx.conf) ist `reloaded` vorzuziehen.

**2. Wann wird ein Handler ausgeführt?**
> Ein Handler wird **einmal am Ende des Plays** ausgeführt,
> wenn mindestens ein Task ihn mit `notify:` benachrichtigt hat **und** dieser Task `changed` war.
> Wenn kein Task `changed` war, wird der Handler **nicht** ausgeführt.

**3. Was passiert wenn 3 verschiedene Tasks denselben Handler mit `notify:` aufrufen?**
> Der Handler wird trotzdem **nur einmal** ausgeführt – am Ende des Plays.
> Ansible merkt sich Benachrichtigungen intern und dedupliziert sie.

**4. Wozu dient `enabled: true` im `service`-Modul?**
> Es aktiviert den Dienst für den **automatischen Start beim Systemstart** (wie `systemctl enable`).
> Ohne `enabled: true` startet der Dienst nach einem Neustart des Servers **nicht automatisch**.

---

## Nächster Schritt

→ [08 – Rollen](08-rollen.md)
