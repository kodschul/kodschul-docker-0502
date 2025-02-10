FROM python:3.9-alpine

RUN pip install flask requests

WORKDIR /app

COPY . .

CMD [ "python", "frontend.py" ]

EXPOSE 80
