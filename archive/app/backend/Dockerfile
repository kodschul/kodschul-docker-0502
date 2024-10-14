FROM python:3.9-alpine

RUN pip install flask

WORKDIR /app


COPY . .

CMD [ "python", "backend.py" ]

EXPOSE 80 