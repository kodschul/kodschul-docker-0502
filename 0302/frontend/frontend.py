from flask import Flask
import socket
import os
import requests
from datetime import datetime


ips = os.uname()
# hostname = os.uname()
# ips = hostname
# ips = socket.gethostbyname_ex(hostname)[2]

# port = os.getenv("BACKEND_PORT")
# port = 5000
backend_url = "http://backend:80"
# backend_url = os.getenv("BACKEND_URL")


app = Flask(__name__)


@app.route('/')
def index():

    os.makedirs("/data", exist_ok=True)
    with open("/data/access.log", "a+") as f:
        f.write(f"{datetime.now()}: IP: {ips} \n")

    backend_response = requests.get(backend_url).text

    # backend_response = requests.get("http://host.docker.internal:55007").text
    # backend_response = "Backend is coming lsater!"
    # backend_response = ips
    return f'<html style="background:yellow;">Hello World V1, IP: {ips}, Backend Response: {backend_response} </html>'


app.run(host='0.0.0.0', port=80, debug=True)
