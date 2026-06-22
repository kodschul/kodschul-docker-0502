# 00d – Best Practices: Docker, Kubernetes & Ansible

**Block:** 90 min | **Extra-Modul** (empfohlen: Ende Tag 2 als Zusammenfassung vor K8s)

---

## Warum Best Practices?

Jeder kann einen Container starten. Die Herausforderung liegt darin, Images klein, sicher und reproduzierbar zu halten – und Deployments zu schreiben, die auch in 6 Monaten noch funktionieren, wenn ein anderer Entwickler sie anfasst.

Best Practices sind keine strengen Regeln. Sie sind gesammelte Erfahrungen aus vielen Projekten, die zeigen: **Das führt meistens zu Problemen** und **das funktioniert meistens gut**.

---

## Dockerfile Best Practices

### 1. Minimale Basis-Images wählen

**Warum?** Jedes Paket im Basis-Image ist eine potenzielle Schwachstelle (CVE). Ubuntu bringt hunderte vorinstallierte Pakete mit. Ein nginx-Container braucht keinen Paketmanager, keinen Compiler und kein SSH.

```dockerfile
# ❌ Zu groß und zu viel unbekanntes Zeug drin:
FROM ubuntu:latest

# ✅ Alpine: nur 5 MB, winzige Angriffsfläche
FROM python:3.12-alpine

# ✅ Distroless: kein Shell, kein Paketmanager – nur die App
#    Gut für Produktion, schwerer zu debuggen
FROM gcr.io/distroless/python3
```

| Image       | Größe  | Hat Shell? | Wann nutzen            |
| ----------- | ------ | ---------- | ---------------------- |
| ubuntu      | ~77 MB | ja         | Nur Dev / Debug        |
| debian:slim | ~75 MB | ja         | Wenn apt nötig         |
| alpine      | ~5 MB  | sh         | Produktion (empfohlen) |
| distroless  | ~20 MB | **nein**   | Produktion (sicherer)  |
| scratch     | 0 MB   | **nein**   | Nur für Go-Binaries    |

> **Einfach ausgedrückt:** Du willst Pizza liefern. Du brauchst kein Catering-Truck mit Küche, Gefriertruhe und Grill. Ein Fahrradbote reicht.

---

### 2. Multi-Stage Builds

**Warum?** Zum Bauen braucht man einen Compiler, Dependencies, Build-Tools. In Produktion braucht man nur das fertige Ergebnis. Ohne Multi-Stage landen Compiler, npm, pip usw. im finalen Image – das ist riesig und enthält Tools die angegriffen werden können.

```dockerfile
# Stage 1: Bauen – hier passiert alles Aufwändige
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build        # → erzeugt /app/dist/

# Stage 2: Ausliefern – nur das Ergebnis
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
# Das finale Image enthält: nginx + deine HTML-Dateien. Das wars.
```

> **Einfach ausgedrückt:** Stell dir vor, du baust ein Haus. Zum Bauen brauchst du Kran, Gerüst, Werkzeuge. Wenn das Haus fertig ist, zieht nicht der Kran mit ein. Multi-Stage = Kran bleibt draußen.

---

### 3. Layer-Reihenfolge – Cache richtig nutzen

**Warum?** Docker baut Images in Layern. Ändert sich ein Layer, müssen alle **nachfolgenden** Layer neu gebaut werden. Das kostet Zeit. Wenn man Dinge die sich selten ändern (Dependencies) vor Dinge stellt die sich oft ändern (Code), profitiert man vom Cache.

```dockerfile
# ❌ Schlecht: Jede Code-Änderung → npm install neu (dauert Minuten)
COPY . .
RUN npm install

# ✅ Besser: package.json ändert sich selten → npm install wird gecacht
COPY package*.json ./
RUN npm install          # wird aus Cache geladen wenn package.json unverändert
COPY . .                 # erst jetzt den Code kopieren
```

> **Faustregel:** Dinge die sich selten ändern → oben im Dockerfile. Dinge die sich oft ändern → unten.

---

### 4. Nicht als root laufen

**Warum?** Wenn ein Container als root läuft und ein Angreifer eine Schwachstelle in der App findet, hat er sofort Root-Zugriff im Container – und damit potenziell auf den Host. Ein nicht-privilegierter Benutzer begrenzt den Schaden.

