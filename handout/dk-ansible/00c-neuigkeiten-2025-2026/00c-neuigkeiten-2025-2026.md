# 00c – Docker & Kubernetes: Was sich seit 2025 geändert hat – und warum

**Block:** 60 min | **Extra-Modul** (empfohlen: Beginn Tag 2 oder als eigenständige Update-Session)

---

## Warum dieses Modul?

Docker und Kubernetes sind keine fertige Software, die irgendwann „fertig" wird. Sie werden aktiv weiterentwickelt. Das bedeutet: Befehle, die vor 2 Jahren funktionierten, können heute veraltet sein – und neue Features vereinfachen Dinge, für die es früher einen Workaround brauchte.

Wer ein Tutorial von 2022 oder 2023 befolgt, wird auf Dinge stoßen, die so heute nicht mehr funktionieren. Dieses Modul erklärt: **Was hat sich geändert, seit wann, und vor allem warum.**

---

## Docker – Änderungen ab 2025

---

### `docker-compose` ist weg – es lebe `docker compose`

**Seit wann?** Das alte Binary `docker-compose` wurde mit Docker Desktop 4.34 (Ende 2024) entfernt. `docker compose` V2 gibt es seit 2022.

**Warum wurde es geändert?**

Das alte `docker-compose` war ein eigenständiges Python-Programm, das separat installiert werden musste. Es hatte eigene Versionsnummern, eigene Bugs, und musste mit der Docker CLI immer kompatibel gehalten werden – was regelmäßig schiefging. Docker hat Compose neu in Go geschrieben und direkt als Plugin in die Docker CLI eingebaut. Ergebnis: Ein Befehl, eine Installation, keine Synchronisations-Probleme.

```bash
# ❌ Alt – funktioniert nicht mehr (Binary entfernt):
docker-compose up
docker-compose down

# ✅ Heute – direkt in Docker eingebaut:
docker compose up
docker compose down
```

> **Einfach ausgedrückt:** `docker-compose` (mit Bindestrich) war ein separates Tool wie ein Fremdschlüssel. `docker compose` (mit Leerzeichen) ist jetzt eingebaut wie ein Hausschlüssel.

```bash
# Prüfen ob noch altes Binary existiert:
which docker-compose       # leer = gut; Pfad = noch alt installiert

# V2 bestätigen:
docker compose version     # muss "v2.x.x" zeigen
```

---

### `compose.yml` statt `docker-compose.yml`

**Seit wann?** Empfohlen seit Compose V2 (2022), Standard ab 2024.

**Warum?**

Der neue Name macht klar: Compose ist kein Docker-exklusives Tool mehr. Das Format ist offen und kann mit jedem OCI-kompatiblen System verwendet werden. Außerdem ist `compose.yml` schlicht kürzer. Beide Namen werden noch erkannt, aber `compose.yml` ist die Zukunft.

```bash
mv docker-compose.yml compose.yml   # einmalige Umbenennung
```

---

### BuildKit ist automatisch aktiv

**Seit wann?** Docker 23.0 (Februar 2023). Kein manuelles Aktivieren mehr nötig.

**Was war das Problem vorher?**

Der alte Build-Mechanismus war sequenziell: Layer für Layer, keine parallelen Stages, kein modernes Caching. BuildKit ist der moderne Build-Motor – parallele Stages, intelligenter Cache, weniger Wartezeit.

```bash
# ❌ Früher musste BuildKit explizit aktiviert werden:
DOCKER_BUILDKIT=1 docker build .

# ✅ Heute: automatisch aktiv, kein Flag nötig:
docker build .
```

> **Einfach ausgedrückt:** Früher war der Build wie eine Fließband-Fabrik – eine Station nach der anderen. BuildKit ist eine moderne Fabrik mit parallelen Linien.

```bash
# Neues Cache-Feature – nützlich in CI/CD:
docker build --cache-to type=local,dest=/tmp/cache .
docker build --cache-from type=local,src=/tmp/cache .
# → Erste Pipeline: langsam. Jede weitere: schnell.
```

---

### `depends_on` wartet jetzt wirklich

**Seit wann?** `condition: service_healthy` gibt es seit Compose V2 (2022). Viele nutzen es aber noch nicht, weil ältere Tutorials es nicht erwähnen.

**Was war das Problem vorher?**

