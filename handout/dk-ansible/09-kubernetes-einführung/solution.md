# Lösung: Kubernetes Einführung

---

## Aufgabe 1

```bash
kubectl cluster-info
# Kubernetes control plane is running at https://127.0.0.1:6443

kubectl get nodes
# NAME             STATUS   ROLES           AGE   VERSION
# docker-desktop   Ready    control-plane   1d    v1.32.2

kubectl get nodes -o wide
# → zeigt IP, OS, Container Runtime (containerd)

kubectl get namespaces
# default       Active
# kube-node-lease Active
# kube-public   Active
# kube-system   Active

kubectl get pods -n kube-system
# coredns-xxx         1/1 Running   (DNS)
# etcd-xxx            1/1 Running   (Cluster-State)
# kube-apiserver-xxx  1/1 Running   (API)
# kube-controller-xxx 1/1 Running   (Controller)
# kube-proxy-xxx      1/1 Running   (Netzwerk)
# kube-scheduler-xxx  1/1 Running   (Scheduler)
```

---

## Aufgabe 2

```bash
kubectl run myfirst-pod --image=nginx:alpine

kubectl get pods -w
# myfirst-pod   0/1   ContainerCreating   0   2s
# myfirst-pod   1/1   Running             0   4s

kubectl describe pod myfirst-pod
# Events:
#   Pulled     Successfully pulled image "nginx:alpine"
#   Created    Created container myfirst-pod
#   Started    Started container myfirst-pod

kubectl logs myfirst-pod
# /docker-entrypoint.sh: Configuration complete; ready for start up

kubectl exec -it myfirst-pod -- sh
# / # hostname
# myfirst-pod   ← Pod-Name = Hostname
# / # exit

kubectl delete pod myfirst-pod
# pod "myfirst-pod" deleted
```

---

## Aufgabe 3

```yaml
# pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: hello-pod
  labels:
    app: hello
spec:
  containers:
    - name: nginx
      image: nginx:alpine
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
```

```bash
kubectl apply -f pod.yml
# pod/hello-pod created

kubectl get pods
# NAME        READY   STATUS    RESTARTS   AGE
# hello-pod   1/1     Running   0          5s

kubectl describe pod hello-pod
# Labels:  app=hello
# Requests: cpu: 100m, memory: 64Mi

kubectl delete -f pod.yml
# pod "hello-pod" deleted
```
