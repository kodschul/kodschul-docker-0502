# 04 – Facts und Conditionals

**Lernziel:** Automatisch gesammelte Server-Infos nutzen und Tasks gezielt steuern.
**Playbook:** `03-facts.yml`

---

## Was sind Facts?

Bevor Ansible Tasks ausführt, verbindet es sich mit jedem Server und
**sammelt automatisch Informationen** – das nennt sich *Gathering Facts*.

```
Ansible Control Node
       │
       │  SSH → "Sag mir alles über dich"
       ▼
Server (Managed Node)
  → Betriebssystem, Version
  → IP-Adressen, Netzwerk-Interfaces
  → CPU-Kerne, RAM
  → Festplatten, Mountpoints
  → Python-Version
  → ... (Hunderte von Werten)
```

Diese Informationen landen als **Variablen** in Ansible und können in
jedem Task über `{{ ansible_... }}` verwendet werden.

---

## Wichtige Facts auf einen Blick

```yaml
{{ ansible_hostname }}               # server1
{{ ansible_fqdn }}                   # server1.lab.local
{{ ansible_distribution }}           # Ubuntu
{{ ansible_distribution_version }}   # 22.04
{{ ansible_os_family }}              # Debian
{{ ansible_kernel }}                 # 5.15.0-...
{{ ansible_architecture }}           # x86_64
{{ ansible_processor_vcpus }}        # 2
{{ ansible_memtotal_mb }}            # 1024
{{ ansible_memfree_mb }}             # 512
{{ ansible_default_ipv4.address }}   # 10.20.0.11
{{ ansible_python_version }}         # 3.10.12
{{ ansible_date_time.date }}         # 2026-06-23
{{ ansible_date_time.time }}         # 14:32:01
```

---

## Alle Facts eines Servers ansehen

```bash
# Gibt ALLE Facts als riesiges JSON-Objekt aus
ansible server1 -m setup

# Nur bestimmte Facts (Filter mit Wildcard)
ansible server1 -m setup -a "filter=ansible_distribution*"
ansible server1 -m setup -a "filter=ansible_memory*"
ansible server1 -m setup -a "filter=ansible_processor*"
ansible server1 -m setup -a "filter=ansible_default_ipv4"
```

---

## Facts in Tasks verwenden

```yaml
- name: System-Info ausgeben
  ansible.builtin.debug:
    msg:
      - "Hostname : {{ ansible_hostname }}"
      - "OS       : {{ ansible_distribution }} {{ ansible_distribution_version }}"
      - "CPU      : {{ ansible_processor_vcpus }} Kerne"
      - "RAM      : {{ ansible_memtotal_mb }} MB"
      - "IP       : {{ ansible_default_ipv4.address }}"
```

```yaml
- name: Bericht-Datei auf dem Server erstellen
  ansible.builtin.copy:
    dest: /tmp/server-bericht.txt
    content: |
      === Systembericht ===
      Hostname  : {{ ansible_hostname }}
      OS        : {{ ansible_distribution }} {{ ansible_distribution_version }}
      Kernel    : {{ ansible_kernel }}
      CPU       : {{ ansible_processor_vcpus }} Kerne
      RAM       : {{ ansible_memtotal_mb }} MB
```

---

## Conditionals mit `when:`

`when:` führt einen Task nur aus, **wenn eine Bedingung wahr ist**.
Ist die Bedingung falsch → `skipping` in der Ausgabe.

```yaml
- name: Nur auf Ubuntu ausführen
  ansible.builtin.apt:
    name: htop
    state: present
  when: ansible_distribution == "Ubuntu"

- name: Nur auf server1 ausführen
  ansible.builtin.debug:
    msg: "Ich bin server1!"
  when: inventory_hostname == "server1"

- name: Nur wenn RAM > 512 MB
  ansible.builtin.debug:
    msg: "Genug Arbeitsspeicher vorhanden."
  when: ansible_memtotal_mb > 512

- name: Nur wenn Betriebssystem NICHT CentOS ist
  ansible.builtin.debug:
    msg: "Kein CentOS."
  when: ansible_distribution != "CentOS"
```