```dockerfile
# Vor dem CMD: Benutzer anlegen und wechseln
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

CMD ["python", "app.py"]
# → Python läuft jetzt als "appuser", nicht als root
```

```bash
# Prüfen als welcher User ein Container läuft:
docker run --rm nginx whoami
# root  ← ohne USER-Anweisung immer root!

docker run --rm meinapp whoami
# appuser  ← korrekt
```

> **Einfach ausgedrückt:** In einem Bürogebäude hat der Putzmann nicht den Generalschlüssel. Er kommt rein, macht sauber, kann aber nicht in jeden Raum. Genauso sollte deine App nur die Rechte haben, die sie wirklich braucht.

---

### 5. `.dockerignore` – was NICHT ins Image soll

**Warum?** Ohne `.dockerignore` kopiert `COPY . .` alles in den Build-Kontext – `node_modules` (hunderte MB), `.git` (mit Commit-History und evtl. Secrets), `.env` (Passwörter!). Das macht Images riesig und unsicher.

```
# .dockerignore  (liegt neben dem Dockerfile)
.git
node_modules
*.log
.env
.DS_Store
__pycache__
*.pyc
coverage/
.vscode/
```

> **Einfach ausgedrückt:** Wenn du umziehst, packst du auch nicht den Müll in den Umzugswagen.

---

### 6. Konkrete Versionen pinnen

**Warum?** `FROM node:latest` bedeutet: heute node:20, morgen node:22, nächste Woche node:22 mit einem Breaking Change. Das Image das gestern gebaut hat, baut plötzlich nicht mehr. In Produktion ist das gefährlich.

```dockerfile
# ❌ Unvorhersehbar – was ist "latest" in 6 Monaten?
FROM node:latest

# ✅ Reproduzierbar – genau diese Version, immer
FROM node:20.14-alpine3.20
```

> **Einfach ausgedrückt:** Wenn du ein Rezept kochst, steht da auch nicht „irgendein Mehl". Es steht: „550g Weizenmehl Type 550". Sonst kann das Ergebnis jedes Mal anders sein.

---

## Docker Compose Best Practices

### Das vollständige Beispiel mit Erklärungen

```yaml
services:
  backend:
    build:
      context: ./backend
      target: production # Multi-Stage: nur die production-Stage
    image: myapp-backend:${TAG:-latest} # ${TAG:-latest} = nutze $TAG oder "latest"
    restart: unless-stopped # startet neu wenn er crasht, aber nicht bei manuellem stop
    env_file: .env # Passwörter aus Datei lesen, nicht direkt hier reinschreiben!
    ports:
      - "127.0.0.1:8080:8080" # Nur auf localhost, NICHT 0.0.0.0 (sicherer!)
    depends_on:
      db:
        condition: service_healthy # wartet wirklich bis db bereit ist
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    networks:
      - internal # nur im internen Netzwerk, nicht öffentlich

  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data # named volume (Docker verwaltet es)
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password # Passwort aus Datei, nicht ENV
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
    networks:
      - internal

volumes:
  db-data: # named volume: Daten überleben docker compose down

networks:
  internal:
    driver: bridge
```

**Warum `127.0.0.1` statt nichts bei ports?**

```yaml
# ❌ Öffnet Port auf ALLEN Netzwerk-Interfaces:
ports:
  - "8080:8080"     # → 0.0.0.0:8080 = jeder im Netz kann drauf

# ✅ Nur auf localhost:
ports:
  - "127.0.0.1:8080:8080"   # → nur du selbst auf dem Rechner
```

> **Einfach ausgedrückt:** Der erste Fall hängt ein Schild vor dein Haus. Der zweite steckt den Schlüssel in deine eigene Tasche.

**Warum named volumes statt Bind Mounts für Produktionsdaten?**

```yaml
# ❌ Bind Mount: Datenbankdaten liegen in einem lokalen Ordner
volumes:
  - ./postgres-data:/var/lib/postgresql/data
# Problem: Ordner-Berechtigungen, Betriebssystem-Unterschiede, versehentliches Löschen

# ✅ Named Volume: Docker verwaltet wo und wie die Daten liegen
volumes:
  - db-data:/var/lib/postgresql/data
```

---

## Kubernetes Best Practices

### Resource Limits immer setzen

**Warum?** Kubernetes muss wissen, wie viel Ressourcen ein Pod braucht, um ihn auf den richtigen Node zu platzieren. Ohne Limits kann ein einziger Pod den gesamten Node-Speicher leer räumen – alle anderen Pods auf dem Node sterben dann mit.

