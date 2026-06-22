# 00e – Docker & Kubernetes in der Produktion

**Block:** 90 min | **Extra-Modul** (empfohlen: Ende Tag 3 als Abschluss)

---

## Von lokal zu Produktion

Ein Container der lokal funktioniert, ist noch keine produktionsreife Anwendung. Produktion bedeutet: zuverlässig, beobachtbar, sicher und wiederherstellbar – auch wenn gerade niemand am Rechner sitzt.

```
Lokal            →  Staging           →  Produktion
──────────────      ──────────────       ──────────────────────
docker run         docker compose       Kubernetes Cluster
ein Node           2-3 Nodes            ≥3 Control Plane Nodes
manuell restarten  depends_on           Self-Healing
kein Monitoring    Logs im Terminal     Prometheus + Grafana
Secrets in .env    Vault lokal          Kubernetes Secrets / HSM
```

---

## Thema 1: Container-Registry

### Welche Registry für Produktion?

| Registry                            | Wann nutzen                                     |
| ----------------------------------- | ----------------------------------------------- |
| Docker Hub                          | Open Source, kleine Teams, Public Images        |
| GitHub Container Registry (ghcr.io) | GitHub-Workflows, kostenlos für Public          |
| AWS ECR                             | AWS-Infrastruktur                               |
| Azure ACR                           | Azure Kubernetes Service (AKS)                  |
| Harbor (self-hosted)                | On-Premise, volle Kontrolle, Vulnerability-Scan |
| GitLab Registry                     | GitLab CI/CD integriert                         |

### Image-Tagging-Strategie

```bash
# ❌ nie in Produktion: latest
docker push myapp:latest

# ✅ semantische Versionierung
docker push myapp:2.1.0

# ✅ Git-SHA für reproduzierbare Deployments
docker push myapp:$(git rev-parse --short HEAD)
# z.B. myapp:a3f5c9d

# ✅ Kombination: Version + SHA
docker push myapp:2.1.0-a3f5c9d
```

### Image-Scanning vor dem Push

```bash
# Docker Scout (in Docker Desktop integriert)
docker scout cves myapp:2.1.0
docker scout recommendations myapp:2.1.0

# Trivy (CLI, kostenlos)
trivy image myapp:2.1.0

# In CI/CD (GitHub Actions)
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    exit-code: '1'          # Pipeline schlägt fehl bei kritischen CVEs
    severity: 'CRITICAL'
```

---

## Thema 2: Logging

### Zentrales Logging – warum?

Container sind flüchtig. Wenn ein Pod crasht und neu startet, sind die alten Logs weg – außer du leitest sie vorher woanders hin.

```bash
# Logs laufen nach stdout/stderr (Docker-Konvention)
# → Docker Logging Driver schreibt sie weiter

# Lokale Ansicht
docker logs -f mycontainer
kubectl logs -f pod/myapp-xyz --container=app

# Logs der vorherigen Container-Instanz
kubectl logs pod/myapp-xyz --previous
```

### Log-Stack: ELK / EFK

```
Container → stdout/stderr
    ↓
Fluentd / Filebeat (DaemonSet auf jedem Node)
    ↓
Elasticsearch (Speicherung + Indexierung)
    ↓
Kibana / Grafana (Visualisierung + Suche)
```

### Strukturiertes Logging

```python
# ❌ Freitext-Log – schwer zu durchsuchen
print(f"Fehler beim Verarbeiten der Anfrage von {user}")

# ✅ Strukturiertes JSON-Log – direkt filterbar
import json, sys
log = {"level": "error", "msg": "request failed", "user": user, "trace_id": "abc123"}
print(json.dumps(log), file=sys.stderr)
```

---

## Thema 3: Monitoring & Metriken

### Prometheus + Grafana

```
App → /metrics Endpoint
         ↓
    Prometheus (scrapen alle X Sekunden)
         ↓
    Grafana (Dashboards, Alerting)
```

```yaml
# Kubernetes: ServiceMonitor (Prometheus Operator)
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-monitor
spec:
  selector:
    matchLabels:
      app: backend
  endpoints:
    - port: metrics
      interval: 30s
```

### Was monitoren?

| Metrik             | Tool                 | Kubernetes-Gegenstück   |
| ------------------ | -------------------- | ----------------------- |
| CPU / RAM          | cAdvisor             | `kubectl top pods`      |
| Anfragen / Sekunde | Prometheus           | Ingress-Metriken        |
| Fehlerrate         | App-Metriken         | Liveness-Probe-Failures |
| Latenz (p95, p99)  | Prometheus Histogram | –                       |
| Disk-Nutzung       | Node Exporter        | PVC-Status              |

