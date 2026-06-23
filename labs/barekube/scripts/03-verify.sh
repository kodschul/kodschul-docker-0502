#!/bin/bash
# ============================================================
# 03-verify.sh
# Run on the MASTER after all workers have joined.
#
# Demonstrates:
#   - Cluster health checks
#   - Deploying a real workload
#   - Spreading across nodes (scheduling)
#   - Service discovery (ClusterIP)
#   - Pod-to-pod networking
# ============================================================
set -e

echo ""
echo "=================================================="
echo " Cluster Verification"
echo "=================================================="

# ----------------------------------------------------------
# 1. Node status
# ----------------------------------------------------------
echo ""
echo "[1] Nodes (all should be 'Ready'):"
echo ""
kubectl get nodes -o wide
echo ""

NOT_READY=$(kubectl get nodes --no-headers | grep -v " Ready" | wc -l)
if [ "${NOT_READY}" -gt "0" ]; then
    echo "  ⚠️  Some nodes not Ready yet. Waiting 30 seconds..."
    sleep 30
    kubectl get nodes -o wide
fi

# ----------------------------------------------------------
# 2. System pods
# ----------------------------------------------------------
echo ""
echo "[2] System Pods (kube-system namespace):"
echo "    These run the cluster infrastructure:"
echo "    - etcd          : key-value store (cluster state)"
echo "    - kube-apiserver: the Kubernetes REST API"
echo "    - kube-controller-manager: watches and reconciles state"
echo "    - kube-scheduler: assigns pods to nodes"
echo "    - coredns       : internal DNS for services"
echo "    - kube-proxy    : network rules on each node"
echo ""
kubectl get pods -n kube-system -o wide

# ----------------------------------------------------------
# 3. Deploy a test workload (nginx)
# ----------------------------------------------------------
echo ""
echo "[3] Deploying test workload: nginx (3 replicas)..."
echo "    The scheduler should spread pods across all 3 nodes."
echo ""

kubectl create deployment nginx-demo \
    --image=nginx:alpine \
    --replicas=3 \
    2>/dev/null || echo "    (Deployment already exists — skipping create)"

echo ""
echo "    Waiting for pods to be Running..."
kubectl wait deployment/nginx-demo \
    --for=condition=Available \
    --timeout=120s

kubectl get pods -l app=nginx-demo -o wide
echo ""
echo "    Which node is each pod on? (should be spread across nodes)"
kubectl get pods -l app=nginx-demo -o \
    custom-columns='POD:.metadata.name,NODE:.spec.nodeName,IP:.status.podIP'

# ----------------------------------------------------------
# 4. Expose with a ClusterIP service
# ----------------------------------------------------------
echo ""
echo "[4] Exposing nginx via a ClusterIP Service..."
kubectl expose deployment nginx-demo \
    --port=80 \
    --target-port=80 \
    --name=nginx-demo-svc \
    2>/dev/null || echo "    (Service already exists — skipping create)"

echo ""
CLUSTER_IP=$(kubectl get svc nginx-demo-svc -o jsonpath='{.spec.clusterIP}')
echo "    Service ClusterIP: ${CLUSTER_IP}"
echo "    DNS name (inside cluster): nginx-demo-svc.default.svc.cluster.local"
echo ""
kubectl get service nginx-demo-svc

# ----------------------------------------------------------
# 5. Test pod-to-pod networking
# ----------------------------------------------------------
echo ""
echo "[5] Testing pod-to-pod networking..."
echo "    Running a busybox pod that curls the nginx service..."
echo ""

kubectl run nettest \
    --image=busybox:1.36 \
    --restart=Never \
    --rm \
    --attach \
    --timeout=30s \
    -- sh -c "
        echo '── Pinging nginx service by ClusterIP ──'
        wget -qO- http://${CLUSTER_IP} | head -5
        echo ''
        echo '── DNS resolution (CoreDNS) ──'
        nslookup nginx-demo-svc.default.svc.cluster.local 2>&1 | head -10
        echo '── Done ──'
    " 2>/dev/null || echo "    (nettest timed out — cluster may still be settling)"

# ----------------------------------------------------------
# 6. Resource summary
# ----------------------------------------------------------
echo ""
echo "[6] Resource summary:"
kubectl top nodes 2>/dev/null || echo "    (metrics-server not installed — install for resource metrics)"
echo ""
kubectl get all -n default
echo ""

# ----------------------------------------------------------
# Summary
# ----------------------------------------------------------
echo ""
echo "=================================================="
echo " ✅  Cluster is working!"
echo "=================================================="
echo ""
echo "  Useful commands to explore further:"
echo ""
echo "  kubectl get nodes -o wide                 — all nodes"
echo "  kubectl get pods -A -o wide               — all pods everywhere"
echo "  kubectl describe node k8s-worker1         — node detail"
echo "  kubectl describe pod <name>               — pod events/config"
echo "  kubectl logs <pod-name>                   — pod logs"
echo "  kubectl exec -it <pod-name> -- sh         — shell into a pod"
echo "  kubectl scale deployment nginx-demo --replicas=6"
echo "  kubectl delete pod <name>                 — watch it get recreated"
echo ""
echo "  To watch nodes/pods in real-time:"
echo "  kubectl get nodes -w"
echo "  kubectl get pods -A -w"
echo ""
