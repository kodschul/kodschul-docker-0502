# Übung: Kubernetes Einführung

**Zeit:** 30 min

---

## Aufgabe 1 – Cluster erkunden (10 min)

```bash
# 1. Cluster-Info anzeigen
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide

# 2. Alle Namespaces anzeigen
kubectl get namespaces

# 3. Was läuft im kube-system Namespace?
kubectl get pods -n kube-system
kubectl get all -n kube-system

# 4. Versionen vergleichen
kubectl version
```

**Fragen:**

- Wie viele Nodes hat dein Cluster?
- Welche Kubernetes-Version läuft?
- Welche System-Pods laufen im `kube-system` Namespace?

---

## Aufgabe 2 – Ersten Pod starten (10 min)

```bash
# 1. Pod direkt starten (imperativ)
kubectl run myfirst-pod --image=nginx:alpine

# 2. Status verfolgen
kubectl get pods
kubectl get pods -w    # live watch (Ctrl+C)

# 3. Details des Pods anzeigen
kubectl describe pod myfirst-pod

# 4. Logs lesen
kubectl logs myfirst-pod

# 5. In den Pod einsteigen
kubectl exec -it myfirst-pod -- sh
# Im Pod:
hostname
cat /etc/nginx/nginx.conf
exit

# 6. Pod löschen
kubectl delete pod myfirst-pod
```

---

## Aufgabe 3 – YAML-Manifest schreiben (10 min)

Schreibe ein YAML-Manifest `pod.yml` für einen Pod mit:

- Name: `hello-pod`
- Image: `nginx:alpine`
- Label: `app=hello`
- Ressourcen: 64Mi Memory, 100m CPU (als requests)

```bash
kubectl apply -f pod.yml
kubectl get pods
kubectl describe pod hello-pod
kubectl delete -f pod.yml
```

> Tipp: `kubectl explain pod.spec.containers` zeigt alle verfügbaren Felder.
