# 00 – Kursübersicht: Docker, Kubernetes & Ansible

**Dauer:** 3 Tage | **Format:** Präsenz / Remote  
**Niveau:** Einsteiger bis Fortgeschrittene

---

## Kursziel

Am Ende dieser Schulung kannst du:

- Container mit Docker bauen, verwalten und absichern
- Multi-Container-Anwendungen mit Docker Compose orchestrieren
- Kubernetes-Cluster verstehen und eigene Deployments schreiben
- Infrastruktur mit Ansible agentlos automatisieren und wiederverwenden

---

## Voraussetzungen

| Was                        | Warum                                      |
| -------------------------- | ------------------------------------------ |
| Linux-Grundkenntnisse      | CLI-Arbeit, Dateisystem, Berechtigungen    |
| Texteditor (VS Code o. ä.) | YAML, Dockerfile, Playbooks bearbeiten     |
| Docker Desktop / Docker CE | Alle Übungen laufen lokal oder auf dem Lab |
| kubectl + minikube / kind  | Kubernetes-Übungen (Tag 3)                 |
| Python 3 + Ansible ≥ 2.15  | Ansible-Übungen (Tag 3)                    |

> **Tipp:** Alle Tools können vorab mit dem Setupskript `scripts/setup.sh` installiert werden.

---

## Zeitplan – Übersicht

### Tag 1 – Docker Grundlagen

| Uhrzeit       | Block | Inhalt                                           |
| ------------- | ----- | ------------------------------------------------ |
| 09:00 – 10:30 | 1     | **Modul 1** – Einführung in Containertechnologie |
| 10:30 – 10:45 | —     | _Pause_                                          |
| 10:45 – 12:15 | 2     | **Modul 2** – Arbeit mit Containern (CLI)        |
| 12:15 – 13:15 | —     | _Mittagspause_                                   |
| 13:15 – 14:45 | 3     | **Modul 3** – Images, Dockerfile & Registries    |
| 14:45 – 15:00 | —     | _Pause_                                          |
| 15:00 – 16:30 | 4     | **Modul 4** – Docker Compose (Teil 1)            |

### Tag 2 – Docker Vertiefung

| Uhrzeit       | Block | Inhalt                                             |
| ------------- | ----- | -------------------------------------------------- |
| 09:00 – 10:30 | 5     | **Modul 4** – Docker Compose (Teil 2)              |
| 10:30 – 10:45 | —     | _Pause_                                            |
| 10:45 – 12:15 | 6     | **Modul 5** – Docker Networking                    |
| 12:15 – 13:15 | —     | _Mittagspause_                                     |
| 13:15 – 14:45 | 7     | **Modul 6** – Docker Sicherheit                    |
| 14:45 – 15:00 | —     | _Pause_                                            |
| 15:00 – 16:30 | 8     | **Modul 9** – Kubernetes: Einführung & Architektur |

### Tag 3 – Kubernetes & Ansible

| Uhrzeit       | Block | Inhalt                                                 |
| ------------- | ----- | ------------------------------------------------------ |
| 09:00 – 10:30 | 9     | **Modul 10** – Kubernetes: Arbeitsumgebung & Setup     |
| 10:30 – 10:45 | —     | _Pause_                                                |
| 10:45 – 12:15 | 10    | **Modul 11** – Kubernetes: Pods, Deployments, Services |
| 12:15 – 13:15 | —     | _Mittagspause_                                         |
| 13:15 – 14:45 | 11    | **Modul 12** – Ansible: Grundlagen & Playbooks         |
| 14:45 – 15:00 | —     | _Pause_                                                |
| 15:00 – 16:30 | 12    | **Modul 13** – Ansible: Rollen, Variablen & Templates  |

---

## Modulübersicht

### Docker (Tag 1 & 2)

| Nr. | Modul                                     | Dauer     | Tag |
| --- | ----------------------------------------- | --------- | --- |
| 1   | Einführung in Containertechnologie        | 90 min    | 1   |
| 2   | Arbeit mit Containern – die Grundlagen    | 90 min    | 1   |
| 3   | Arbeiten mit Images und lokale Registries | 90 min    | 1   |
| 4   | Komplexe Anwendungen mit Docker Compose   | 2× 90 min | 1+2 |
| 5   | Docker Networking                         | 90 min    | 2   |
| 6   | Docker Sicherheit                         | 90 min    | 2   |

### Kubernetes (Tag 2 & 3)

| Nr. | Modul                                  | Dauer  | Tag |
| --- | -------------------------------------- | ------ | --- |
| 9   | Kubernetes – Einführung und Grundlagen | 90 min | 2   |
| 10  | Aufbau der Arbeitsumgebung             | 90 min | 3   |
| 11  | Ressourcen und flexibles Deployment    | 90 min | 3   |

