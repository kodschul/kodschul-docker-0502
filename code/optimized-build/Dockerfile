FROM python:3.9-alpine as build 
WORKDIR /app
COPY . .
RUN python build.py


FROM busybox
WORKDIR /app
COPY --from=build /app/output.txt .