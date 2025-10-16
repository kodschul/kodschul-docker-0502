FROM python:3.9-alpine as build  
COPY . .
RUN python build.py

FROM busybox as final

WORKDIR /app

COPY --from=build /output.txt .
# COPY --from=build /abc . 


CMD ["cat", "output.txt"]