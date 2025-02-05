FROM python:3.9-alpine as build

WORKDIR /app 

COPY . .

RUN python build.py

CMD ["cat", "output.txt"]


FROM busybox

COPY --from=build /app/output.txt /app/output.txt

CMD ["cat", "/app/output.txt"]