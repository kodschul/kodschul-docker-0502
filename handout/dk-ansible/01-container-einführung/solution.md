# Lösung: Einführung in Containertechnologie

---

## Aufgabe 1

```bash
docker run hello-world
# → pulled Image, startet Prozess, gibt Begrüßungstext aus, beendet sich

docker run -it ubuntu bash
# Im Container:
cat /etc/os-release   # Ubuntu 24.04 o.ä.
hostname              # zufällige Container-ID
ps aux               # nur bash + ps laufen
exit

docker run -d -p 8080:80 --name webserver nginx
# → Container-ID wird ausgegeben
# Browser: http://localhost:8080 → nginx Welcome Page
```

**Antworten:**

- `hello-world` startet, gibt Text aus und beendet sich. `-it ubuntu bash` öffnet eine interaktive Shell, die offen bleibt.
- Im Container läuft nur der Prozess, der gestartet wurde (bash) – kein Init-System, kein systemd, keine anderen Dienste. Linux-Namespaces isolieren den Prozessraum.

---

## Aufgabe 2

```bash
docker info
# Storage Driver: overlay2
# Containers: X (Running: X, Paused: 0, Stopped: X)

docker images
# nginx    latest    xxxx    ~187 MB (oder alpine: ~22 MB)
```

**Hinweis:** Der Storage Driver `overlay2` ist Standard auf modernen Linux-Kerneln und implementiert das Union Filesystem.

---

## Aufgabe 3

```bash
docker run -d --name nginx1 nginx:alpine
docker run -d --name nginx2 nginx:alpine
docker stats --no-stream

# Typischer Output:
# nginx1  ~2 MiB RAM  < 0.1% CPU
# nginx2  ~2 MiB RAM  < 0.1% CPU

docker image history nginx:alpine
# Zeigt 5-8 Layers
```

**Vergleich:**

- Zwei nginx-Container: ~4 MB RAM gesamt
- Zwei nginx-VMs: ~512 MB – 1 GB RAM allein für das Gast-OS
- Container teilen den Kernel → kein duplizierter Overhead
