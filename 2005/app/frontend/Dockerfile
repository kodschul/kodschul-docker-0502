FROM python:3.9-alpine 

WORKDIR /app 

RUN pip install flask requests python-dotenv

COPY . .

CMD [ "python", "frontend.py" ]