```yaml
resources:
  requests: # "Mindestens das brauche ich" → für den Scheduler
    memory: "128Mi"
    cpu: "100m" # 100m = 0.1 CPU-Kern (1000m = 1 Kern)
  limits: # "Mehr als das darf ich nicht" → Schutzgrenze
    memory: "256Mi"
    cpu: "500m"
```

> **Einfach ausgedrückt:** `requests` ist wie der Platzbedarf auf einer Reservierungsliste. `limits` ist die maximale Tischgröße. Ohne limits kann einer den ganzen Saal für sich beanspruchen.

---

### Liveness- und Readiness-Probes

**Warum?** Ohne Probes weiß Kubernetes nicht, ob dein Container wirklich läuft oder nur so tut als ob. Ein Container kann gestartet sein, aber die App hat einen Deadlock oder ist noch am Hochfahren.

```yaml
livenessProbe: # "Ist die App noch am Leben?"
  httpGet: # Kubernetes macht einen HTTP-Request auf /healthz
    path: /healthz
    port: 8080
  initialDelaySeconds: 15 # warte 15s bevor erster Check
  periodSeconds: 20 # danach alle 20s prüfen
  # → Wenn fehlschlägt: Container wird NEUGESTARTET

readinessProbe: # "Ist die App bereit Traffic zu empfangen?"
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  # → Wenn fehlschlägt: Container bekommt KEINEN TRAFFIC (aber wird nicht neugestartet)
```

| Probe       | Aktion bei Fehler               | Wann nutzen                     |
| ----------- | ------------------------------- | ------------------------------- |
| `liveness`  | Container wird neu gestartet    | Deadlocks, hängende Prozesse    |
| `readiness` | Kein Traffic bis healthy        | Startup-Zeit, kurze Überlastung |
| `startup`   | Erst nach Erfolg liveness-Check | Sehr langsam startende Apps     |

> **Einfach ausgedrückt:** Liveness = "lebt der Patient noch?" Readiness = "kann der Patient schon Besucher empfangen?"

---

### Namespaces – nicht alles in `default`

**Warum?** Der `default`-Namespace ist wie der Desktop deines Computers – wenn dort alles liegt, verlierst du schnell den Überblick. Namespaces trennen Umgebungen logisch voneinander und machen es einfacher, Berechtigungen und Ressourcen zu verwalten.

```bash
kubectl create namespace production
kubectl create namespace staging
kubectl create namespace monitoring

kubectl apply -f deployment.yml -n production
kubectl get pods -n production
```

---

### Labels konsequent setzen

**Warum?** Labels sind das einzige System in Kubernetes, mit dem du Ressourcen filtern, gruppieren und auswählen kannst. Services finden ihre Pods über Labels. Ohne sinnvolle Labels kannst du im Notfall nicht schnell finden was du suchst.

```yaml
metadata:
  labels:
    app: frontend # Name der Anwendung
    version: "2.1.0" # aktuelle Version (für Rollbacks)
    environment: production # Umgebung
    team: platform # zuständiges Team
```

```bash
# Mit Labels kann man gezielt filtern:
kubectl get pods -l app=frontend
kubectl get pods -l environment=production
kubectl delete pods -l version=1.0.0   # alte Version aufräumen
```

---

### Keine Secrets direkt im YAML

**Warum?** YAML-Dateien werden oft in Git eingecheckt. Wenn ein Passwort im YAML steht, steht es in der Git-History – für immer, auch wenn du es später löschst.

```yaml
# ❌ NIE SO – landet in Git, sieht jeder der Zugriff hat:
env:
  - name: DB_PASSWORD
    value: "meinpasswort123"

# ✅ Aus einem Secret lesen:
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials   # Name des Secret-Objekts
        key: password          # Schlüssel im Secret
```

```bash
# Secret anlegen (im Cluster, nicht in Git):
kubectl create secret generic db-credentials \
  --from-literal=password=meinpasswort123
```

> **Einfach ausgedrückt:** Dein Hausschlüssel liegt nicht auf dem Bürgersteig, auch wenn du ein Notizbuch darüber hast. Secrets gehören ins Secret-Objekt, nicht ins YAML.

---

## Ansible Best Practices

### Idempotenz – der wichtigste Grundsatz

