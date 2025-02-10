FROM python:3.9-alpine as build

COPY build.py . 

RUN python build.py

FROM busybox as export

COPY --from=build output.txt .

CMD ["cat", "output.txt"]

