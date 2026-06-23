# 01 – Was ist Ansible?

**Lernziel:** Verstehen, was Ansible tut, und das Labor starten.

---

## Das Konzept in einem Satz

Ansible verbindet sich per SSH auf einen Server und führt dort Aufgaben aus.
**Kein Agent, kein Daemon, kein extra Software** auf den Ziel-Servern nötig.

```
Dein Rechner (Control Node)
       │
       │  SSH  →  Aufgaben ausführen
       ├──────────► Server 1  (Ubuntu)
       ├──────────► Server 2  (CentOS)
       └──────────► Server 3  (Debian)
```

> **Analogie:** Ansible ist wie ein Regisseur.
> Er gibt jedem Schauspieler (Server) genau an, was er tun soll –
> aber der Schauspieler selbst trägt kein spezielles Kostüm (keinen Agent).

---

## Warum Ansible?

| Problem ohne Ansible | Lösung mit Ansible |
|---|---|
| 20 Server manuell konfigurieren | Ein Playbook, läuft auf allen 20 |
| Wer hat was wann geändert? | Alles steht in YAML-Dateien (Git-versionierbar) |
| Konfiguration weicht vom Standard ab | Ansible bringt Server jedes Mal in den gewünschten Zustand |
| Neuer Kollege muss alles neu lernen | Playbooks sind lesbares YAML – selbst dokumentierend |

---

## Die drei Kernkonzepte

### 1. Inventory – die Serverliste

```ini
# inventory/hosts.ini
[servers]
server1  ansible_host=10.20.0.11
server2  ansible_host=10.20.0.12

[servers:vars]
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_rsa
```

Das Inventory sagt Ansible: *"Diese Server existieren, so erreichst du sie."*

### 2. Modul – eine einzelne Aktion

Ein Modul ist eine vorgefertigte Aktion. Ansible hat über 3.000 davon.

```
ansible.builtin.apt      → Pakete installieren (Debian/Ubuntu)
ansible.builtin.copy     → Datei kopieren
ansible.builtin.service  → Dienst starten / stoppen
ansible.builtin.user     → Benutzer anlegen
ansible.builtin.ping     → Verbindung prüfen
```

### 3. Playbook – eine Liste von Aufgaben

```yaml
---
- name: "Mein erstes Playbook"
  hosts: servers        # Zielgruppe aus dem Inventory

  tasks:
    - name: Paket installieren
      ansible.builtin.apt:
        name: curl
        state: present   # "present" = installiere, falls noch nicht da
```

---

## Das Labor starten

Dieses Labor simuliert eine echte Umgebung mit Docker-Containern:

```
ansible-control  (10.20.0.10)   ← hier läufst du ansible-playbook
      │
      ├── SSH ──► server1  (10.20.0.11)   ← Ubuntu-Server
      └── SSH ──► server2  (10.20.0.12)   ← Ubuntu-Server
```

### Schritt 1 – Labor starten

```powershell
# Im PowerShell-Terminal auf Windows:
cd C:\Users\User\Documents\kodschul\kodschul-docker-0502\labs\ansible

docker compose up -d
docker compose ps
```

Erwartete Ausgabe: alle 3 Container im Status `Up`.

### Schritt 2 – In den Control Node einloggen

```powershell
docker exec -it ansible-control bash
```

Du bist jetzt im Control Node. Die Eingabeaufforderung ändert sich zu:
```
root@ansible-control:/#
```

### Schritt 3 – Ansible-Version prüfen

```bash
ansible --version
```

### Schritt 4 – Inventory anschauen

```bash
cat /inventory/hosts.ini
```

Hier siehst du die beiden Server mit ihren IP-Adressen.

### Schritt 5 – Die Konfigurationsdatei anschauen

```bash
cat /etc/ansible/ansible.cfg
```

Hier ist z.B. eingestellt:
- welches Inventory verwendet wird
- welcher SSH-Key benutzt wird
- dass Host-Key-Prüfung ausgeschaltet ist (für das Labor)

---

## Verständnisfragen

**1. Was ist der Unterschied zwischen Control Node und Managed Node?**
> Der **Control Node** ist der Rechner, auf dem Ansible installiert ist und von dem aus Playbooks ausgeführt werden.
> Ein **Managed Node** (verwalteter Server) ist ein Ziel-Server – dort wird Ansible *nicht* installiert.
> Ansible verbindet sich per SSH vom Control Node auf die Managed Nodes.

**2. Was braucht ein Server, damit Ansible ihn verwalten kann?**
> - SSH-Zugang (Port 22, erreichbar vom Control Node)
> - Python 3 (meist vorinstalliert unter Ubuntu/Debian)
> - Einen Benutzer mit ausreichenden Rechten (z.B. `root` oder ein sudo-Benutzer)
> Kein Ansible, kein Agent, kein Daemon auf dem Server nötig.

**3. Wozu dient das Inventory?**
> Das Inventory ist eine Datei (z.B. `hosts.ini`), die Ansible sagt, **welche Server existieren**,
> wie sie erreichbar sind (IP/Hostname, Port, Benutzer, SSH-Key) und in welchen Gruppen sie
> zusammengefasst sind.

---

## Nächster Schritt

→ [02 – Erste Verbindung](02-erste-verbindung.md)
