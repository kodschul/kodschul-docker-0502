FROM python:3.10-alpine

# Install flask library
RUN pip install flask

WORKDIR /backend
COPY backend.py .


CMD ["python", "backend.py" ]

EXPOSE 80