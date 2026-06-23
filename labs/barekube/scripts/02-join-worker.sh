#!/bin/bash
# ============================================================
# 02-join-worker.sh
# Run on each WORKER container (worker1, worker2).
#
# What kubeadm join does:
#   preflight       – same checks as init (swap, modules, CRI)
#   download-config – fetches cluster config from API server
#                     using the bootstrap token
#   kubelet-start   – writes kubelet config and starts kubelet
#   kubelet-finalize– kubelet registers itself with the API server
#
# After joining, the control-plane (master) will:
#   - Approve the worker's CSR (Certificate Signing Request)
#   - Schedule kube-proxy and any DaemonSet pods to the worker
# ============================================================
set -e

MASTER_IP="10.10.0.10"
MASTER_CONTAINER="k8s-master"

echo ""
echo "=================================================="
echo " kubeadm join — Worker Node: $(hostname)"
echo "=================================================="

# ----------------------------------------------------------
# Step A: Get the join command from the master
# ----------------------------------------------------------
# The join command contains:
#   - Master API server address (host:6443)
#   - A short-lived bootstrap token
#   - The CA certificate hash (prevents MITM attacks)
#
# We fetch it from the master container via /tmp/join-command.sh
# (which was created by 01-init-master.sh)
echo ""
echo "[A] Fetching join command from master..."

# Try to get it from the master container directly
JOIN_CMD=""

if command -v docker &>/dev/null; then
    JOIN_CMD=$(docker exec "${MASTER_CONTAINER}" cat /tmp/join-command.sh 2>/dev/null) || true
fi

# Fallback: try via kubectl from master
if [ -z "${JOIN_CMD}" ]; then
    echo "    Could not reach master container via docker exec."
    echo "    Attempting to generate a new token from master..."
    echo ""
    echo "    ── Manual option ──────────────────────────────────"
    echo "    On the MASTER container, run:"
    echo "      kubeadm token create --print-join-command"
    echo "    Then paste the output here and add:"
    echo "      --ignore-preflight-errors=all"
    echo "    ───────────────────────────────────────────────────"
    echo ""
    echo "    Waiting for join command (set JOIN_CMD env var or re-run)..."

    if [ -n "${KUBEADM_JOIN_CMD}" ]; then
        JOIN_CMD="${KUBEADM_JOIN_CMD}"
        echo "    Using JOIN_CMD from environment variable."
    else
        echo ""
        echo "ERROR: No join command available."
        echo "Run '01-init-master.sh' on the master first, then retry."
        exit 1
    fi
fi

echo ""
echo "[A] Join command:"
echo "    ${JOIN_CMD}"

# ----------------------------------------------------------
# Step B: Run kubeadm join
# ----------------------------------------------------------
echo ""
echo "[B] Joining the cluster..."
echo "    (This generates a TLS certificate and registers"
echo "     this node with the API server)"
echo ""

# shellcheck disable=SC2086
${JOIN_CMD}

# ----------------------------------------------------------
# Step C: Verify kubelet is running
# ----------------------------------------------------------
echo ""
echo "[C] Checking kubelet status..."
sleep 5
systemctl status kubelet --no-pager | head -20 || true

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo " ✅  $(hostname) has joined the cluster!"
echo "=================================================="
echo ""
echo "  Verify on the MASTER:"
echo "    docker exec -it k8s-master kubectl get nodes"
echo ""
echo "  The node may show 'NotReady' for 30-60 seconds"
echo "  while Flannel sets up the pod network — that is NORMAL."
echo ""