### Ansible (Tag 3)

| Nr. | Modul                                | Dauer  | Tag |
| --- | ------------------------------------ | ------ | --- |
| 12  | Grundlagen und Aufbau von Ansible    | 90 min | 3   |
| 13  | Wiederverwendbare Ansible-Strukturen | 90 min | 3   |

---

## Thematischer Roter Faden

```
Tag 1                        Tag 2                      Tag 3
─────────────────────        ─────────────────────      ─────────────────────
Container verstehen      →   Netzwerk & Sicherheit  →   Orchestrierung (K8s)
Images bauen             →   Compose vertieft       →   Infrastruktur-Code
Erste App deployen       →   Production-ready       →   Ansible Automation
```

> **Lernpfad:** Jeder Tag baut auf dem vorherigen auf – aber jedes Modul enthält auch einen kurzen Rückblick auf die Kernkonzepte der Abhängigkeiten.

---

## Ordnerstruktur des Handouts

```
dk-ansible/
├── 00-kursübersicht/
│   └── 00-kursübersicht.md       ← diese Datei
├── 01-container-einführung/
│   ├── 01-container-einführung.md
│   ├── exercise.md
│   └── solution.md
├── 02-container-grundlagen/
│   ├── 02-container-grundlagen.md
│   ├── exercise.md
│   └── solution.md
├── 03-images-registries/
│   ├── 03-images-registries.md
│   ├── exercise.md
│   └── solution.md
├── 04-docker-compose/
│   ├── 04-docker-compose.md
│   ├── exercise.md
│   └── solution.md
├── 05-networking/
│   ├── 05-networking.md
│   ├── exercise.md
│   └── solution.md
├── 06-sicherheit/
│   ├── 06-sicherheit.md
│   ├── exercise.md
│   └── solution.md
├── 09-kubernetes-einführung/
│   ├── 09-kubernetes-einführung.md
│   ├── exercise.md
│   └── solution.md
├── 10-kubernetes-setup/
│   ├── 10-kubernetes-setup.md
│   ├── exercise.md
│   └── solution.md
├── 11-kubernetes-deployment/
│   ├── 11-kubernetes-deployment.md
│   ├── exercise.md
│   └── solution.md
├── 12-ansible-grundlagen/
│   ├── 12-ansible-grundlagen.md
│   ├── exercise.md
│   └── solution.md
└── 13-ansible-rollen/
    ├── 13-ansible-rollen.md
    ├── exercise.md
    └── solution.md
```

---

## Arbeitsweise im Kurs

Jedes Modul folgt dem gleichen Schema:

1. **Theorie** (~ 30 min) – Konzepte, Diagramme, Analogien
2. **Live-Demo** (~ 20 min) – Trainer zeigt, Teilnehmer beobachten
3. **Übung** (~ 30 min) – Selbstständig am eigenen Rechner
4. **Besprechung** (~ 10 min) – Lösung & offene Fragen

> Die Übungsdateien (`exercise.md`) und Musterlösungen (`solution.md`) befinden sich jeweils im Modulordner.

---

## Kurzreferenz: Wichtige Kommandos

### Docker

```bash
docker run -it ubuntu bash          # Container interaktiv starten
docker build -t myapp:1.0 .         # Image aus Dockerfile bauen
docker compose up -d                # Compose-Stack im Hintergrund starten
docker ps -a                        # Alle Container (auch gestoppte)
docker logs -f <container>          # Log-Stream verfolgen
docker exec -it <container> bash    # In laufenden Container einsteigen
```

### Kubernetes

```bash
kubectl apply -f deployment.yml     # Ressource anlegen / updaten
kubectl get pods -A                 # Alle Pods in allen Namespaces
kubectl describe pod <name>         # Details + Events zum Pod
kubectl logs <pod> -f               # Log-Stream eines Pods
kubectl port-forward svc/<svc> 8080:80  # Service lokal erreichbar machen
```

### Ansible

```bash
ansible all -i inventory.ini -m ping          # Verbindung zu allen Hosts testen
ansible-playbook -i inventory.ini playbook.yml  # Playbook ausführen
ansible-galaxy role install <role>            # Rolle aus Galaxy installieren
ansible-vault encrypt secrets.yml            # Datei verschlüsseln
```

---

## Weitere Ressourcen

| Thema          | Link                                                   |
| -------------- | ------------------------------------------------------ |
| Docker Docs    | https://docs.docker.com                                |
| Kubernetes     | https://kubernetes.io/docs                             |
| Ansible        | https://docs.ansible.com                               |
| Play w/ Docker | https://labs.play-with-docker.com                      |
| K8s Playground | https://killercoda.com/playgrounds/scenario/kubernetes |
