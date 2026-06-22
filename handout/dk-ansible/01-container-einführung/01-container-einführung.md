# 01 – Einführung in Containertechnologie

**Block:** 90 min | **Tag 1**

---

## Was ist ein Container?

Ein Container ist ein **isolierter Prozess**, der auf dem Host-Betriebssystem läuft – mit eigenem Dateisystem, eigenem Netzwerk und eigenen Umgebungsvariablen, aber ohne eigenen Kernel.

```
Ohne Container                    Mit Containern
──────────────────────            ──────────────────────────────────
Host OS                           Host OS
  └─ App A (Python 3.8)             ├─ Container A (Python 3.8)
  └─ App B (Python 3.12)            ├─ Container B (Python 3.12)
  └─ App C (Node 18)                └─ Container C (Node 18)
  ← Konflikte!                      ← vollständig isoliert
```

> **Analogie:** Ein Container verhält sich wie ein Schiffscontainer – standardisiertes Gehäuse, egal was drin ist, passt auf jedes Schiff (Host).

---

## Lab 1.1 – Warum Container?

### Das Problem vor Containern

- **"Works on my machine"** – App läuft lokal, schlägt in Produktion fehl
- **Dependency-Konflikte** – zwei Apps brauchen verschiedene Versionen derselben Bibliothek
- **Langsame Deployments** – VM provisionieren dauert Minuten bis Stunden
- **Ressourcenverschwendung** – jede VM braucht vollständiges OS

### Was Container lösen

| Problem                 | Lösung durch Container                                        |
| ----------------------- | ------------------------------------------------------------- |
| Umgebungsunterschiede   | Image enthält alles – OS, Runtime, Code, Konfiguration        |
| Dependency-Konflikte    | Jeder Container hat eigene isolierte Umgebung                 |
| Langsame Starts         | Container starten in Sekunden (kein Kernel-Boot)              |
| Ressourcenverschwendung | Kein duplizierter Kernel – Prozessisolierung durch Namespaces |

### Kernel-Mechanismen hinter Containern

```
Linux-Kernel
├── Namespaces    → Isolierung (PID, Network, Mount, UTS, IPC, User)
├── Cgroups       → Ressourcenlimitierung (CPU, RAM, I/O)
└── Union FS      → Layered Filesystem (OverlayFS)
```

---

## Lab 1.2 – Vergleich zur Virtualisierung

```
Virtuelle Maschinen                 Container
────────────────────────            ────────────────────────
Hardware                            Hardware
  Hypervisor (Type 1/2)               Host OS (Linux-Kernel)
    VM 1                                Container Runtime (Docker)
      Guest OS (vollständig)              Container A  Container B
      Binaries / Libs                       App A        App B
      App A
    VM 2
      Guest OS (vollständig)
      App B
```

| Aspekt       | VM                           | Container           |
| ------------ | ---------------------------- | ------------------- |
| Startzeit    | 30 Sek – 5 Min               | < 1 Sekunde         |
| Größe        | 1–20 GB                      | 5–500 MB            |
| Isolation    | vollständig (eigener Kernel) | Prozessisolierung   |
| Overhead     | hoch (Hypervisor, Guest OS)  | gering              |
| Portabilität | schwerfällig (VMDK, OVF)     | Image-Format (OCI)  |
| Sicherheit   | starke Isolation             | Kernel wird geteilt |

> **Wann VM, wann Container?**
>
> - VM: wenn starke Isolation nötig (Multi-Tenant, unterschiedliche OS)
> - Container: wenn Effizienz und Portabilität Vorrang haben

---

## Lab 1.3 – Container-Ökosystem

```
Container-Ökosystem
─────────────────────────────────────────────────────
Build                Run                  Orchestrierung
──────────           ──────────────       ──────────────────
Dockerfile      →    Docker Engine   →    Kubernetes
Buildpacks           containerd           Docker Swarm
Kaniko               Podman               Nomad
BuildKit             CRI-O

Image-Registry              Beobachtbarkeit
──────────────────          ──────────────────
Docker Hub                  Prometheus
GitHub Container Registry   Grafana
Harbor                      Loki
Amazon ECR                  Jaeger (Tracing)
```

### OCI – Open Container Initiative

Docker hat 2015 gemeinsam mit anderen Firmen den **OCI-Standard** ins Leben gerufen:

- **OCI Image Spec** – wie ein Container-Image aufgebaut ist
- **OCI Runtime Spec** – wie ein Container aus einem Image gestartet wird

> Dadurch: ein Docker-Image läuft auch auf Podman, containerd, CRI-O – ohne Änderung.

### Docker-Komponenten im Überblick

```
docker CLI
    │
    │ REST API
    ▼
Docker Daemon (dockerd)
    │
    ├── containerd       ← Container-Lifecycle-Management
    │     └── runc       ← OCI Runtime: startet Container-Prozesse
    │
    ├── Images           ← gespeichert unter /var/lib/docker/
    └── Volumes / Networks
```

```bash
# Architektur live ansehen
docker info                    # Engine-Details
docker system info             # vollständige Systeminfo
docker version                 # Client + Server Versionen
```

---

## Zusammenfassung

```
Container
├── isolierter Linux-Prozess (kein eigener Kernel)
├── basiert auf Image (unveränderliches Dateisystem)
├── startet in < 1 Sekunde
└── portabel durch OCI-Standard

vs. VM
├── eigener Kernel (Guest OS)
├── stärkere Isolation
└── höherer Ressourcenverbrauch

Ökosystem
├── Docker Engine (lokal)
├── Kubernetes (Orchestrierung)
└── Registry (Image-Verteilung)
```
