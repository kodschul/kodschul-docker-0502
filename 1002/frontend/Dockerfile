FROM python:3.9-alpine

RUN pip install flask requests

WORKDIR /app

COPY . .

ARG APP_VERSION=1.0
ARG BUILD_APP_PASSWORD=default

RUN echo "Version v$APP_VERSION" > version.info
ENV APP_PASSWORD=$BUILD_APP_PASSWORD

CMD [ "python", "frontend.py" ]

EXPOSE 80
