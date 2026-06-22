FROM python:3.14-alpine

RUN pip install requests flask dotenv

WORKDIR /app

COPY . .

CMD ["python", "frontend.py"]

