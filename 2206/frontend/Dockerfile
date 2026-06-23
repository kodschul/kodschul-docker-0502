FROM python:3.14-alpine

RUN pip install requests flask dotenv 

RUN echo "updated 5" > info.txt

WORKDIR /app

COPY . .

CMD ["python", "frontend.py"]

