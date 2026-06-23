#!/bin/bash
# ============================================================
# entrypoint-server.sh
# Runs when a managed node container starts.
#
# What this does:
#   1. Generates SSH host keys (server identity)
#   2. Waits for the control node to publish its public key
#      in the shared /ansible-keys/ volume
#   3. Installs that public key as an authorized key for root
#   4. Starts the SSH daemon in the foreground (keeps container alive)
# ============================================================

echo ""
echo "=================================================="
echo " Managed Node Starting: $(hostname)"
echo "=================================================="

# ──────────────────────────────────────────────────────────
# 1. Generate SSH host keys (server's own identity)
#    These are normally created once during OS install.
#    ssh-keygen -A creates all missing host key types.
# ──────────────────────────────────────────────────────────
echo ""
echo "[1/3] Generating SSH host keys..."
ssh-keygen -A 2>/dev/null
echo "      ✓ Host keys ready"

# ──────────────────────────────────────────────────────────
# 2. Wait for the control node's public key
#    The control container generates the key pair and writes
#    it to the shared volume.  We wait up to 60 seconds.
# ──────────────────────────────────────────────────────────
echo ""
echo "[2/3] Waiting for control node's public key..."
WAITED=0
while [ ! -f /ansible-keys/id_rsa.pub ]; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ $WAITED -ge 60 ]; then
        echo "      WARNING: Timed out waiting for public key."
        echo "      SSH will start but Ansible may not be able to connect."
        echo "      Try restarting with: docker compose restart"
        break
    fi
done

if [ -f /ansible-keys/id_rsa.pub ]; then
    echo "      ✓ Public key found after ${WAITED}s"
fi

# ──────────────────────────────────────────────────────────
# 3. Install the control node's public key
#    This is the equivalent of running ssh-copy-id on a real
#    server — it allows Ansible to log in without a password.
# ──────────────────────────────────────────────────────────
echo ""
echo "[3/3] Installing authorized key for root..."
if [ -f /ansible-keys/id_rsa.pub ]; then
    cat /ansible-keys/id_rsa.pub > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "      ✓ Authorized key installed"
    echo "      Key fingerprint: $(ssh-keygen -lf /ansible-keys/id_rsa.pub 2>/dev/null | awk '{print $2}')"
else
    echo "      WARNING: No public key found — root login via key will fail"
fi

echo ""
echo "=================================================="
echo " $(hostname) is READY"
echo " SSH daemon starting on port 22..."
echo "=================================================="
echo ""

# ──────────────────────────────────────────────────────────
# 4. Start SSH daemon in the foreground
#    -D = do not daemonize (keeps the container alive)
#    -e = log to stderr (visible in docker logs)
# ──────────────────────────────────────────────────────────
exec /usr/sbin/sshd -D -e
