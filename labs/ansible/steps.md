# Ansible Basics — Interactive Docker Lab

> **Goal**: Learn Ansible by running it against real (containerised) servers.
> You get a control node and two managed servers, all wired up and ready.
> No cloud account, no VMs, no manual SSH key setup — just Docker.

---

## What You Are Building

```
┌─────────────────────────────────────────────────────────────────┐
│                     Your Windows Machine                         │
│                                                                  │
│  Docker Desktop (WSL2)                                           │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Bridge Network: 10.20.0.0/24                           │    │
│  │                                                         │    │
│  │  ┌──────────────────────┐                               │    │
│  │  │   ansible-control    │   You run commands here       │    │
│  │  │     10.20.0.10       │   Ansible + SSH client        │    │
│  │  │                      │                               │    │
│  │  │  ansible-playbook    │──────SSH────────────────┐     │    │
│  │  │  ansible all -m ping │──────SSH────────┐       │     │    │
│  │  └──────────────────────┘                 ▼       ▼     │    │
│  │                              ┌─────────┐ ┌─────────┐   │    │
│  │                              │ server1 │ │ server2 │   │    │
│  │                              │10.20.0.11│ │10.20.0.12│  │    │
│  │                              │ Ubuntu  │ │ Ubuntu  │   │    │
│  │                              │  + SSH  │ │  + SSH  │   │    │
│  │                              │ + Python│ │ + Python│   │    │
│  │                              └─────────┘ └─────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### File Layout

```
labs/ansible/
├── steps.md              ← you are here
├── docker-compose.yml    ← defines control, server1, server2
├── Dockerfile.control    ← control node image (Ubuntu + Ansible)
├── Dockerfile.server     ← managed node image (Ubuntu + SSH)
├── ansible.cfg           ← Ansible settings (copied into the image)
├── inventory/
│   └── hosts.ini         ← server list (edit this to add more servers)
├── playbooks/
│   ├── 01-ping.yml       ← verify connectivity
│   ├── 02-files.yml      ← create files on remote servers
│   ├── 03-facts.yml      ← explore system facts
│   ├── 04-packages.yml   ← install packages with apt
│   ├── 05-variables.yml  ← variables and templates
│   └── 06-your-playbook.yml  ← exercise: write your own
└── scripts/
    ├── entrypoint-control.sh  ← control node startup
    └── entrypoint-server.sh   ← server startup (generates SSH trust)
```

---

## Concepts Before You Start

### What is Ansible?

Ansible is an **agentless automation tool**. It connects to servers via SSH
and runs tasks on them. "Agentless" means you install nothing on the managed
servers — you only need Python (which every Linux server already has).

```
[your machine / control node]
        │
        │  SSH (port 22)
        ▼
[managed server]
  Python 3 already installed
  Ansible runs Python snippets here temporarily
```

### Key vocabulary

| Term             | What it is                                                        |
| ---------------- | ----------------------------------------------------------------- |
| **Control node** | Where Ansible is installed; where you run commands                |
| **Managed node** | The server Ansible configures remotely                            |
| **Inventory**    | A file listing which servers exist and how to reach them          |
| **Playbook**     | A YAML file describing what to do on which servers                |
| **Task**         | One action in a playbook (e.g. "install nginx")                   |
| **Module**       | The built-in action type for a task (ping, copy, apt, …)          |
| **Facts**        | Variables Ansible collects automatically from the server          |
| **Idempotent**   | Running a playbook twice produces the same result (no duplicates) |

### What is a Playbook?

```yaml
---
- name: "My first playbook"
  hosts: servers # which servers to target

  tasks:
    - name: Install curl
      ansible.builtin.apt:
        name: curl
        state: present
```

Reading it out loud: _"On all servers, run one task: use the apt module
to ensure curl is present (installed if not already there)."_

### What is an Inventory?

```ini
[servers]              # ← group name
server1  ansible_host=10.20.0.11
server2  ansible_host=10.20.0.12