**Was bedeutet Idempotenz?** Eine Aktion ist idempotent, wenn sie mehrfach ausgeführt werden kann und dabei immer dasselbe Ergebnis produziert. Ein nginx-Task soll nginx installieren, wenn es noch nicht da ist – und nichts tun wenn es schon installiert ist.

```yaml
# ❌ Nicht idempotent: führt den Befehl immer aus, egal was
- name: nginx installieren
  command: apt-get install -y nginx

# ✅ Idempotent: prüft erst, handelt nur wenn nötig
- name: nginx installieren
  ansible.builtin.apt:
    name: nginx
    state: present # "present" = installieren falls nicht vorhanden
```

> **Einfach ausgedrückt:** Wenn du ein Playbook zweimal ausführst, soll beim zweiten Mal nichts passieren – weil alles schon so ist wie gewollt. Das ist Idempotenz.

---

### Variablen hierarchisch strukturieren

**Warum?** Ansible hat ein Variablen-System mit Prioritäten. Wenn man die Struktur nutzt, kann man Defaults setzen die für alle gelten, und sie für einzelne Hosts/Umgebungen überschreiben.

```
roles/webserver/
├── defaults/main.yml    ← Standardwerte (niedrigste Priorität – leicht überschreibbar)
├── vars/main.yml        ← Rolle-interne Werte (höhere Priorität)
└── tasks/main.yml
```

```yaml
# defaults/main.yml – jeder kann das überschreiben
nginx_port: 80
nginx_user: www-data

# Überschreiben für Produktion in group_vars/production.yml:
nginx_port: 443
```

> **Einfach ausgedrückt:** defaults sind Fabrikeinstellungen. Jeder kann sie nach Bedarf anpassen, aber sie funktionieren auch ohne Anpassung.

---

### `ansible-lint` – Fehler früh finden

**Warum?** Ansible-lint prüft Playbooks auf häufige Fehler, bevor sie ausgeführt werden. Fehler wie: fehlende Task-Namen, `command` statt spezialisiertem Modul, Sicherheitsprobleme.

```bash
pip install ansible-lint
ansible-lint playbook.yml

# Was lint findet (Beispiele):
# - task mit command statt ansible.builtin.apt → nicht idempotent!
# - kein "name:" bei Task → schlecht lesbar
# - hardcodiertes Passwort → Sicherheitsproblem
```

---

### Vault für Secrets

**Warum?** Passwörter, API-Keys und Tokens gehören nicht in Git. Mit ansible-vault können Dateien verschlüsselt werden – sie können dann sicher ins Repository eingecheckt werden, weil ohne das Vault-Passwort nichts lesbar ist.

```bash
# Datei mit Secrets verschlüsseln:
ansible-vault encrypt group_vars/all/secrets.yml
# → Datei ist jetzt verschlüsselt, kann in Git

# Playbook mit Vault ausführen:
ansible-playbook site.yml --ask-vault-pass
```

---

## Allgemeine Regeln – Zusammenfassung

| Regel                 | Docker                        | Kubernetes                     | Ansible                     |
| --------------------- | ----------------------------- | ------------------------------ | --------------------------- |
| Keine Secrets im Code | `.env` / Docker Secrets       | `Secret`-Objekte               | `ansible-vault`             |
| Versionierung pinnen  | `image:1.2.3` im Dockerfile   | `image: app:1.2.3`             | `meta/main.yml` mit Version |
| Health prüfen         | `HEALTHCHECK` im Dockerfile   | Liveness + Readiness Probe     | `ansible-lint`              |
| Minimale Rechte       | `USER` im Dockerfile          | `securityContext.runAsNonRoot` | `become: yes` nur wo nötig  |
| Reproduzierbar        | Multi-Stage + `.dockerignore` | Ressource-Limits               | Idempotente Module          |

---

## Checkliste vor dem Deployment

