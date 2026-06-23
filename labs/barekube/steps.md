# Bare kubeadm on Docker Desktop — Step by Step

> **Goal**: Simulate a real 3-node on-premise Kubernetes cluster
> (1 control-plane + 2 workers) using Docker Desktop on Windows.
> Every step mirrors what you would do on real bare-metal servers.

---

## What You Are Building

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Windows Machine                      │
│                                                             │
│  Docker Desktop (WSL2)                                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Bridge Network: 10.10.0.0/24                        │  │
│  │                                                       │  │
│  │  ┌─────────────────┐   ┌──────────┐  ┌──────────┐   │  │
│  │  │   k8s-master    │   │ k8s-wkr1 │  │ k8s-wkr2 │   │  │
│  │  │  10.10.0.10     │   │10.10.0.11│  │10.10.0.12│   │  │
│  │  │                 │   │          │  │          │   │  │
│  │  │  kube-apiserver │   │ kubelet  │  │ kubelet  │   │  │
│  │  │  etcd           │   │containerd│  │containerd│   │  │
│  │  │  kube-scheduler │   │kube-proxy│  │kube-proxy│   │  │
│  │  │  controller-mgr │   │ flannel  │  │ flannel  │   │  │
│  │  │  kubelet        │   └──────────┘  └──────────┘   │  │
│  │  │  containerd     │                                 │  │
│  │  │  kube-proxy     │       Pod Network               │  │
│  │  │  flannel        │       10.244.0.0/16             │  │
│  │  └─────────────────┘                                 │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  Port 6443 → API server (kubectl from Windows host)         │
└─────────────────────────────────────────────────────────────┘
```

### File layout

```
labs/barekube/
├── steps.md              ← you are here
├── Dockerfile            ← node base image (Ubuntu + systemd + containerd + kubeadm)
├── docker-compose.yml    ← defines master, worker1, worker2
└── scripts/
    ├── 00-setup-node.sh  ← run on EVERY node (modules, sysctl, swap)
    ├── 01-init-master.sh ← run on MASTER (kubeadm init + Flannel)
    ├── 02-join-worker.sh ← run on WORKERS (kubeadm join)
    ├── 03-verify.sh      ← run on MASTER (deploy test app, check networking)
    └── cleanup.sh        ← tear everything down
