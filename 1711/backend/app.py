"""Hello-Backend: antwortet mit JSON (Pod, IP, Uhrzeit, Version).

Umgebungsvariablen (Standardwert in Klammern):
  APP_VERSION  angezeigte Version                    (v1)
  PORT         Port, auf dem der Webserver lauscht   (80)
"""

import os
import socket
from datetime import datetime
import json

from flask import Flask, jsonify

APP_VERSION = os.getenv("APP_VERSION", "v1")
PORT = int(os.getenv("PORT", "80"))

POD_NAME = socket.gethostname()
POD_IP = socket.gethostbyname(POD_NAME)

app = Flask(__name__)


@app.route("/")
# gleiche Antwort unter /api (Gateway-Route, Lab 5.3)
@app.route("/api")
def index():

    info = {
        "pod": POD_NAME,
        "ip": POD_IP,
        "time": datetime.now().strftime("%H:%M:%S"),
        "version": APP_VERSION


    }

    os.makedirs("/data", exist_ok=True)

    with open("/data/access.log", "a", ) as f:
        f.write(json.dumps(info) + "\n")

    return jsonify(
        pod=POD_NAME,
        ip=POD_IP,
        time=datetime.now().strftime("%H:%M:%S"),
        version=APP_VERSION,
    )


@app.route("/healthz")
def healthz():
    return "ok", 200


if __name__ == "__main__":
    print(f"Hello-Backend {APP_VERSION} auf Port {PORT}", flush=True)
    app.run(host="0.0.0.0", port=PORT)
