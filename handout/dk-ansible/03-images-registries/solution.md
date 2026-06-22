# Lösung: Images und lokale Registries

---

## Aufgabe 1 – Dockerfile

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
```

```bash
docker build -t myapp:1.0 ./myapp
docker run -d -p 8080:8000 --name myapp myapp:1.0
# → http://localhost:8080 → Hello from myapp v1.0
```

---

## Aufgabe 2 – Layer-Cache

```bash
time docker build -t myapp:1.0 ./myapp
# real  0m25s   (erstes Mal: pip install dauert)

time docker build -t myapp:1.0 ./myapp
# real  0m0.5s  (alle Layer aus Cache: "Using cache")

echo "# Kommentar" >> myapp/app.py
time docker build -t myapp:1.0 ./myapp
# Step 1-4: Using cache  ← FROM, WORKDIR, adduser, pip install
# Step 5: COPY . .       ← CACHE MISS wegen app.py-Änderung
# Step 6: USER           ← neu ausgeführt
```

**Erkenntnis:** `COPY requirements.txt` + `RUN pip install` kommen vor `COPY . .` → pip install wird nur neu ausgeführt wenn `requirements.txt` sich ändert, nicht bei jeder Code-Änderung.

---

## Aufgabe 3 – Lokale Registry

```bash
docker run -d -p 5000:5000 --name registry registry:2

docker tag myapp:1.0 localhost:5000/myapp:1.0
docker push localhost:5000/myapp:1.0
# Pushing 5 layers...

curl http://localhost:5000/v2/_catalog
# {"repositories":["myapp"]}

curl http://localhost:5000/v2/myapp/tags/list
# {"name":"myapp","tags":["1.0"]}

docker rmi myapp:1.0 localhost:5000/myapp:1.0
docker pull localhost:5000/myapp:1.0
docker run -d -p 8081:8000 localhost:5000/myapp:1.0
# → http://localhost:8081 → Hello from myapp v1.0
```
