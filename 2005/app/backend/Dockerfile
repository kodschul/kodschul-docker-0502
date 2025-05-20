FROM python:3.9-alpine 

WORKDIR /app 

RUN pip install flask requests

COPY . .

CMD [ "python", "backend.py" ]