#!/bin/bash
# ============================================================
# entrypoint-control.sh
# Runs when the Ansible control node container starts.
#
# What this does:
#   1. Generates an SSH key pair (if not already done)
#   2. Installs the private key into ~/.ssh/
#   3. Waits until both servers are reachable via SSH
#   4. Executes the CMD passed by docker-compose (tail -f /dev/null)
# ============================================================

set -e

echo ""
echo "=================================================="
echo " Ansible Control Node — Starting Up"
echo "=================================================="

# ──────────────────────────────────────────────────────────
# 1. Generate SSH key pair
#    Written to the shared Docker volume /ansible-keys so
#    the server containers can read the public key.
# ──────────────────────────────────────────────────────────
echo ""
echo "[1/3] SSH key pair..."

if [ ! -f /ansible-keys/id_rsa ]; then
    echo "      Generating new RSA 2048 key pair..."
    ssh-keygen -t rsa -b 2048 \
        -f /ansible-keys/id_rsa \
        -N "" \
        -C "ansible-lab-key"
    echo "      ✓ Keys written to shared volume /ansible-keys/"
else
    echo "      ✓ Key pair already exists — reusing it."
fi

# ──────────────────────────────────────────────────────────
# 2. Install private key into ~/.ssh/id_rsa
#    Ansible uses this to SSH into the managed servers.
# ──────────────────────────────────────────────────────────
echo ""
echo "[2/3] Installing private key into /root/.ssh/id_rsa ..."
cp /ansible-keys/id_rsa /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "      ✓ Done"

# ──────────────────────────────────────────────────────────
# 3. Wait for managed nodes to be ready
#    The server containers need a moment to:
#      a) Start sshd
#      b) Read the public key from the shared volume
#      c) Install it into their authorized_keys
# ──────────────────────────────────────────────────────────
echo ""
echo "[3/3] Waiting for managed nodes to accept SSH connections..."

SERVERS=("10.20.0.11" "10.20.0.12")

for host in "${SERVERS[@]}"; do
    echo -n "      Waiting for $host "
    connected=false
    for i in $(seq 1 40); do
        if ssh -o StrictHostKeyChecking=no \
               -o UserKnownHostsFile=/dev/null \
               -o ConnectTimeout=2 \
               -i /root/.ssh/id_rsa \
               root@"$host" "exit 0" 2>/dev/null; then
            echo " ✓ ready"
            connected=true
            break
        fi
        echo -n "."
        sleep 2
    done
    if [ "$connected" = false ]; then
        echo " (timeout — will retry when you run ansible)"
    fi
done

echo ""
echo "=================================================="
echo " Control node is READY"
echo ""
echo " Quick start commands:"
echo "   ansible all -m ping"
echo "   ansible-playbook /playbooks/01-ping.yml"
echo ""
echo " See /playbooks/ for all lab exercises."
echo " Edit playbooks from VS Code on your host machine."
echo "=================================================="
echo ""

# Hand off to CMD (tail -f /dev/null keeps the container alive)
exec "$@"