```

---

## Prerequisites

| Requirement | Minimum | Check |
|---|---|---|
| Docker Desktop | 4.x or later | `docker version` |
| RAM available | 4 GB free | Task Manager |
| Disk space | 10 GB free | — |
| OS | Windows 10/11 with WSL2 | `wsl --status` |

> **WSL2 tip**: Enable systemd in WSL2 for best cgroup support:
> ```
> # Inside WSL2 shell, edit /etc/wsl.conf
> [boot]
> systemd=true
> ```
> Then restart WSL: `wsl --shutdown` in PowerShell.

---

## Concepts Before You Start

### What is kubeadm?
`kubeadm` is the official Kubernetes bootstrapping tool. It:
- Generates all TLS certificates
- Writes configuration files for every component
- Starts the control-plane as static Pods
- Creates a join token for workers

On a real bare server you would:
1. Install containerd (the container runtime)
2. Install kubeadm, kubelet, kubectl
3. Run `kubeadm init` on the master
4. Run `kubeadm join` on each worker

This lab does exactly those steps — inside Docker containers.

### Why Docker containers as "nodes"?
A Kubernetes node needs an OS with systemd and a container runtime.
Privileged Docker containers give us exactly that, with:
- Their own hostname and IP
- `systemd` as PID 1
- `containerd` managing workload containers
- Access to the kernel's cgroup and network stack

### Key terms
| Term | What it is |
|---|---|
| **Control Plane** | The node running the API server, scheduler, etcd |
| **Worker node** | A node that runs your application pods |
| **kubelet** | Agent on every node; takes orders from the API server |
| **containerd** | Low-level container runtime; actually runs containers |
| **kubeadm** | Bootstrap tool; only needed during setup |
| **CNI** | Container Network Interface — the pod networking layer |
| **Flannel** | The CNI plugin we install (simple overlay network) |
| **CRI socket** | The socket kubelet uses to talk to containerd |
| **static Pod** | A pod managed directly by kubelet (no scheduler needed) |

---

## Step 0 — Open a Terminal and go to the lab folder

```powershell
# PowerShell on Windows
cd C:\Users\User\Documents\kodschul\kodschul-docker-0502\labs\barekube
```

---

## Step 1 — Build the Node Image

The `Dockerfile` builds a single image used by all 3 nodes.
It pre-installs: `containerd`, `kubeadm`, `kubelet`, `kubectl`.

```powershell
docker compose build
```

**What happens:**
- Starts from `ubuntu:22.04`
- Installs `systemd` (init system — same as a real server)
- Installs `containerd` from Docker's repository
- Configures containerd with `SystemdCgroup = true` (required)
- Installs `kubeadm`, `kubelet`, `kubectl` v1.30
- Enables `containerd` and `kubelet` systemd services

> Build takes 5–10 minutes on first run (downloads ~1 GB of packages).

---

## Step 2 — Start All Three "Servers"

```powershell
docker compose up -d
```

This starts 3 privileged containers:

| Container | IP | Role |
|---|---|---|
| `k8s-master` | 10.10.0.10 | Control Plane |
| `k8s-worker1` | 10.10.0.11 | Worker |
| `k8s-worker2` | 10.10.0.12 | Worker |

**Verify they are running:**
```powershell
docker compose ps
docker ps
```

Expected output: all 3 containers in `Up` state.

**Peek inside a container (it looks like a real server):**
```powershell
docker exec -it k8s-master bash
hostname        # k8s-master
ip addr         # shows 10.10.0.10
systemctl status containerd
exit
```

---

## Step 3 — Prepare Every Node (run on all 3)

Open 3 separate terminals, one for each container.

**Terminal 1 (master):**
```powershell
docker exec -it k8s-master bash
bash /scripts/00-setup-node.sh
```

**Terminal 2 (worker1):**
```powershell
docker exec -it k8s-worker1 bash
bash /scripts/00-setup-node.sh
```

**Terminal 3 (worker2):**
```powershell
docker exec -it k8s-worker2 bash
bash /scripts/00-setup-node.sh
```

**What `00-setup-node.sh` does:**

1. **Loads kernel modules:**
   - `overlay` — containerd uses OverlayFS for image layers
   - `br_netfilter` — lets iptables see bridged traffic (required for pod networking)

2. **Applies sysctl settings:**
   - `net.bridge.bridge-nf-call-iptables = 1` — pod traffic goes through iptables
   - `net.ipv4.ip_forward = 1` — allows packet routing between pods

3. **Disables swap:**
   - kubelet refuses to start if swap is on (configurable but convention is off)

4. **Starts containerd:**
   - The CRI (Container Runtime Interface) that kubelet uses
   - Will manage all pod containers on this node

5. **Shows kubelet status (crash-loop is NORMAL here):**
   - kubelet has no config yet — it will keep restarting
   - `kubeadm init` will give it a config in the next step

---

## Step 4 — Initialize the Control Plane (master only)

In the **master terminal**:
```bash
bash /scripts/01-init-master.sh
```

**This runs `kubeadm init`. Here is what it does, phase by phase:**

### Phase 1: preflight
Checks everything is ready:
- Swap is off
- Kernel modules loaded
- Required ports are free (6443, 2379, 2380, 10250...)
- containerd socket exists

### Phase 2: certs
Generates a self-signed CA and TLS certificates for:
- `kube-apiserver` (server cert, signed by the CA)
- `etcd` (its own CA + cert)
- `kubelet` (client cert to talk to the API server)
- `kube-controller-manager` (client cert)
- `kube-scheduler` (client cert)
- `front-proxy` (for API aggregation)

All certs land in `/etc/kubernetes/pki/`.

### Phase 3: kubeconfig
Writes kubeconfig files so each component can authenticate:
```
/etc/kubernetes/
  admin.conf             ← for you (kubectl)
  controller-manager.conf
  scheduler.conf
  kubelet.conf