[servers:vars]         # ← variables for the whole group
ansible_user=root
ansible_ssh_private_key_file=/root/.ssh/id_rsa
```

---

## Prerequisites

| Requirement                            | Check            |
| -------------------------------------- | ---------------- |
| Docker Desktop running                 | `docker version` |
| 1 GB of free RAM                       | Task Manager     |
| Internet access (to pull Ubuntu image) | —                |

---

## Step 0 — Open a Terminal and Go to the Lab Folder

```powershell
# PowerShell on Windows
cd C:\Users\User\Documents\kodschul\kodschul-docker-0502\labs\ansible
```

---

## Step 1 — Build the Images

```powershell
docker compose build
```

**What happens:**

- Builds `Dockerfile.control` → installs Ansible, Python, SSH client
- Builds `Dockerfile.server` → installs SSH server, Python

> First build takes 2–4 minutes (downloads Ubuntu + packages).

---

## Step 2 — Start All Three Containers

```powershell
docker compose up -d
```

This starts 3 containers:

| Container         | IP         | Role                            |
| ----------------- | ---------- | ------------------------------- |
| `ansible-control` | 10.20.0.10 | Control node — run Ansible here |
| `ansible-server1` | 10.20.0.11 | Managed node 1                  |
| `ansible-server2` | 10.20.0.12 | Managed node 2                  |

**What happens automatically on startup:**

1. `ansible-control` generates an SSH key pair and writes it to a shared Docker volume
2. `ansible-server1` and `ansible-server2` wait for the public key, install it, then start SSH
3. `ansible-control` waits until both servers respond to SSH

**Verify everything is running:**

```powershell
docker compose ps
```

Expected: all 3 containers in `running` state.

**Watch the startup logs:**

```powershell
docker compose logs -f
```

Press `Ctrl+C` when you see "Control node is READY".

---

## Step 3 — Enter the Control Node

```powershell
docker exec -it ansible-control bash
```

You are now inside the `ansible-control` container.
Your prompt looks like:

```
root@ansible-control:/#
```

**Check Ansible is installed:**

```bash
ansible --version
```

**Check the inventory (the server list):**

```bash
cat /inventory/hosts.ini
```

**Check the SSH key was generated:**

```bash
ls -la /root/.ssh/
# You should see id_rsa (private key) and id_rsa.pub (public key)
```

---

## Step 4 — Test Connectivity (Ad-Hoc Commands)

An **ad-hoc command** runs a single module directly — no playbook file needed.
Great for quick checks.

```bash
# The most important test: can Ansible reach all servers?
ansible all -m ping
```

Expected output:

```
server1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
server2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**More ad-hoc examples:**

```bash
# Run a shell command on all servers
ansible all -m command -a "hostname"

# Run on only one server
ansible server1 -m command -a "uname -a"

# Get disk usage on all servers
ansible all -m command -a "df -h /"

# Check free memory
ansible all -m command -a "free -m"
```

> **Tip**: `ansible all` targets every host. `ansible servers` targets the
> `[servers]` group. `ansible server1` targets just server1.

---

## Step 5 — Run Your First Playbook

Playbooks live in `/playbooks/` inside the container.
They are **also mounted from your host machine** at `labs/ansible/playbooks/`,
so you can edit them in VS Code and the changes appear instantly inside the container.

```bash
ansible-playbook /playbooks/01-ping.yml
```

**What you will see:**

```
PLAY [Lab 01 — Verify connectivity to all managed nodes] ****

TASK [Ping the server via Ansible] ***************************
ok: [server1]
ok: [server2]

TASK [Run a simple shell command on the remote server] *******
ok: [server1]
ok: [server2]

TASK [Show the output] ***************************************
ok: [server1] => {
    "msg": "Hello from server1!"
}
ok: [server2] => {
    "msg": "Hello from server2!"
}

PLAY RECAP ***************************************************
server1 : ok=3  changed=0  unreachable=0  failed=0
server2 : ok=3  changed=0  unreachable=0  failed=0
```

**Reading the PLAY RECAP:**
| Column | Meaning |
|---|---|
| `ok` | Tasks that ran successfully and changed nothing |
| `changed` | Tasks that actually modified something on the server |
| `unreachable` | Servers Ansible could not connect to (SSH failed) |
| `failed` | Tasks that ran but returned an error |

---

## Step 6 — Create Files on Remote Servers

```bash
ansible-playbook /playbooks/02-files.yml
```

After it runs, verify the files are there:

```bash
ansible all -m command -a "ls -la /opt/ansible-lab/"
ansible all -m command -a "cat /opt/ansible-lab/hello.txt"
```

**What to notice:**

- You never had to `ssh` into the servers manually
- The same playbook ran on both servers simultaneously
- Variables like `{{ inventory_hostname }}` were substituted differently per host

---

## Step 7 — Explore System Facts

```bash
ansible-playbook /playbooks/03-facts.yml
```

Facts are variables Ansible collects automatically. To see **all** facts for a server:

```bash
ansible server1 -m setup
```

That will print a large JSON object with hundreds of facts. Pipe through `grep` to find what you need:

```bash
ansible server1 -m setup | grep ansible_distribution
ansible server1 -m setup | grep memory
ansible server1 -m setup | grep processor
```

**Use a fact in an ad-hoc command:**

```bash
# Not possible directly, but in a playbook you can use:
# "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
```

---

## Step 8 — Install Packages

```bash
ansible-playbook /playbooks/04-packages.yml
```

This playbook installs `htop`, `tree`, and `jq` on both servers,
then removes `ncdu` to show how `state: absent` works.

**Verify:**

```bash
ansible all -m command -a "which htop"
ansible all -m command -a "which tree"
```

**Run the same playbook again:**

