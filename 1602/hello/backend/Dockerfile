FROM python:3.13-alpine


RUN apk add curl
RUN pip install requests python-dotenv flask

WORKDIR /app

COPY . .

CMD [ "python", "backend.py" ]

EXPOSE 80