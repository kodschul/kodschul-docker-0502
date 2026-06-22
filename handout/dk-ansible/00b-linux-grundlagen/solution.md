# Lösung: Linux Grundlagen

---

## Aufgabe 1

```bash
# 1. aktuelles Verzeichnis
pwd

# 2. Dateien in /etc mit "host" im Namen
ls /etc | grep host
# oder: find /etc -maxdepth 1 -name "*host*"

# 3. Speicherplatz
df -h
```

---

## Aufgabe 2

```bash
mkdir -p ~/kurs/docker ~/kurs/ansible

echo "Docker ist cool" > ~/kurs/docker/notes.txt
cp ~/kurs/docker/notes.txt ~/kurs/ansible/notes.txt
sed -i 's/Docker/Ansible/g' ~/kurs/ansible/notes.txt

cat ~/kurs/docker/notes.txt     # Docker ist cool
cat ~/kurs/ansible/notes.txt    # Ansible ist cool
```

---

## Aufgabe 3

```bash
python3 -m http.server 9090 &
# merke PID z.B. [1] 12345

ps aux | grep python
ss -tlnp | grep 9090
curl http://localhost:9090

kill 12345
# oder: kill %1  (Job-Nummer aus dem &-Start)
```

---

## Aufgabe 4

```bash
cat > .env << 'EOF'
APP_PORT=8080
APP_ENV=development
APP_NAME=MeinProjekt
EOF

export $(cat .env | xargs)

echo $APP_PORT    # 8080
echo $APP_ENV     # development
echo $APP_NAME    # MeinProjekt
```

> **Antwort zur letzten Frage:** Nein. `export` setzt Variablen nur in der aktuellen Shell-Session. Jede neue Terminal-Instanz startet ohne diese Werte. Dauerhaft wären sie in `~/.bashrc` oder `~/.profile` zu hinterlegen – oder per Docker Compose `env_file`.
