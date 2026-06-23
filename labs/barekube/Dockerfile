# ============================================================
# Kubernetes Node Image
# Simulates a bare-metal server with kubeadm pre-installed.
# Used for BOTH master and worker nodes.
# ============================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# Tells systemd it is running inside a container
ENV container=docker

# -----------------------------------------------------------
# 1. Base packages
# -----------------------------------------------------------
RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    dbus \
    curl \
    wget \
    vim \
    net-tools \
    iputils-ping \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    socat \
    conntrack \
    ipset \
    iptables \
    iproute2 \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# 2. Strip down systemd so it can run inside a container
#    (Remove units that require real hardware / real kernel)
# -----------------------------------------------------------
RUN find /lib/systemd/system/sysinit.target.wants/ -type l \
        ! -name "systemd-tmpfiles-setup.service" -delete 2>/dev/null || true \
 && rm -f /lib/systemd/system/multi-user.target.wants/* \
          /etc/systemd/system/*.wants/* \
          /lib/systemd/system/local-fs.target.wants/* \
          /lib/systemd/system/sockets.target.wants/*udev* \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/* 2>/dev/null || true

# -----------------------------------------------------------
# 3. Install containerd (the CRI that kubelet will use)
#    We use Docker's repo because it ships a stable containerd.
# -----------------------------------------------------------
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
         -o /etc/apt/keyrings/docker.asc \
 && chmod a+r /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y containerd.io \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# 4. Configure containerd for Kubernetes
#    The critical setting: SystemdCgroup = true
#    Without this kubelet and containerd use different cgroup drivers
#    which causes pods to crash on startup.
# -----------------------------------------------------------
RUN mkdir -p /etc/containerd \
 && containerd config default > /etc/containerd/config.toml \
 && sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# -----------------------------------------------------------
# 5. Install kubeadm, kubelet, kubectl (v1.30)
#    - kubeadm : bootstraps the cluster
#    - kubelet  : the node agent (runs on every node)
#    - kubectl  : CLI to talk to the API server
# -----------------------------------------------------------
RUN mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
 && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' \
    > /etc/apt/sources.list.d/kubernetes.list \
 && apt-get update \
 && apt-get install -y kubelet kubeadm kubectl \
 && apt-mark hold kubelet kubeadm kubectl \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# 6. Kernel module configuration
#    overlay     : needed by containerd for layered filesystems
#    br_netfilter: needed for pod-to-pod networking across nodes
# -----------------------------------------------------------
RUN printf 'overlay\nbr_netfilter\n' > /etc/modules-load.d/k8s.conf

# -----------------------------------------------------------
# 7. Sysctl network settings (required by kubeadm preflight)
# -----------------------------------------------------------
RUN printf 'net.bridge.bridge-nf-call-iptables  = 1\n\
net.bridge.bridge-nf-call-ip6tables = 1\n\
net.ipv4.ip_forward                 = 1\n' \
    > /etc/sysctl.d/k8s.conf

# -----------------------------------------------------------
# 8. Tell kubelet not to fail if swap is detected
#    (Docker Desktop containers may report swap)
# -----------------------------------------------------------
RUN echo 'KUBELET_EXTRA_ARGS=--fail-swap-on=false' > /etc/default/kubelet

# -----------------------------------------------------------
# 9. Enable containerd and kubelet services
# -----------------------------------------------------------
RUN systemctl enable containerd kubelet

# cgroup fs needs to be mounted from the host
VOLUME ["/sys/fs/cgroup"]

# systemd is PID 1 — it will start containerd and kubelet
CMD ["/lib/systemd/systemd"]
