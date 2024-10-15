FROM python:3.9-alpine


RUN pip install flask requests

WORKDIR /app

ARG APP_DB_PASSWORD=default_secret
ENV DB_PASSWORD=$APP_DB_PASSWORD

COPY . .

CMD python frontend.py

# EXPOSE 80