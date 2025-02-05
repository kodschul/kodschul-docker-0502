FROM python:3.9-alpine

ARG APP_VERSION=1.0

RUN pip install flask requests

WORKDIR /app

RUN echo "Current Version: $APP_VERSION" > version.info

COPY . .

ENV BACKEND_URL=http://backend
ENV test=abc 
ENV build_app_version=${APP_VERSION}

CMD [ "python", "frontend.py" ]

EXPOSE 80

# https://github.com/kodschul/kodschul-docker-0502