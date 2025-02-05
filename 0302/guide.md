# docker service create --name registry -p 5000:5000 registry

# docker tag frontend:v1 localhost:5000/frontend:v1

# docker push localhost:5000/frontend:v1

# docker tag backend:v1 localhost:5000/backend:v1

# docker push localhost:5000/backend:v1

# docker service create --name frontend --replicas 1 -p 8000:80 127.0.0.1:5000/frontend:v1

# docker service create --name backend --replicas 1 -p 8000:80 127.0.0.1:5000/backend:v1
