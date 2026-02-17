FROM python:3.13-alpine


RUN apk add curl
RUN pip install requests python-dotenv flask


WORKDIR /app

ARG APP_VERSION=0.0.0
ENV APP_DISPLAY_VERSION=$APP_VERSION


RUN echo "Last version updated: $APP_VERSION" > version.info


COPY . .

CMD [ "python", "frontend.py" ]

EXPOSE 80