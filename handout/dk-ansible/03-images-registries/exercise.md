# Übung: Images und lokale Registries

**Zeit:** 30 min

---

## Aufgabe 1 – Eigenes Image bauen (15 min)

Erstelle folgende Dateistruktur:

```
myapp/
├── Dockerfile
├── requirements.txt
└── app.py
```

**app.py:**

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def index():
    version = os.environ.get("APP_VERSION", "1.0")
    return f"<h1>Hello from myapp v{version}</h1>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
```

**requirements.txt:**

```
flask==3.0.3
```

**Aufgaben:**

1. Schreibe ein `Dockerfile` (Python 3.12-alpine, non-root user, port 8000)
2. Baue das Image: `docker build -t myapp:1.0 ./myapp`
3. Starte einen Container: Port 8000 → 8080 auf dem Host
4. Öffne http://localhost:8080 im Browser

---

## Aufgabe 2 – Layer-Cache verstehen (5 min)

```bash
# Erster Build (cold cache)
time docker build -t myapp:1.0 ./myapp

# Zweiter Build (cached) – ändere nichts
time docker build -t myapp:1.0 ./myapp

# Jetzt nur app.py ändern und neu bauen
# → Welche Layer werden neu gebaut, welche aus Cache?
echo "# Kommentar" >> myapp/app.py
time docker build -t myapp:1.0 ./myapp
```

---

## Aufgabe 3 – Lokale Registry (10 min)

```bash
# 1. Starte eine lokale Registry
docker run -d -p 5000:5000 --name registry registry:2

# 2. Tagge dein myapp-Image für die lokale Registry
docker tag myapp:1.0 localhost:5000/myapp:1.0

# 3. Pushe das Image
docker push localhost:5000/myapp:1.0

# 4. Überprüfe den Inhalt der Registry
curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2/myapp/tags/list

# 5. Lösche das lokale Image und lade es aus der Registry
docker rmi myapp:1.0 localhost:5000/myapp:1.0
docker pull localhost:5000/myapp:1.0
docker run -d -p 8081:8000 localhost:5000/myapp:1.0
```