Das alte `depends_on: - db` bedeutete nur: „starte den Backend-Container _nach_ dem DB-Container". Es hat aber **nicht gewartet**, bis die Datenbank wirklich bereit war. Das führte zu einem klassischen Fehler: Backend startet, versucht die DB zu erreichen, DB ist noch nicht hochgefahren → Verbindungsfehler → Crash.

```yaml
# ❌ Alt – startet Backend sobald db-Container *läuft*, nicht wenn db *bereit* ist:
depends_on:
  - db

# ✅ Neu – wartet bis Healthcheck grünes Licht gibt:
depends_on:
  db:
    condition: service_healthy

db:
  image: postgres:16
  healthcheck:
    test: ["CMD", "pg_isready"]
    interval: 5s
    retries: 5
```

> **Einfach ausgedrückt:** Früher hat depends_on nur gewartet, bis die Tür aufgeht. Heute wartet es, bis jemand hinter der Tür steht und „bereit!" sagt.

---

### `docker compose watch` – Hot-Reload ohne Volume-Probleme

**Seit wann?** Stabil seit Compose 2.22 (Oktober 2023), produktionsreif 2024.

**Was war das Problem vorher?**

Der klassische Ansatz für Entwicklung war ein Bind Mount: lokaler Ordner wird direkt ins Container-Dateisystem gemountet. Das hat ein Problem: Auf macOS und Windows kommen Dateisystem-Events (Änderungen) mit Verzögerung oder gar nicht im Container an. Resultat: Code-Änderungen werden nicht erkannt.

`compose watch` löst das: Docker beobachtet Dateien selbst und sendet Änderungen gezielt in den Container.

```yaml
services:
  frontend:
    develop:
      watch:
        - path: ./src
          action: sync # Datei geändert → direkt in Container kopieren
          target: /app/src
        - path: package.json
          action: rebuild # package.json geändert → Image neu bauen
```

```bash
docker compose watch
```

> **Einfach ausgedrückt:** Statt deinen Schreibtisch (lokaler Ordner) ins Büro (Container) zu schieben, schaut watch aktiv nach Änderungen und schickt nur das Nötige rein – zuverlässiger auf allen Plattformen.

---

### `docker debug` – Shell in jeden Container

**Seit wann?** Preview 2023, produktionsreif Docker Desktop 4.33 (2024).

**Was war das Problem vorher?**

Ein Container crasht. Man will reinschauen. Aber das Image ist `alpine` oder `scratch` – keine Shell, keine Tools installiert. Früher: Image anpassen, neu bauen, neu starten, debuggen. Mit `docker debug` bringt Docker ein Toolset-Image mit und hängt es in den laufenden Container ein – das Original-Image bleibt unverändert.

```bash
# Container hat kein bash, trotzdem Shell öffnen:
docker debug my-container

# Mit bestimmtem Toolset-Image (z.B. für mehr Tools):
docker debug --image=ubuntu my-container
```

> **Einfach ausgedrückt:** Wie wenn man einen Werkzeugkoffer durch ein Fenster schiebt, ohne die Fabrik umzubauen.

---

### `docker init` – Dockerfile + Compose generieren lassen

**Seit wann?** Seit Docker Desktop 4.27 (2023), stabil seit 2024.

**Warum?**

Für neue Projekte ein Dockerfile und eine compose.yml von Hand zu schreiben dauert. `docker init` fragt nach Sprache und Einstellungen und generiert fertige Startdateien – mit aktuellen Best Practices.

```bash
docker init
# → Welche Sprache? (Python / Node / Go / ...)
# → Welche Version?
# → Welcher Port?
# → Generiert: Dockerfile + compose.yml + .dockerignore
```

---

### Docker Hub Rate Limits verschärft

**Seit wann?** November 2024.

**Was hat sich geändert?**

Anonyme Pulls (ohne Docker-Login) sind auf **10 Pulls pro Stunde pro IP** begrenzt. Das klingt nach viel, ist aber in CI/CD-Pipelines schnell erreicht – besonders wenn viele Entwickler die gleiche IP nutzen (Firmen-NAT, VPN).

**Lösung:**

```bash
# In CI immer einloggen:
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Oder: eigene Registry / Mirror verwenden
```

---

## Kubernetes – Änderungen ab 2025

---

### Kubernetes erscheint alle 4 Monate – warum das wichtig ist

**Seit wann?** Dieser 3-Releases-pro-Jahr-Rhythmus gilt seit K8s 1.22 (2021) konsequent.

**Warum das wichtig ist:**

Kubernetes unterstützt immer nur die letzten 3 Minor-Versionen mit Security-Patches. Wer auf einer alten Version steckt, bekommt keine Sicherheits-Updates mehr. Das ist kein Marketing – das ist ein echtes Risiko.

