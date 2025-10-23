FROM python:3.9-alpine


ARG APP_CONFIG_CODE="change-it"
ARG APP_VERSION=1.0

ENV SECRET_PASS=$APP_CONFIG_CODE


# install deps 
RUN pip install flask requests python-dotenv 

RUN echo "App Version: $APP_VERSION" > version.info

WORKDIR /app

# add code 
COPY frontend.py frontend.py

EXPOSE 80

CMD [ "python", "frontend.py" ]
