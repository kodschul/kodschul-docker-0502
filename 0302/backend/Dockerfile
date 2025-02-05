FROM python:3.12-alpine 

RUN pip install flask requests

WORKDIR /app

COPY . .

CMD [ "python", "backend.py" ]

EXPOSE 80
