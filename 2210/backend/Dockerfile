FROM python:3.9-alpine

# install deps 
RUN pip install flask requests python-dotenv 

WORKDIR /app

# add code 
COPY backend.py backend.py

EXPOSE 80

CMD [ "python", "backend.py" ]
