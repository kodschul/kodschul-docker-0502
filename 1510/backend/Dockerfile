FROM python:3.9-alpine

RUN pip install flask requests python-dotenv

WORKDIR /app

COPY . .

CMD [ "python", "backend.py" ]