```

### Phase 4: kubelet-start
Writes kubelet's config and starts it as a systemd service.

### Phase 5: control-plane
Creates **static Pod manifests** in `/etc/kubernetes/manifests/`:
```
kube-apiserver.yaml
kube-controller-manager.yaml
kube-scheduler.yaml
```
kubelet watches that folder and starts those Pods automatically —
**no Deployment, no ReplicaSet** — just files on disk.

### Phase 6: etcd
Creates `/etc/kubernetes/manifests/etcd.yaml`.
etcd stores ALL cluster state (nodes, pods, secrets, configs...).

### Phase 7: upload-config + bootstrap-token
- Stores kubeadm config in a ConfigMap
- Creates a short-lived token workers use to bootstrap themselves

### Phase 8: addons
Deploys:
- **CoreDNS** — internal DNS so pods can resolve `service-name.namespace.svc.cluster.local`
- **kube-proxy** — sets up iptables/IPVS rules for Service routing on each node

**After kubeadm init, the script also:**
- Copies `admin.conf` to `~/.kube/config`
- Installs **Flannel** (CNI — pod networking)
- Saves the `kubeadm join` command to `/tmp/join-command.sh`

---

## Step 5 — Join the Workers

### In the worker1 terminal:
```bash
bash /scripts/02-join-worker.sh
```

### In the worker2 terminal:
```bash
bash /scripts/02-join-worker.sh
```

**What `kubeadm join` does:**

1. **preflight** — same checks as init
2. **download-config** — fetches cluster configuration from the master API server using the bootstrap token
3. **certs** — generates a unique certificate for this kubelet (CSR auto-approved by the master)
4. **kubelet-start** — starts kubelet with the new config; kubelet registers itself with the API server

After the join, on the **master**, check:
```bash
kubectl get nodes
```

Expected:
```
NAME          STATUS   ROLES           AGE   VERSION
k8s-master    Ready    control-plane   5m    v1.30.x
k8s-worker1   Ready    <none>          2m    v1.30.x
k8s-worker2   Ready    <none>          1m    v1.30.x
```

> **NotReady is normal for 30–60 seconds** while Flannel sets up the overlay network.

---

## Step 6 — Verify and Deploy a Test App

On the **master**:
```bash
bash /scripts/03-verify.sh
```

This:
1. Lists all nodes and waits for Ready status
2. Shows all system pods and explains what each one does
3. Deploys nginx with 3 replicas (one per node ideally)
4. Creates a ClusterIP Service
5. Runs a busybox pod to test pod-to-service connectivity
6. Tests CoreDNS resolution

---

## Step 7 — Explore Manually

Open a shell on the master and explore the cluster:

### See all running pods across all namespaces
```bash
kubectl get pods -A -o wide
```

### Look at what is inside etcd (the brain of the cluster)
```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only | head -40
```

### Watch the scheduler place a pod
```bash
# Terminal 1: watch pods
kubectl get pods -w

# Terminal 2: create a deployment
kubectl create deployment watch-me --image=nginx:alpine --replicas=5
```

### See the static Pod manifests (control plane config)
```bash
ls /etc/kubernetes/manifests/
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

### See certificates
```bash
ls /etc/kubernetes/pki/
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A2 "Subject\|Issuer\|Not"
```

### Node information
```bash
kubectl describe node k8s-worker1
kubectl get node k8s-worker1 -o yaml
```

### Scale and watch spreading
```bash
kubectl scale deployment nginx-demo --replicas=6
kubectl get pods -l app=nginx-demo -o wide
```

### Kill a pod and watch it come back
```bash
POD=$(kubectl get pods -l app=nginx-demo -o name | head -1)
kubectl delete ${POD}
kubectl get pods -l app=nginx-demo -w
```

### kubectl from Windows host (port 6443 is exposed)
In **PowerShell on Windows** (not inside a container):
```powershell
# Copy the kubeconfig from the master container
docker exec k8s-master cat /etc/kubernetes/admin.conf > $env:USERPROFILE\.kube\config-barekube

# Use it
$env:KUBECONFIG = "$env:USERPROFILE\.kube\config-barekube"
kubectl get nodes
kubectl get pods -A
```

