```
docker run --name frontend2 -d -p 8080:80 --mount type=bind,source=.,target=/frontend frontend:v2
```
