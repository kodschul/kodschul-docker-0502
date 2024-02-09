FROM python:3.10-alpine

RUN pip install flask requests

WORKDIR /backend

COPY backend.py . 

CMD [ "python", "backend.py" ]

EXPOSE 80