---

## Understanding the Network

```
Pod on worker1 (10.244.1.x)  ──┐
                               │  Flannel overlay (VXLAN)
Pod on worker2 (10.244.2.x)  ──┤  (tunnels traffic between nodes)
                               │
Pod on master  (10.244.0.x)  ──┘

Service ClusterIP (10.96.x.x)
  │
  └── kube-proxy iptables rules on EACH node
      (redirects ClusterIP → actual pod IPs, load-balanced)

CoreDNS (10.96.0.10)
  └── Resolves "nginx-demo-svc.default.svc.cluster.local" → ClusterIP
```

### Three distinct IP ranges:
| Range | Purpose |
|---|---|
| `10.10.0.0/24` | Node IPs (our Docker bridge network) |
| `10.96.0.0/12` | Service ClusterIPs (virtual, iptables-routed) |
| `10.244.0.0/16` | Pod IPs (Flannel overlay) |

---

## Troubleshooting

### Nodes stay in NotReady
```bash
# On the node that is NotReady
kubectl describe node <node-name>

# Check kubelet logs
journalctl -u kubelet --no-pager | tail -50

# Check Flannel
kubectl get pods -n kube-flannel -o wide
kubectl logs -n kube-flannel <flannel-pod-name>
```

### kubelet crash-loop on a worker
```bash
journalctl -u kubelet --no-pager | grep -i error | tail -20
# Common fix: re-run setup-node.sh then retry join
```

### Pods stuck in Pending
```bash
kubectl describe pod <pod-name>
# Look at "Events" section — usually a scheduling issue
kubectl get events --sort-by='.lastTimestamp'
```

### kubeadm init fails with "port already in use"
The master container might have stale state. Reset and retry:
```bash
# On master
kubeadm reset -f
rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet/*
bash /scripts/01-init-master.sh
```

### containerd not running
```bash
systemctl start containerd
systemctl status containerd
journalctl -u containerd --no-pager | tail -30
```

### Cannot pull images (network issues in container)
```bash
# Test DNS from inside the container
curl -I https://registry.k8s.io
# Test containerd pull directly
ctr images pull docker.io/library/nginx:alpine
```

---

## What Is Different from a Real On-Premise Setup?

| Aspect | This Lab | Real Bare Metal |
|---|---|---|
| Hardware | Docker container | Physical or VM server |
| Kernel | Shared (WSL2 kernel) | Dedicated kernel |
| Networking | Docker bridge | Real NIC / switches |
| Storage | Docker volumes | Local disk / SAN / NFS |
| HA control plane | Single master | 3 masters + HAProxy |
| Load balancer | Port mapping | MetalLB / F5 / HAProxy |
| Ingress | Not configured | nginx-ingress / Traefik |

The **kubeadm commands are identical**. The concepts, certificates, and
bootstrap process are exactly the same. This lab gives you the muscle memory
for the real thing.

---

## Cleanup

```powershell
# From PowerShell on Windows, in the barekube folder
docker compose down --volumes --remove-orphans
```

Or run the cleanup script from inside WSL:
```bash
bash /scripts/cleanup.sh
```

This removes all containers, volumes, and the cluster network.

---

## Quick Reference — Commands Summary

```bash
# From Windows PowerShell
docker compose build                       # build node image
docker compose up -d                       # start 3 containers
docker compose ps                          # check status
docker exec -it k8s-master bash            # shell into master
docker exec -it k8s-worker1 bash           # shell into worker1
docker exec -it k8s-worker2 bash           # shell into worker2
docker compose down --volumes              # destroy everything

# Inside any container — node setup (run on ALL nodes)
bash /scripts/00-setup-node.sh

# Inside master only
bash /scripts/01-init-master.sh            # init cluster
kubectl get nodes                          # watch nodes join
kubectl get pods -A -o wide               # all pods

# Inside each worker
bash /scripts/02-join-worker.sh

# Inside master — verification
bash /scripts/03-verify.sh
kubectl get nodes -o wide
kubectl get pods -A
kubectl describe node k8s-worker1
kubectl logs -n kube-system <pod>
```
