# 05 – Pakete und Idempotenz

**Lernziel:** Pakete installieren, entfernen und verstehen, warum Ansible sicher mehrfach ausführbar ist.
**Playbook:** `04-packages.yml`

---

## Das `apt`-Modul

Das `apt`-Modul verwaltet Pakete auf Debian/Ubuntu-Systemen –
genau wie `apt install` / `apt remove` in der Shell, aber **idempotent**.

```yaml
- name: Paket installieren
  ansible.builtin.apt:
    name: htop
    state: present        # installieren, falls nicht vorhanden
    update_cache: true    # wie "apt update" vorher ausführen
```

### Die wichtigsten `state`-Werte

| state | Bedeutung |
|---|---|
| `present` | Installieren, falls noch nicht da |
| `absent` | Entfernen, falls installiert |
| `latest` | Installieren oder auf neuste Version upgraden |

### Mehrere Pakete auf einmal

```yaml
- name: Mehrere Pakete installieren
  ansible.builtin.apt:
    name:
      - curl
      - vim
      - tree
      - htop
    state: present
    update_cache: true
```

Das ist effizienter als ein separater Task pro Paket –
Ansible ruft `apt install curl vim tree htop` in einem Aufruf auf.

### Spezifische Version installieren

```yaml
- name: Bestimmte Version installieren
  ansible.builtin.apt:
    name: "nginx=1.18.0-6ubuntu14"    # Paketname=Version
    state: present
```

### Paket entfernen

```yaml
- name: Paket entfernen
  ansible.builtin.apt:
    name: telnet
    state: absent

- name: Paket inklusive Konfiguration entfernen
  ansible.builtin.apt:
    name: telnet
    state: absent
    purge: true           # entfernt auch Konfigurationsdateien
```

---

## Was bedeutet Idempotenz?

> **Idempotenz** bedeutet: Ein Vorgang kann beliebig oft ausgeführt werden
> und erzeugt immer das gleiche Ergebnis.

**Ohne Ansible:**
```bash
# 1. Mal ausführen → curl wird installiert
apt install curl

# 2. Mal ausführen → Fehler oder "bereits installiert"
apt install curl
# → Kein echtes Problem, aber: Skript nicht sicher wiederholbar
```

**Mit Ansible:**
```yaml
- name: curl installieren
  ansible.builtin.apt:
    name: curl
    state: present
```

```
1. Ausführung: curl nicht vorhanden → installieren → changed=1
2. Ausführung: curl bereits vorhanden → nichts tun → changed=0
3. Ausführung: curl bereits vorhanden → nichts tun → changed=0
```

Ansible prüft den **aktuellen Zustand** und handelt nur, wenn der
gewünschte Zustand noch nicht erreicht ist.

---

## `changed` vs. `ok` in der Ausgabe

```
TASK [Install htop] ************************************
ok: [server1]      ← htop war bereits installiert
changed: [server2] ← htop wurde gerade installiert
```

```
PLAY RECAP *********************************************
server1 : ok=3  changed=0  unreachable=0  failed=0
server2 : ok=2  changed=1  unreachable=0  failed=0
```

- `ok` = Task gelaufen, aber Zustand war bereits korrekt → keine Änderung
- `changed` = Task hat etwas auf dem Server verändert

---

## Das `package_facts`-Modul

Damit kannst du den Installationsstatus eines Pakets prüfen:

```yaml
- name: Paket-Facts sammeln
  ansible.builtin.package_facts:
    manager: apt

- name: Prüfen ob nginx installiert ist
  ansible.builtin.debug:
    msg: "nginx Version: {{ ansible_facts.packages['nginx'][0].version }}"
  when: "'nginx' in ansible_facts.packages"
```

---

## Andere Paketmanager

Ansible hat für jedes System das passende Modul:

| Modul | System |
|---|---|
| `ansible.builtin.apt` | Debian, Ubuntu |
| `ansible.builtin.yum` | CentOS, RHEL 7 |
| `ansible.builtin.dnf` | Fedora, RHEL 8+ |
| `ansible.builtin.pacman` | Arch Linux |
| `community.general.homebrew` | macOS |

Oder universell (erkennt das System automatisch):

```yaml
- name: Paket installieren (betriebssystemunabhängig)
  ansible.builtin.package:
    name: curl
    state: present
```

---

## Playbook anschauen und ausführen

```bash
ansible-playbook /playbooks/04-packages.yml
```

Führe es **zweimal** aus und beobachte den Unterschied:

**1. Durchlauf:**
```
PLAY RECAP *****
server1 : ok=5  changed=3  ...
server2 : ok=5  changed=3  ...
```

**2. Durchlauf:**
```
PLAY RECAP *****
server1 : ok=5  changed=0  ...
server2 : ok=5  changed=0  ...
```

Beim zweiten Mal ist `changed=0` – Ansible hat festgestellt, dass
alle Pakete bereits im gewünschten Zustand sind.

### Pakete nachprüfen

```bash
# Ist htop jetzt installiert?
ansible all -m command -a "which htop"
ansible all -m command -a "htop --version"

# Ist ncdu weg? (Das Playbook entfernt es am Ende)
ansible all -m command -a "which ncdu"
```

---

## Übung

1. Führe `04-packages.yml` aus.
2. Führe es ein zweites Mal aus – beobachte `changed`.
3. Öffne das Playbook in VS Code.
4. Ändere `ncdu` von `state: absent` auf `state: present`.
5. Führe es erneut aus. Was passiert?
6. Füge ein weiteres Paket deiner Wahl zur Install-Liste hinzu (z.B. `jq`).
7. Führe es aus und prüfe: `ansible all -m command -a "which jq"`

---

## Verständnisfragen

**1. Was ist der Unterschied zwischen `state: present` und `state: latest`?**
> `present` → Paket installieren, falls noch nicht vorhanden. Vorhandene Version bleibt.
> `latest` → Paket installieren oder auf die **neueste verfügbare Version aktualisieren**.
> In Produktion ist `present` oft vorzuziehen, weil `latest` unerwartete Versions-Upgrades verursachen kann.

**2. Was bedeutet `changed=0` beim zweiten Ausführen eines Playbooks?**
> Alle Tasks haben festgestellt, dass der gewünschte Zustand **bereits erreicht** ist.
> Nichts wurde verändert. Das ist Idempotenz in der Praxis.

**3. Warum ist es besser, mehrere Pakete in einer `name:`-Liste anzugeben statt einzelne Tasks?**
> Ansible ruft dann **einen einzigen `apt install`-Befehl** mit allen Paketen auf.
> Das ist schneller als mehrere separate apt-Aufrufe (jeder startet einen neuen SSH-Prozess).

**4. Mit welchem Modul kannst du betriebssystemunabhängig Pakete installieren?**
> `ansible.builtin.package` – es erkennt automatisch den Paketmanager des Systems
> (apt auf Debian/Ubuntu, yum/dnf auf RHEL/CentOS, pacman auf Arch usw.).

---

## Nächster Schritt

→ [06 – Variablen und Templates](06-variablen-und-templates.md)
