### 1. create registry

```

docker run -d --name registry -p 5000:5000 registry

```

### 2. push image to registry

```
$ docker tag frontend:v1 localhost:9000/frontend:v1

$ docker push localhost:9000/frontend:v1

```

```
docker image rm frontend:v1
```

```
docker image rm localhost:9000/frontend:v1
```

### 2. start container with registry image

```
docker run -d -p 8000:80 --name frontend localhost:9000/frontend:v1
```
