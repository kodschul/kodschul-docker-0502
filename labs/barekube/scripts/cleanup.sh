#!/bin/bash
# ============================================================
# cleanup.sh
# Tear down everything (run from Windows PowerShell / WSL,
# NOT from inside a container).
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "${SCRIPT_DIR}")"

echo ""
echo "=================================================="
echo " Cleanup — Removing kubeadm lab cluster"
echo "=================================================="
echo ""

cd "${LAB_DIR}"

echo "[1] Stopping and removing containers..."
docker compose down --volumes --remove-orphans 2>/dev/null || true

echo ""
echo "[2] Removing Docker volumes..."
docker volume rm barekube_master-kubelet barekube_master-etcd barekube_master-kube \
                 barekube_worker1-kubelet barekube_worker2-kubelet 2>/dev/null || true

echo ""
echo "[3] Removing Docker network..."
docker network rm barekube_k8s-net 2>/dev/null || true

echo ""
echo "[4] Removing built images (optional — comment out to keep)..."
docker rmi barekube-master barekube-worker1 barekube-worker2 2>/dev/null || true
docker image prune -f 2>/dev/null || true

echo ""
echo "=================================================="
echo " ✅  Cleanup complete. All containers and volumes removed."
echo "=================================================="
echo ""
echo "  To restart the lab from scratch:"
echo "    cd labs/barekube"
echo "    docker compose build"
echo "    docker compose up -d"
echo ""
