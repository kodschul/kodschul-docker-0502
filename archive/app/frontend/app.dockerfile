FROM python:3.9-alpine


RUN pip install flask requests


WORKDIR /app

# ARG APP_VERSION
# RUN echo "Version: $APP_VERSION" > version.info 

COPY . .

CMD [ "python", "frontend.py" ]

EXPOSE 80
# CMD ["cat", "version.info"]