### Bedingungen kombinieren

```yaml
# UND: beide müssen wahr sein
when:
  - ansible_distribution == "Ubuntu"
  - ansible_memtotal_mb > 512

# ODER: mindestens eine muss wahr sein
when: ansible_distribution == "Ubuntu" or ansible_distribution == "Debian"

# Ergebnis einer register-Variable prüfen
- name: Datei erstellen
  ansible.builtin.copy:
    dest: /tmp/test.txt
    content: "hallo"
  register: copy_result

- name: Nur wenn die Datei neu war
  ansible.builtin.debug:
    msg: "Datei wurde neu angelegt!"
  when: copy_result.changed
```

---

## Facts deaktivieren

Wenn du Facts nicht brauchst (z.B. für reine Ping-Tests), kannst du
das Sammeln überspringen. Das beschleunigt das Playbook:

```yaml
- name: Schneller Ping ohne Facts
  hosts: servers
  gather_facts: false   # Facts überspringen

  tasks:
    - name: Ping
      ansible.builtin.ping:
```

---

## Playbook anschauen und ausführen

```bash
ansible-playbook /playbooks/03-facts.yml
```

Beobachte in der Ausgabe:
- Task "Show a message only on server1" → bei server2 steht `skipping`
- Die Variablen werden pro Host unterschiedlich befüllt

---

## Eigene Facts mit `set_fact`

Du kannst mitten in einem Playbook eigene Variablen erstellen:

```yaml
- name: Eigene Variable berechnen
  ansible.builtin.set_fact:
    server_zusammenfassung: "{{ ansible_hostname }} läuft {{ ansible_distribution }}"

- name: Variable verwenden
  ansible.builtin.debug:
    msg: "{{ server_zusammenfassung }}"
```

---

## Übung

1. Führe aus: `ansible server1 -m setup -a "filter=ansible_distribution*"`
2. Führe das Playbook aus: `ansible-playbook /playbooks/03-facts.yml`
3. Öffne `03-facts.yml` in VS Code.
4. Füge einen neuen Task hinzu, der nur auf `server2` ausgeführt wird:
   ```yaml
   - name: Nur server2 begrüßen
     ansible.builtin.debug:
       msg: "Ich bin server2 und laufe auf {{ ansible_distribution }}!"
     when: inventory_hostname == "server2"
   ```
5. Führe das Playbook erneut aus. Was steht bei server1 in der Ausgabe?

---

## Verständnisfragen

**1. Was sind Ansible Facts und wie werden sie gesammelt?**
> Facts sind **automatisch gesammelte Informationen** über einen Managed Node:
> Betriebssystem, IP-Adresse, RAM, CPU, Festplatten usw.
> Ansible verbindet sich vor dem ersten Task per SSH und führt das `setup`-Modul aus.
> Danach sind alle Infos als `{{ ansible_... }}`-Variablen verfügbar.

**2. Was passiert wenn eine `when:`-Bedingung `false` ergibt?**
> Der Task wird **übersprungen** – in der Ausgabe steht `skipping`.
> Es ist kein Fehler. Das Playbook macht mit dem nächsten Task weiter.

**3. Wie kombinierst du zwei `when:`-Bedingungen mit UND?**
> Als Liste – beide Einträge müssen wahr sein:
> ```yaml
> when:
>   - ansible_distribution == "Ubuntu"
>   - ansible_memtotal_mb > 512
> ```
> Für ODER: `when: bedingung1 or bedingung2`

**4. Wozu dient `gather_facts: false`?**
> Das Sammeln von Facts wird **übersprungen**, was das Playbook beschleunigt.
> Sinnvoll bei Ping-Tests oder wenn du keine `{{ ansible_... }}`-Variablen benötigst.

---

## Nächster Schritt

→ [05 – Pakete und Idempotenz](05-pakete-und-idempotenz.md)
