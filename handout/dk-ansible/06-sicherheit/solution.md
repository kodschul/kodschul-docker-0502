# Lösung: Docker Sicherheit

---

## Aufgabe 1

```bash
docker run --rm alpine whoami
# root  ← Container läuft standardmäßig als root!

docker run --rm nginx whoami
# root

docker run --rm -u 1000:1000 alpine whoami
# whoami: unknown uid 1000   ← kein Eintrag in /etc/passwd, aber OK
docker run --rm -u 1000:1000 alpine id
# uid=1000 gid=1000

docker run --rm --read-only alpine sh -c "echo test > /test.txt"
# sh: can't create /test.txt: Read-only file system  ← erwartet ✅

docker run --rm \
  --read-only \
  --tmpfs /tmp \
  alpine sh -c "echo 'ich darf /tmp schreiben' > /tmp/test.txt && cat /tmp/test.txt"
# ich darf /tmp schreiben  ← tmpfs ist beschreibbar ✅
```

---

## Aufgabe 2

```bash
docker run -d \
  --name limited-nginx \
  --memory 64m \
  --cpus 0.2 \
  nginx:alpine

docker stats --no-stream limited-nginx
# limited-nginx   2.3MiB / 64MiB   3.6%    0.1%CPU

docker inspect limited-nginx | grep -E '"Memory"|"NanoCpus"'
# "Memory": 67108864,     ← 64 * 1024 * 1024 = 64 MiB
# "NanoCpus": 200000000,  ← 0.2 * 1e9

docker run --rm --memory 32m \
  alpine sh -c "cat /dev/zero | head -c 64m > /dev/null"
echo "Exit: $?"
# Exit: 137   ← OOM Kill (SIGKILL = 128 + 9)
```

**Exit Code 137** = Container wurde durch OOM-Killer beendet (Speicherlimit überschritten).

---

## Aufgabe 3

```bash
trivy image python:3.10 --severity HIGH,CRITICAL | tail -20
# Viele CVEs – älteres Basis-Image mit Debian-Paketen aus 2022-2023

trivy image python:3.12-alpine --severity HIGH,CRITICAL | tail -20
# Deutlich weniger CVEs
```

**Antworten:**

- `python:3.10` auf Debian-Basis: typischerweise 50-200+ HIGH/CRITICAL CVEs (veraltete System-Bibliotheken)
- `python:3.12-alpine`: deutlich weniger (< 10), da Alpine weniger Pakete enthält
- **Hauptgründe:** Alpine hat weniger installierte Systempakete, daher kleinere Angriffsfläche. Neuere Python-Version enthält Sicherheits-Patches.
