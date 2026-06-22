# Übung: Einführung in Containertechnologie

**Zeit:** 30 min

---

## Aufgabe 1 – Erste Container (10 min)

```bash
# 1. Starte den hello-world Container und lies die Ausgabe
docker run hello-world

# 2. Starte einen Ubuntu-Container interaktiv
docker run -it ubuntu bash
# Im Container:
cat /etc/os-release
hostname
ps aux
exit

# 3. Starte nginx im Hintergrund und öffne im Browser
docker run -d -p 8080:80 --name webserver nginx
# → http://localhost:8080
```

**Fragen:**

- Was ist der Unterschied zwischen `docker run hello-world` und `docker run -it ubuntu bash`?
- Warum siehst du im Ubuntu-Container nur wenige Prozesse?

---

## Aufgabe 2 – Ökosystem erkunden (10 min)

```bash
# Docker-Systeminfo anzeigen
docker info
docker version

# Welche Images sind lokal vorhanden?
docker images

# Welche Container laufen gerade?
docker ps

# Alle Container (auch gestoppte)
docker ps -a
```

Beantworte:

1. Welchen Storage Driver nutzt deine Docker-Installation?
2. Wie viele Container sind gerade gestoppt (nicht gelöscht)?
3. Wie groß ist das nginx-Image in MB?

---

## Aufgabe 3 – VM vs. Container (10 min)

Starte zwei nginx-Container gleichzeitig und beobachte den Ressourcenverbrauch:

```bash
docker run -d --name nginx1 nginx:alpine
docker run -d --name nginx2 nginx:alpine

# Ressourcenverbrauch live
docker stats --no-stream

# Architektur ansehen
docker image history nginx:alpine
```

**Vergleich:**

- Wie viel RAM verbraucht ein nginx-Container?
- Wie viele Schichten (Layers) hat das nginx:alpine Image?
- Was wäre der Ressourcenverbrauch von 2 nginx-VMs im Vergleich?
