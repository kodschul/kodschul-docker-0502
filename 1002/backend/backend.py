from flask import Flask
import socket
import os
from datetime import datetime

ips = os.uname()
# hostname = os.uname()
# ips = hostname
# ips = socket.gethostbyname_ex(hostname)[2]


app = Flask(__name__)


@app.route('/')
def index():
    return {"ip": str(ips), "username": "root", "now": datetime.now()}


app.run(host='0.0.0.0', port=80, debug=True)
