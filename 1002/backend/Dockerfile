FROM python:3.9-alpine

RUN pip install flask requests

WORKDIR /app

COPY . .

CMD [ "python", "backend.py" ]

EXPOSE 80