```bash
ansible-playbook /playbooks/04-packages.yml
```

Notice the PLAY RECAP: `changed=0`. This is **idempotency** — Ansible
sees the packages are already installed and does nothing. Every properly
written playbook should be safe to run multiple times.

---

## Step 9 — Variables and Templates

```bash
ansible-playbook /playbooks/05-variables.yml
```

**Try overriding a variable from the command line:**

```bash
ansible-playbook /playbooks/05-variables.yml -e "app_name=CoolApp"
```

Watch how `CoolApp` appears everywhere in the output instead of `DemoApp`.
The `-e` flag (extra-vars) has the highest priority of all variable sources.

**Read the generated config:**

```bash
ansible all -m command -a "cat /opt/coolapp/config.ini"
```

---

## Step 10 — Write Your Own Playbook (Exercise)

Open the exercise file in VS Code on your Windows machine:

```
labs/ansible/playbooks/06-your-playbook.yml
```

Follow the TODO comments inside the file. Your goal:
create a simple HTML page on both servers.

Run it from inside the control node:

```bash
ansible-playbook /playbooks/06-your-playbook.yml
```

Verify:

```bash
ansible all -m command -a "cat /var/www/index.html"
```

---

## Useful Commands Cheat Sheet

```bash
# ── Ad-hoc commands ──────────────────────────────────────
ansible all -m ping                            # connectivity test
ansible all -m command -a "uptime"             # run a command
ansible all -m shell -a "echo $HOSTNAME"       # run with shell features
ansible all -m copy -a "content=hi dest=/tmp/hi.txt"  # copy a file
ansible all -m file -a "path=/tmp/hi.txt state=absent" # delete a file
ansible all -m apt -a "name=curl state=present"        # install package
ansible server1 -m setup                       # show all facts

# ── Running playbooks ────────────────────────────────────
ansible-playbook /playbooks/01-ping.yml        # run a playbook
ansible-playbook /playbooks/01-ping.yml -v     # verbose output
ansible-playbook /playbooks/01-ping.yml -vvv   # very verbose (debug)
ansible-playbook /playbooks/01-ping.yml --check  # dry run (what WOULD change)
ansible-playbook /playbooks/01-ping.yml --diff   # show file diffs
ansible-playbook /playbooks/01-ping.yml --limit server1  # only server1
ansible-playbook /playbooks/01-ping.yml -e "key=value"   # extra variable

# ── Inventory ────────────────────────────────────────────
ansible-inventory --list                       # show inventory as JSON
ansible-inventory --graph                      # show inventory as tree
ansible all --list-hosts                       # list all managed hosts

# ── Checking syntax ──────────────────────────────────────
ansible-playbook /playbooks/05-variables.yml --syntax-check
```

---

## Step 11 — Peek Inside a Server

Want to see what the servers look like from the inside?

```bash
# From your Windows PowerShell (NOT inside the control container):
docker exec -it ansible-server1 bash
```

You are now on `server1` as if you had SSH-ed into a real server.

```bash
hostname                             # server1
cat /root/.ssh/authorized_keys       # the key Ansible uses
ls /opt/ansible-lab/                 # files created by playbooks
exit
```

---

## Cleanup

```powershell
# Stop and remove containers
docker compose down

# Also remove the shared SSH key volume
docker compose down -v
```

---

## What's Next?

Once you are comfortable with these basics, explore:

| Topic                  | How                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------- |
| **Roles**              | Reusable bundles of tasks; `ansible-galaxy init myrole`                               |
| **Templates (Jinja2)** | Use `.j2` files with the `template` module instead of `copy`                          |
| **Handlers**           | Tasks that only run when notified; great for "restart service only if config changed" |
| **Vault**              | Encrypt secrets; `ansible-vault encrypt secrets.yml`                                  |
| **group_vars/**        | Variable files that auto-apply to host groups                                         |
| **Tags**               | Run only part of a playbook; `ansible-playbook pb.yml --tags install`                 |
| **Collections**        | Community modules; `ansible-galaxy collection install community.general`              |

---

## Troubleshooting

**"UNREACHABLE" in the output:**

```bash
# Check the server is running
docker compose ps

# Check SSH manually
ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@10.20.0.11

# Restart if needed
docker compose restart
```

**"Connection refused" on SSH:**

```bash
# The server sshd may still be starting; check its logs
docker logs ansible-server1
```

**Playbook changes nothing (all `ok`, no `changed`):**
That is usually correct — it means the desired state already exists.
Try removing a file manually on a server and re-running:

```bash
ansible server1 -m command -a "rm /opt/ansible-lab/hello.txt"
ansible-playbook /playbooks/02-files.yml   # now it shows changed=1
```

**Edit a playbook and nothing changes inside the container:**
The `./playbooks` folder is bind-mounted. Save the file in VS Code,
then re-run `ansible-playbook` — no rebuild needed.
