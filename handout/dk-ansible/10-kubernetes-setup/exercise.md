# Übung: Kubernetes Setup und Arbeitsumgebung

**Zeit:** 30 min

---

## Aufgabe 1 – kubeconfig und Contexts (10 min)

```bash
# 1. Kubeconfig anzeigen
kubectl config view

# 2. Alle Contexts auflisten
kubectl config get-contexts

# 3. Aktuellen Context prüfen
kubectl config current-context

# 4. Standardmäßigen Namespace auf 'default' prüfen
kubectl config view --minify | grep namespace

# 5. Neuen Namespace erstellen und als Standard setzen
kubectl create namespace kurs
kubectl config set-context --current --namespace=kurs
kubectl config view --minify | grep namespace

# Zurück zu default
kubectl config set-context --current --namespace=default
```

---

## Aufgabe 2 – Namespace-getrennte Ressourcen (10 min)

```bash
# 1. Drei Namespaces anlegen
kubectl create namespace dev
kubectl create namespace staging

# 2. Je einen Pod in dev und staging starten
kubectl run web-dev --image=nginx:alpine -n dev
kubectl run web-staging --image=nginx:alpine -n staging

# 3. Pods in bestimmten Namespace anzeigen
kubectl get pods -n dev
kubectl get pods -n staging

# 4. Alle Pods aus allen Namespaces anzeigen
kubectl get pods -A

# 5. Frage: Sieht man web-dev wenn man "kubectl get pods" ohne -n aufruft?
kubectl get pods

# 6. Aufräumen
kubectl delete namespace dev staging
```

---

## Aufgabe 3 – kubectl Kurzreferenz üben (10 min)

```bash
# Starte eine Deployment
kubectl create deployment nginx-demo --image=nginx:alpine --replicas=2

# Skaliere auf 3 Replicas
kubectl scale deployment nginx-demo --replicas=3

# Beobachte die Pods
kubectl get pods -w   # Ctrl+C nach ~10s

# Details zum Deployment
kubectl describe deployment nginx-demo

# Port-Forward zum Testen
kubectl port-forward deployment/nginx-demo 8080:80 &
curl http://localhost:8080
kill %1   # Port-Forward beenden

# Aufräumen
kubectl delete deployment nginx-demo
```
