# 05 – Docker Networking

**Block:** 90 min | **Tag 2**

---

## Netzwerk-Grundlagen in Docker

Jeder Container bekommt standardmäßig ein eigenes Netzwerk-Interface. Docker verwaltet diese Interfaces über **virtuelle Bridges** und nutzt Linux-Namespaces für die Isolation.

```
Host
├── eth0: 192.168.1.100
└── docker0 (Bridge): 172.17.0.1
      ├── Container A: 172.17.0.2
      ├── Container B: 172.17.0.3
      └── Container C: 172.17.0.4
```

---

## Lab 5.1 – Netzwerkverwaltung in Containern

### Built-in Netzwerk-Treiber

| Treiber   | Beschreibung                                     | Wann nutzen                    |
| --------- | ------------------------------------------------ | ------------------------------ |
| `bridge`  | Standard: private interne Bridge, NAT nach außen | lokale Container-Kommunikation |
| `host`    | Container nutzt direkt das Host-Netzwerk         | Performance, kein NAT          |
| `none`    | Kein Netzwerk                                    | vollständig isoliert           |
| `overlay` | Multi-Host-Netzwerk (Docker Swarm / K8s)         | verteilte Cluster              |
| `macvlan` | Container bekommt eigene MAC/IP im LAN           | Legacy-Apps, Layer 2           |

```bash
# Netzwerke anzeigen
docker network ls

# Details zu bridge
docker network inspect bridge
```

### Port-Binding verstehen

```bash
# Container-Port 80 auf Host-Port 8080
docker run -d -p 8080:80 nginx

# Auf allen Interfaces (0.0.0.0) – Standard
docker run -d -p 8080:80 nginx

# Nur auf localhost
docker run -d -p 127.0.0.1:8080:80 nginx

# Zufälliger Host-Port
docker run -d -p 80 nginx
docker port <container>   # gemappten Port anzeigen

# Alle Ports aus EXPOSE öffnen (zufällige Host-Ports)
docker run -d -P nginx
```

---

## Lab 5.2 – Docker-Netzwerke erstellen und verwalten

### Custom Bridge Network

```bash
# Netzwerk erstellen
docker network create --driver bridge mynetwork

# Mit eigenem Subnet
docker network create \
  --driver bridge \
  --subnet 192.168.100.0/24 \
  --gateway 192.168.100.1 \
  mynetwork

# Container in custom network starten
docker run -d --name backend --network mynetwork myapp
docker run -d --name db --network mynetwork postgres:16-alpine

# Container zu bestehendem Netzwerk hinzufügen
docker network connect mynetwork anderer-container

# Netzwerk trennen
docker network disconnect mynetwork container-name

# Netzwerk entfernen
docker network rm mynetwork
```

### DNS in Custom Networks

```bash
# Im default bridge: Container sind nur über IP erreichbar
# Im custom bridge: DNS-Auflösung über Container-Namen!

docker network create testnet
docker run -d --name server --network testnet nginx:alpine
docker run -it --rm --network testnet alpine sh

# Im alpine-Container:
ping server          # ✅ funktioniert in custom network
nslookup server      # → 172.x.x.x (Container-IP)
wget -O - http://server   # ✅ HTTP-Request an "server"
```

> **Wichtig:** Im Standard `bridge`-Netzwerk gibt es **kein DNS** zwischen Containern. In custom bridge Networks schon. Docker Compose erstellt automatisch ein custom Network → daher funktioniert Service Discovery in Compose ohne Extra-Konfiguration.

---

## Lab 5.3 – Kommunikation zwischen Containern

### Netzwerk-Topologie mit Compose

```yaml
services:
  frontend:
    networks:
      - public # erreichbar von außen
      - internal # kann backend ansprechen

  backend:
    networks:
      - internal # nur intern erreichbar

  db:
    networks:
      - internal # nur intern erreichbar

networks:
  public:
    driver: bridge
  internal:
    driver: bridge
    internal: true # kein Zugang zum Internet!
```

```
Internet → frontend (public) → backend (internal) → db (internal)
                                                       ↑
                             kein direkter Zugang von außen
```

### Firewall & iptables

Docker manipuliert automatisch `iptables`-Regeln beim Port-Binding:

```bash
# Aktuelle iptables-Regeln von Docker anzeigen
sudo iptables -L DOCKER -n --line-numbers
sudo iptables -t nat -L DOCKER -n

# Was Docker beim -p Flag macht:
# DNAT: eingehende :8080 → Container-IP:80
# ACCEPT in DOCKER-Chain

# Problem: Docker-Regeln haben Vorrang vor ufw/firewalld!
# Lösung: Bind auf 127.0.0.1 oder interne Docker-Netze
docker run -d -p 127.0.0.1:8080:80 nginx   # sicherer
```

### Container-Netzwerk debuggen

```bash
# IP-Adresse eines Containers
docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mycontainer

# Netzwerkverbindungen im Container
docker exec mycontainer ss -tlnp
docker exec mycontainer netstat -tlnp

# DNS-Konfiguration im Container
docker exec mycontainer cat /etc/resolv.conf

# Direkte TCP-Verbindung testen
docker run --rm --network mynetwork alpine \
  sh -c "nc -zv backend 8080 && echo OK"
```

---

## Zusammenfassung

```
Netzwerk-Treiber
├── bridge   → Standard, NAT, custom für DNS
├── host     → kein NAT, direkter Kernel-Zugang
└── none     → komplett isoliert

DNS
├── default bridge  → kein automatisches DNS
└── custom bridge   → DNS über Container-Namen ✅

Port-Binding
├── -p 8080:80             → alle Interfaces
└── -p 127.0.0.1:8080:80  → nur lokal (sicherer)

Compose
└── erstellt automatisch custom network → DNS gratis
```