| Version  | Erschienen    | End of Support (ca.) |
| -------- | ------------- | -------------------- |
| **1.30** | April 2024    | Juni 2025            |
| **1.31** | August 2024   | Oktober 2025         |
| **1.32** | Dezember 2024 | Februar 2026         |
| **1.33** | April 2025    | Juni 2026            |
| **1.34** | August 2025   | Oktober 2026         |

---

### `dockershim` ist seit K8s 1.24 (Mai 2022) entfernt

**Seit wann?** K8s 1.24. Viele Tutorials (und Anleitungen) erwähnen das nicht – deshalb hier explizit.

**Was ist dockershim und warum wurde es entfernt?**

Früher nutzte Kubernetes Docker als Container-Runtime. Das Problem: Docker ist kein reines Container-Runtime-Tool. Es bringt eine eigene CLI, einen Daemon, Build-Werkzeuge und vieles mehr mit – alles unnötiger Overhead für Kubernetes. Um Docker trotzdem nutzen zu können, gab es `dockershim` – eine Übersetzungsschicht zwischen Kubernetes und Docker.

Diese Schicht wurde entfernt. Kubernetes redet jetzt direkt mit `containerd` – dem eigentlichen Container-Mechanismus, der auch hinter Docker steckt.

```
Früher:   kubectl → kubelet → dockershim → Docker → containerd → Container
Heute:    kubectl → kubelet → containerd → Container
```

> **Einfach ausgedrückt:** Früher musste man Docker als Vermittler anrufen, um Container zu starten. Heute redet man direkt mit containerd – wie Direktbuchung statt Reisebüro.

**Was das für dich bedeutet:**

- `docker build` auf deinem Entwicklerrechner → funktioniert weiterhin
- Docker-Images im Cluster deployen → funktioniert weiterhin (OCI-Format ist kompatibel)
- Docker als Runtime im K8s-Cluster → läuft nicht mehr

---

### `PodSecurityPolicy` ist seit K8s 1.25 (September 2022) entfernt

**Seit wann?** Abgekündigt K8s 1.21, entfernt K8s 1.25.

**Was war PodSecurityPolicy?**

PSP war das alte System, um zu kontrollieren was Pods dürfen: Kein root, kein privileged mode, kein HostPath-Volume usw. Das Problem: Es war extrem komplex zu konfigurieren, hatte kontraintuitive Vererbungsregeln und führte oft dazu, dass Admins alle Einschränkungen deaktivierten – weil es so kompliziert war.

**Ersatz: Pod Security Admission (PSA)** – standardmäßig aktiv seit K8s 1.25.

```yaml
# Namespace mit PSA absichern (statt PSP)
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    # "restricted" blockiert Pods die als root laufen, privilegiert sind etc.
```

**Profile:**

- `privileged` – keine Einschränkungen (nur für vertrauenswürdige Infra-Tools)
- `baseline` – verbietet offensichtlich gefährliche Konfigurationen
- `restricted` – strikteste Einstellungen (non-root, kein privilege escalation)

> **Einfach ausgedrückt:** PSP war wie ein Türsteher mit 50-seitigem Regelwerk. PSA ist wie ein Türsteher mit drei klaren Zonen: offen, mittel, streng.

---

### Sidecar Containers – GA seit K8s 1.33 (April 2025)

**Seit wann?** Alpha K8s 1.28 (2023), Beta 1.29, GA (General Availability = stabil, produktionsreif) seit 1.33.

**Was ist ein Sidecar und warum brauchte es dafür eine Lösung?**

Manchmal soll ein zweiter Container neben der eigentlichen App laufen – z.B. ein Logging-Agent, ein Proxy (wie Envoy/Istio) oder ein Monitoring-Collector. Das ist ein Sidecar-Container.

Früher gab es dafür kein natives Konzept. Man musste Workarounds nutzen (Init-Container mit `sleep infinity`), die sich falsch anfühlten und Edge-Cases hatten.

```yaml
# ✅ Neu: nativer Sidecar (K8s 1.33+)
# Ein initContainer mit restartPolicy: Always ist ein Sidecar
initContainers:
  - name: log-collector
    image: fluentd:v1.16
    restartPolicy: Always # ← dieses eine Feld macht es zum Sidecar
```

Ein Sidecar-Container (so definiert):

- Startet **vor** den App-Containern
- Läuft **parallel** solange die App läuft
- Beendet sich **nach** dem App-Container automatisch

