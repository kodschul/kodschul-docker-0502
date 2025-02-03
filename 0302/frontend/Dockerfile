FROM python:3.12-alpine 

RUN pip install flask requests

WORKDIR /app

COPY . .

CMD [ "python", "frontend.py" ]

EXPOSE 80

# https://github.com/kodschul/kodschul-docker-0502