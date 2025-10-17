FROM python:3.9-alpine

ARG APP_BUILD_SECRET 

RUN pip install flask requests python-dotenv

ENV APP_SECRET=$APP_BUILD_SECRET

WORKDIR /app

ARG APP_VERSION=1.0
RUN echo "App Version: $APP_VERSION, Static: v3" > version.info

COPY . .

CMD [ "python", "frontend.py" ]