> **Einfach ausgedrückt:** Früher gab es nur Vorarbeiter (Init-Container, beenden sich) oder gleichberechtigte Kollegen (normale Container). Jetzt gibt es einen dauerhaften Assistenten, der immer dabei ist und am Ende geht.

---

### In-place Pod Resource Resize – GA seit K8s 1.34 (August 2025)

**Seit wann?** Alpha K8s 1.27, GA seit 1.34.

**Was war das Problem vorher?**

Wenn du in K8s 1.33 oder älter die CPU- oder RAM-Zuweisung eines Pods ändern wolltest, musste der Pod gelöscht und neu gestartet werden. Das bedeutete: kurzer Ausfall, neue Pod-IP, eventuell verlorene Verbindungen oder Sessions.

```bash
# ❌ Alt: Ressourcen ändern = Pod neu starten (kurzer Ausfall)
kubectl edit deployment myapp   # → Rolling Restart ausgelöst

# ✅ Neu (K8s 1.34+): Ressourcen live patchen OHNE Neustart
kubectl patch pod mypod \
  --patch '{"spec":{"containers":[{"name":"app","resources":{"requests":{"cpu":"500m"}}}]}}'
```

> **Einfach ausgedrückt:** Früher musstest du ein Restaurant schließen, um mehr Stühle reinzustellen. Heute kann man sie umstellen während die Gäste sitzen.

---

### Neue `kubectl`-Befehle 2025/2026

```bash
# Events nach Zeit sortiert (sehr praktisch beim Debuggen!)
kubectl events --for pod/myapp --watch
# Früher: kubectl describe pod/myapp und in Events-Abschnitt scrollen

# Interaktives Löschen mit Bestätigung
kubectl delete pod --interactive
# Fragt nach: "Delete pod/myapp? [y/N]"

# Alle Ressourcen mit Labels anzeigen
kubectl get all -l app=myapp --show-labels
```

---

## Abgekündigte Features im Überblick

| Feature                   | Entfernt seit                    | Ersatz                      | Warum entfernt                          |
| ------------------------- | -------------------------------- | --------------------------- | --------------------------------------- |
| `docker-compose` Binary   | Docker Desktop 4.34 (2024)       | `docker compose`            | Python-Tool → Go-Plugin in CLI          |
| `PodSecurityPolicy`       | K8s 1.25 (2022)                  | Pod Security Admission      | Zu komplex, zu fehleranfällig           |
| `dockershim`              | K8s 1.24 (2022)                  | containerd direkt           | Docker als Runtime = unnötiger Overhead |
| `kubectl run --generator` | K8s 1.18 (2020)                  | `kubectl create deployment` | API-Vereinfachung                       |
| Docker Hub anonyme Pulls  | Seit Nov 2024 auf 10/h limitiert | Eigene Registry / Login     | Kostenkontrolle bei Docker              |

---

## Was du jetzt sofort prüfen und anpassen solltest

```bash
# 1. Altes docker-compose-Binary suchen
which docker-compose
# → leer = gut. Wenn ein Pfad erscheint: upgrade Docker Desktop.

# 2. Compose V2 bestätigen
docker compose version
# → muss "Docker Compose version v2.x.x" zeigen

# 3. Docker-Version prüfen
docker version
# → Engine sollte ≥ 25.x sein

# 4. Dateiname modernisieren (falls noch nicht gemacht)
mv docker-compose.yml compose.yml

# 5. Kubernetes-Version prüfen
kubectl version
# → Server Version: v1.32+ ist gut, v1.28 oder älter → dringend updaten
```

---

## Zusammenfassung: Was 2025/2026 wirklich wichtig ist

```
Docker
├── docker compose (V2)  → Pflicht, kein Bindestrich mehr
├── compose.yml          → neuer Standard-Dateiname
├── BuildKit             → automatisch aktiv seit Docker 23
├── depends_on + healthy → wartet wirklich auf Bereitschaft
├── docker compose watch → Hot-Reload ohne Volume-Probleme
└── docker debug         → Shell in jedes Image ohne Umbau

Kubernetes
├── containerd           → kein dockershim seit K8s 1.24
├── PSA                  → ersetzt PodSecurityPolicy seit K8s 1.25
├── Sidecar Containers   → nativer Nebenläufer, GA seit K8s 1.33
└── In-place Pod Resize  → CPU/RAM live ändern ohne Neustart, GA seit K8s 1.34
```
