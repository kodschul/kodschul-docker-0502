#!/bin/bash
# ============================================================
# 01-init-master.sh
# Run on the MASTER (control-plane) container ONLY.
#
# What kubeadm init does step by step:
#   preflight   – checks swap, kernel modules, ports, CRI
#   certs       – generates TLS certificates for all components
#   kubeconfig  – writes admin / controller-manager / scheduler configs
#   kubelet     – writes kubelet config and starts it
#   control-plane – starts API server, scheduler, controller-manager as
#                   static Pods (Pod manifests in /etc/kubernetes/manifests)
#   etcd        – starts etcd as a static Pod
#   upload-config – stores kubeadm config in a ConfigMap
#   bootstrap-token – creates the token workers use to join
#   addons      – installs kube-proxy and CoreDNS
# ============================================================
set -e

MASTER_IP="10.10.0.10"
POD_CIDR="10.244.0.0/16"     # Flannel uses this range for pod IPs
K8S_VERSION="1.30.0"

echo ""
echo "=================================================="
echo " kubeadm init — Control Plane Initialization"
echo " Master IP : ${MASTER_IP}"
echo " Pod CIDR  : ${POD_CIDR}"
echo " Version   : v${K8S_VERSION}"
echo "=================================================="

# ----------------------------------------------------------
# Step A: Pull control-plane images
# ----------------------------------------------------------
# These are the images kubeadm will start as static Pods:
#   kube-apiserver, kube-controller-manager, kube-scheduler, etcd
echo ""
echo "[A] Pulling control-plane container images..."
echo "    (This can take 3-5 minutes on first run)"
kubeadm config images pull \
    --kubernetes-version=${K8S_VERSION} \
    --cri-socket unix:///run/containerd/containerd.sock

echo ""
echo "    Images pulled:"
crictl --runtime-endpoint unix:///run/containerd/containerd.sock images 2>/dev/null \
    | grep -E "(apiserver|etcd|scheduler|controller|coredns|pause)" \
    | awk '{printf "      %-60s %s\n", $1":"$2, $3}' || true

# ----------------------------------------------------------
# Step B: kubeadm init
# ----------------------------------------------------------
echo ""
echo "[B] Running kubeadm init..."
echo "    Output is saved to /tmp/kubeadm-init.log"
echo "    Watch with: tail -f /tmp/kubeadm-init.log"
echo ""

kubeadm init \
    --apiserver-advertise-address="${MASTER_IP}" \
    --pod-network-cidr="${POD_CIDR}" \
    --kubernetes-version="${K8S_VERSION}" \
    --cri-socket unix:///run/containerd/containerd.sock \
    --ignore-preflight-errors=all \
    2>&1 | tee /tmp/kubeadm-init.log

echo ""
echo "    kubeadm init finished."

# ----------------------------------------------------------
# Step C: Configure kubectl
# ----------------------------------------------------------
# kubeadm wrote /etc/kubernetes/admin.conf
# kubectl reads ~/.kube/config by default
echo ""
echo "[C] Setting up kubectl access..."

mkdir -p "${HOME}/.kube"
cp -f /etc/kubernetes/admin.conf "${HOME}/.kube/config"
chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

echo "    Kubeconfig written to: ${HOME}/.kube/config"
echo "    Test: kubectl cluster-info"
echo ""
kubectl cluster-info

# ----------------------------------------------------------
# Step D: Verify control plane pods
# ----------------------------------------------------------
echo ""
echo "[D] Control plane static pods (in kube-system namespace):"
kubectl get pods -n kube-system

# ----------------------------------------------------------
# Step E: Install Flannel (CNI — pod networking)
# ----------------------------------------------------------
# Without a CNI plugin, pods stay in "Pending" forever.
# Flannel creates a virtual network overlay so pods on
# different nodes can reach each other.
echo ""
echo "[E] Installing Flannel CNI (pod networking layer)..."
kubectl apply -f \
    https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo ""
echo "    Waiting for Flannel pods to be ready..."
kubectl wait --for=condition=Ready pod \
    -l app=flannel \
    -n kube-flannel \
    --timeout=120s 2>/dev/null \
|| kubectl wait --for=condition=Ready pod \
    -l app=flannel \
    -n kube-system \
    --timeout=120s 2>/dev/null \
|| echo "    (Flannel may take a moment — check: kubectl get pods -A)"

# ----------------------------------------------------------
# Step F: Wait for the master node to become Ready
# ----------------------------------------------------------
echo ""
echo "[F] Waiting for master node to be Ready..."
kubectl wait --for=condition=Ready node/k8s-master --timeout=180s
echo "    Master is Ready!"

# ----------------------------------------------------------
# Step G: Generate and save the join command for workers
# ----------------------------------------------------------
echo ""
echo "[G] Generating worker join command..."

JOIN_CMD=$(kubeadm token create --print-join-command)
echo "${JOIN_CMD} --ignore-preflight-errors=all" > /tmp/join-command.sh
chmod +x /tmp/join-command.sh

echo ""
echo "    Join command saved to: /tmp/join-command.sh"
echo ""

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo " ✅  Control plane is UP!"
echo "=================================================="
echo ""
echo "  Nodes so far:"
kubectl get nodes -o wide
echo ""
echo "  System pods:"
kubectl get pods -n kube-system
echo ""
echo "  ─────────────────────────────────────────────"
echo "  NEXT STEP — On each worker container, run:"
echo "    bash /scripts/02-join-worker.sh"
echo "  ─────────────────────────────────────────────"
echo ""
echo "  Worker join command (copy this to workers):"
echo ""
cat /tmp/join-command.sh
echo ""