### Alerts einrichten

```yaml
# Prometheus Alerting Rule
groups:
  - name: backend.rules
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Fehlerrate > 5% seit 5 Minuten"
```

---

## Thema 4: Skalierung

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70 # skaliere hoch wenn > 70% CPU
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

```bash
kubectl get hpa                    # aktuellen Skalierungsstatus
kubectl describe hpa backend-hpa  # Events und Entscheidungen
```

### Pod Disruption Budget (PDB)

```yaml
# Sicherstellen: Bei Node-Wartung nie alle Pods gleichzeitig runter
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: backend-pdb
spec:
  minAvailable: 1 # mindestens 1 Pod muss immer laufen
  selector:
    matchLabels:
      app: backend
```

---

## Thema 5: Netzwerk & Ingress

### Ingress Controller

```yaml
# nginx Ingress: HTTP-Traffic auf Services verteilen
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod # TLS automatisch
spec:
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: backend
                port:
                  number: 8080
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80
```

### Network Policies (Isolation)

```yaml
# Nur Frontend darf Backend ansprechen – kein anderer Pod
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-only-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - port: 8080
```

---

## Thema 6: Secrets Management

### Kubernetes Secrets – Einschränkungen

Kubernetes `Secret`-Objekte sind standardmäßig Base64-kodiert, **nicht verschlüsselt**. Sie liegen im etcd-Cluster unverschlüsselt, wenn keine Encryption-at-Rest konfiguriert ist.

```bash
# Secret anlegen
kubectl create secret generic db-creds \
  --from-literal=password=geheim123

# Wert auslesen (Base64 dekodieren)
kubectl get secret db-creds -o jsonpath='{.data.password}' | base64 -d
```

### Bessere Alternativen

| Tool                          | Beschreibung                                        |
| ----------------------------- | --------------------------------------------------- |
| **Sealed Secrets**            | Verschlüsselte Secrets, sicher in Git speicherbar   |
| **HashiCorp Vault**           | Zentrales Secret-Management, dynamische Credentials |
| **External Secrets Operator** | Zieht Secrets aus AWS/Azure/GCP in Kubernetes       |
| **SOPS**                      | Verschlüsselte YAML/JSON-Dateien in Git             |

---

## Thema 7: Rolling Updates & Rollbacks

```yaml
# Deployment-Strategie konfigurieren
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1 # max 1 zusätzlicher Pod während Update
      maxUnavailable: 0 # kein Ausfall während Update
```

```bash
# Update durchführen
kubectl set image deployment/backend backend=myapp:2.1.0

# Update-Status beobachten
kubectl rollout status deployment/backend

# Rollback falls nötig
kubectl rollout undo deployment/backend

# Auf bestimmte Version zurück
kubectl rollout undo deployment/backend --to-revision=3

# Revisionshistorie anzeigen
kubectl rollout history deployment/backend
```

---

## Thema 8: Disaster Recovery

### Was du vorbereiten solltest

```
1. etcd-Backup (Kubernetes Cluster-State)
   → velero (Backup-Tool für K8s-Ressourcen + PVs)

2. Datenbank-Backups
   → CronJob in K8s oder externe Backup-Lösung

3. Image-Registry-Backup
   → Harbor Replikation auf zweite Registry

4. GitOps: Infrastruktur als Code
   → Alles in Git = Wiederherstellung durch "apply"
```

### Velero – Kubernetes-Backup

```bash
# Backup erstellen
velero backup create prod-backup --include-namespaces production

# Backup wiederherstellen
velero restore create --from-backup prod-backup

# Geplante Backups
velero schedule create daily-backup --schedule="0 2 * * *"
```

---

## Produktions-Checkliste

```
Registry & Images
  ☐ Versioniertes Tagging (kein latest)
  ☐ Vulnerability-Scan in CI/CD
  ☐ Private Registry mit Zugriffskontrolle

Kubernetes
  ☐ Mindestens 3 Nodes (HA)
  ☐ Resource Limits auf allen Deployments
  ☐ Liveness + Readiness Probes
  ☐ PodDisruptionBudget
  ☐ Network Policies
  ☐ RBAC konfiguriert
  ☐ Secrets nicht als Plaintext

Observability
  ☐ Zentrales Logging (EFK/Loki)
  ☐ Metriken (Prometheus)
  ☐ Dashboards (Grafana)
  ☐ Alerting eingerichtet

Betrieb
  ☐ Rolling Update Strategie definiert
  ☐ Rollback getestet
  ☐ Backup-Strategie vorhanden (Velero)
  ☐ Runbook für häufige Probleme
```
