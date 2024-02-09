FROM python:3.10-alpine


ARG frontend_port=8000
ENV FRONTEND_PORT=$frontend_port

RUN pip install flask requests

WORKDIR /frontend

COPY . . 

CMD ["python", "frontend.py"]

EXPOSE 80
