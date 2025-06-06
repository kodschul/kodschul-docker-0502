from flask import Flask
import socket
import os
from datetime import datetime

hostname = os.uname()[1]
ips = socket.gethostbyname_ex(hostname)[2]


app = Flask(__name__)


@app.route('/')
def index():
    os.makedirs("/data", exist_ok=True)
    with open("/data/access.log", "a+") as f:
        f.write(f"{datetime.now()}: IP: {ips} \n")

    return {"ip": str(ips), "username": "root", "now": datetime.now()}


app.run(host='0.0.0.0', port=80, debug=True)
