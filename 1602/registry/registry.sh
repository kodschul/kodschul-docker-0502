docker rm -f registry && docker run -d -p 5001:5000 --name registry registry:3
s
docker tag frontend:v1 127.0.0.1:5001/frontend:v1

docker push 127.0.0.1:5001/frontend:v1

http://localhost:5001/v2/_catalog
http://localhost:5001/v2/REPLACE_WITH_IMAGE_NAME/tags/list


docker pull 127.0.0.1:5001/frontend:v1

docker rm -f frontend && docker run -d -p 8000:80 --name frontend \
    -v .:/app 127.0.0.1:5001/frontend:v1 

