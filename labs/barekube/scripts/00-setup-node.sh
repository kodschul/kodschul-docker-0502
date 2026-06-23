#!/bin/bash
# ============================================================
# 00-setup-node.sh
# Run on EVERY node (master AND workers) before kubeadm.
#
# What this does (same steps you'd do on a real bare server):
#   1. Load kernel modules required by containerd / kubelet
#   2. Apply sysctl networking settings
#   3. Disable swap  (kubeadm refuses to run with swap on)
#   4. Start containerd
#   5. Show kubelet status (it will keep restarting until
#      kubeadm gives it a config — that is NORMAL)
# ============================================================
set -e

echo ""
echo "=================================================="
echo " Node Setup: $(hostname)"
echo "=================================================="

# ----------------------------------------------------------
# 1. Kernel modules
# ----------------------------------------------------------
echo ""
echo "[1/5] Loading kernel modules..."

modprobe overlay 2>/dev/null       && echo "  + overlay"       || echo "  ~ overlay (already loaded)"
modprobe br_netfilter 2>/dev/null  && echo "  + br_netfilter"  || echo "  ~ br_netfilter (already loaded)"

echo ""
echo "      Verification:"
lsmod | grep -E "^(overlay|br_netfilter)" | awk '{printf "        %-20s loaded\n", $1}' \
    || echo "      WARNING: some modules missing – may still work if built into kernel"

# ----------------------------------------------------------
# 2. Sysctl settings
# ----------------------------------------------------------
echo ""
echo "[2/5] Applying sysctl network settings..."
sysctl --system 2>&1 | grep -E "(Applying|bridge|forward)" | head -20
echo "      Done."

# Quick verification
V1=$(sysctl -n net.bridge.bridge-nf-call-iptables 2>/dev/null)
V2=$(sysctl -n net.ipv4.ip_forward 2>/dev/null)
echo "      net.bridge.bridge-nf-call-iptables = ${V1}"
echo "      net.ipv4.ip_forward                = ${V2}"

# ----------------------------------------------------------
# 3. Disable swap
# ----------------------------------------------------------
echo ""
echo "[3/5] Disabling swap..."
swapoff -a 2>/dev/null || true

SWAP=$(free -m | awk '/^Swap/{print $2}')
if [ "${SWAP}" = "0" ]; then
    echo "      Swap is OFF — OK"
else
    echo "      WARNING: Swap still enabled (${SWAP} MB)."
    echo "      kubeadm will be run with --ignore-preflight-errors=Swap"
fi

# ----------------------------------------------------------
# 4. Start containerd
# ----------------------------------------------------------
echo ""
echo "[4/5] Starting containerd..."

if systemctl is-active --quiet containerd; then
    echo "      containerd is already running"
else
    systemctl start containerd
    sleep 2
    systemctl is-active --quiet containerd \
        && echo "      containerd started OK" \
        || { echo "ERROR: containerd failed to start!"; systemctl status containerd --no-pager; exit 1; }
fi

# Verify the CRI socket exists
if [ -S /run/containerd/containerd.sock ]; then
    echo "      CRI socket: /run/containerd/containerd.sock — OK"
else
    echo "      WARNING: CRI socket not found at /run/containerd/containerd.sock"
fi

# ----------------------------------------------------------
# 5. Kubelet status
# ----------------------------------------------------------
echo ""
echo "[5/5] Checking kubelet..."
echo "      (kubelet will be in a crash-loop until kubeadm provides"
echo "       a config file — this is EXPECTED and NORMAL)"
echo ""
systemctl status kubelet --no-pager 2>&1 | head -20 || true

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo " ✅  $(hostname) is ready for kubeadm"
echo "=================================================="
echo ""
if [ "${ROLE}" = "master" ]; then
    echo "  NEXT STEP (on this master container):"
    echo "    bash /scripts/01-init-master.sh"
else
    echo "  NEXT STEP (on this worker container):"
    echo "    Wait for the master to initialize, then:"
    echo "    bash /scripts/02-join-worker.sh"
fi
echo ""