```
Docker – Dockerfile
  ☐ Kein "latest" als Basis-Image-Tag
  ☐ .dockerignore vorhanden (node_modules, .env, .git drin)
  ☐ package.json / requirements.txt VOR dem Code-COPY
  ☐ Multi-Stage Build für Build-Artefakte
  ☐ USER-Anweisung: kein root
  ☐ HEALTHCHECK definiert

Docker Compose
  ☐ Ports auf 127.0.0.1 gebunden (nicht 0.0.0.0)
  ☐ Passwörter in env_file / .env (nicht direkt im YAML)
  ☐ Named Volumes für persistente Daten
  ☐ Healthchecks für alle Services die andere brauchen
  ☐ depends_on mit condition: service_healthy

Kubernetes
  ☐ resources.requests und resources.limits gesetzt
  ☐ readinessProbe und livenessProbe definiert
  ☐ Kein Passwort-Wert direkt im YAML
  ☐ Eigener Namespace (nicht default)
  ☐ Labels: app, version, environment

Ansible
  ☐ ansible-lint ohne Fehler
  ☐ Secrets in ansible-vault verschlüsselt
  ☐ Alle Tasks mit "name:" versehen
  ☐ command-Modul durch spezialisierte Module ersetzt
  ☐ Defaults in defaults/main.yml, nicht in tasks/main.yml
```

---

## Dockerfile Best Practices

### 1. Minimale Basis-Images wählen

```dockerfile
# ❌ zu groß, zu viele unbekannte Pakete
FROM ubuntu:latest

# ✅ minimal, kein Paketmanager, keine Shell
FROM scratch

# ✅ Alpine: klein (~5 MB), mit apk-Paketmanager
FROM python:3.12-alpine

# ✅ Distroless: kein Shell, kein Paketmanager – nur die App
FROM gcr.io/distroless/python3
```

| Image       | Größe  | Shell | Empfehlung          |
| ----------- | ------ | ----- | ------------------- |
| ubuntu      | ~77 MB | ja    | Nur für Dev/Debug   |
| debian:slim | ~75 MB | ja    | Guter Kompromiss    |
| alpine      | ~5 MB  | sh    | Produktion (klein)  |
| distroless  | ~20 MB | nein  | Produktion (sicher) |
| scratch     | 0 MB   | nein  | Go-Binaries         |

### 2. Multi-Stage Builds

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Production (nur das Ergebnis, ohne node_modules für Dev)
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
```

**Vorteil:** Das finale Image enthält nur das Build-Ergebnis – kein Compiler, keine Dev-Dependencies, keine temporären Dateien.

### 3. Layer-Reihenfolge – Cache nutzen

```dockerfile
# ❌ schlecht: Code-Änderung invalidiert npm install
COPY . .
RUN npm install

# ✅ besser: npm install wird gecacht solange package.json unverändert
COPY package*.json ./
RUN npm install
COPY . .
```

**Regel:** Dinge die sich selten ändern → oben. Dinge die sich oft ändern → unten.

### 4. Nicht als root laufen

```dockerfile
# Benutzer anlegen und wechseln
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Alternativ (Docker 1.17+): ARG + --chown
COPY --chown=appuser:appgroup . .
```

### 5. .dockerignore nicht vergessen

```
# .dockerignore
.git
node_modules
*.log
.env
.DS_Store
__pycache__
*.pyc
dist/          # bei manchen Projekten nicht ignorieren!
```

### 6. Konkrete Versionen pinnen

```dockerfile
# ❌ unvorhersehbar
FROM node:latest
RUN apt-get install curl

# ✅ reproduzierbar
FROM node:20.14-alpine3.20
RUN apk add --no-cache curl=8.7.1-r0
```

---

## Docker Compose Best Practices

```yaml
# ✅ Vollständiges Beispiel mit Best Practices

services:
  backend:
    build:
      context: ./backend
      target: production # Multi-Stage-Target wählen
    image: myapp-backend:${TAG:-latest}
    restart: unless-stopped # kein "always" in Dev, aber gut für Prod
    env_file: .env # Secrets NICHT in compose.yml
    ports:
      - "127.0.0.1:8080:8080" # nur loopback, nicht 0.0.0.0
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    networks:
      - internal

  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data # named volume, kein bind mount
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password # Docker Secrets
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
    networks:
      - internal

volumes:
  db-data:

networks:
  internal:
    driver: bridge
```

**Wichtige Regeln:**

- Ports nur auf `127.0.0.1` binden, nicht auf `0.0.0.0`
- Named Volumes für persistente Daten statt Bind Mounts
- `env_file` statt Environment-Werte direkt im YAML
- Healthchecks für alle Dependencies definieren

---

## Kubernetes Best Practices

### Resource Limits immer setzen

```yaml
resources:
  requests: # Mindestbedarf (für Scheduling)
    memory: "128Mi"
    cpu: "100m"
  limits: # Maximalgrenze (Schutz vor Runaway-Prozessen)
    memory: "256Mi"
    cpu: "500m"
