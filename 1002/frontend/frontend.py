from flask import Flask
import socket
import os
import requests
from datetime import datetime


hostname = os.uname()[1]
ips = socket.gethostbyname_ex(hostname)[2]

# port = os.getenv("FRONTEND_PORT")
# port = 5000
# backend_url = "http://backend:80"
# backend_url = os.getenv("BACKEND_URL")


app = Flask(__name__)


@app.route('/')
def index():

    # os.makedirs("/data", exist_ok=True)
    # with open("/data/access.log", "a+") as f:
    #     f.write(f"{datetime.now()}: IP: {ips} \n")

    # backend_response = requests.get(backend_url).text

    backend_response = requests.get("http://backend:80").text
    # backend_response = "Backend is coming later!"
    # backend_response = "Not yet!"
    return f'<html style="background:green;">Hello World V2, IP: {ips}, Backend Response: {backend_response} </html>'


app.run(host='0.0.0.0', port=80, debug=True)
