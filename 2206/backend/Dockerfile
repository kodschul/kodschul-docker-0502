FROM python:3.14-alpine


RUN pip install requests flask dotenv

RUN apk add curl

WORKDIR /app

COPY . .

CMD ["python", "backend.py"]

