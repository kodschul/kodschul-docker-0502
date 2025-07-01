FROM python:3.9-alpine

RUN pip install flask requests python-dotenv


WORKDIR /app


COPY frontend.py .

CMD ["python", "frontend.py"]



EXPOSE 80