```

> Ohne `limits` kann ein Pod den gesamten Node-Speicher leer räumen.

### Health Checks für jeden Deployment

```yaml
livenessProbe: # Container neu starten wenn dies fehlschlägt
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe: # Traffic erst leiten wenn dies erfolgreich
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

| Probe       | Aktion bei Fehler            | Nutzen                  |
| ----------- | ---------------------------- | ----------------------- |
| `liveness`  | Container wird neu gestartet | Deadlocks beheben       |
| `readiness` | Kein Traffic bis healthy     | Rolling Updates sichern |
| `startup`   | Erst liveness nach Erfolg    | Langsam startende Apps  |

### Namespace-Trennung

```bash
# Nicht alles in default!
kubectl create namespace production
kubectl create namespace staging
kubectl create namespace monitoring

# Ressourcen in Namespace deployen
kubectl apply -f deployment.yml -n production
```

### Labels konsequent setzen

```yaml
metadata:
  labels:
    app: frontend
    version: "2.1.0"
    environment: production
    team: platform
    managed-by: helm # oder kustomize, manual etc.
```

### Keine Secrets in YAML-Dateien

```bash
# ❌ nie so:
env:
  - name: DB_PASSWORD
    value: "meinpasswort123"

# ✅ immer aus Secret:
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: password
```

```bash
# Secret anlegen (nicht ins Git committen!)
kubectl create secret generic db-credentials \
  --from-literal=password=meinpasswort123
```

---

## Ansible Best Practices

### Idempotenz sicherstellen

```yaml
# ❌ nicht idempotent: führt Befehl immer aus
- name: nginx installieren
  command: apt-get install -y nginx

# ✅ idempotent: prüft vorher ob schon installiert
- name: nginx installieren
  ansible.builtin.apt:
    name: nginx
    state: present
```

### Variablen klar strukturieren

```
roles/
└── webserver/
    ├── defaults/
    │   └── main.yml       ← niedrigste Priorität (Defaults)
    ├── vars/
    │   └── main.yml       ← höhere Priorität (Role-intern)
    └── tasks/
        └── main.yml
```

```yaml
# defaults/main.yml – immer überschreibbar
nginx_port: 80
nginx_user: www-data
```

### `ansible-lint` vor jedem Push

```bash
pip install ansible-lint
ansible-lint playbook.yml

# Häufige Fehler die lint findet:
# - fehlende `name` bei Tasks
# - command statt apt-Modul
# - hardcodierte Passwörter
```

### Secrets mit Vault verschlüsseln

```bash
# Datei verschlüsseln
ansible-vault encrypt group_vars/all/secrets.yml

# Im Playbook transparent nutzbar
ansible-playbook site.yml --ask-vault-pass
# oder:
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

---

## Allgemeine Regeln

| Regel                 | Docker                        | Kubernetes                     | Ansible                    |
| --------------------- | ----------------------------- | ------------------------------ | -------------------------- |
| Keine Secrets im Code | `.env` / Docker Secrets       | `Secret`-Objekte / Vault       | `ansible-vault`            |
| Versionierung         | Image-Tag pinnen              | `image: app:1.2.3`             | Rollen mit `meta/main.yml` |
| Monitoring            | Healthcheck                   | Liveness + Readiness Probe     | `ansible-lint`             |
| Minimale Rechte       | Non-root User                 | `securityContext.runAsNonRoot` | `become: yes` nur wo nötig |
| Reproduzierbarkeit    | Multi-Stage + `.dockerignore` | Ressource-Limits               | Idempotente Module         |

---

## Checkliste vor dem Deployment

```
Docker
  ☐ .dockerignore vorhanden?
  ☐ Kein root-Benutzer im Container?
  ☐ Image-Version konkret gepinnt?
  ☐ Multi-Stage Build verwendet?
  ☐ HEALTHCHECK im Dockerfile?

Kubernetes
  ☐ resource.limits gesetzt?
  ☐ readinessProbe definiert?
  ☐ Kein Passwort im YAML?
  ☐ Namespace korrekt?
  ☐ Labels vollständig?

Ansible
  ☐ Playbook mit ansible-lint geprüft?
  ☐ Secrets in vault verschlüsselt?
  ☐ Alle Tasks idempotent?
  ☐ Defaults in defaults/main.yml?
```
