# Lösung: Kubernetes Deployments, Services und ConfigMaps

---

## Aufgabe 1

```yaml
# deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "32Mi"
              cpu: "50m"
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 5
```

```yaml
# service.yml
apiVersion: v1
kind: Service
metadata:
  name: webapp-svc
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

```bash
kubectl apply -f deployment.yml -f service.yml

kubectl get pods -l app=webapp
# NAME                      READY   STATUS    RESTARTS
# webapp-6c9f8d7b5-abc12    1/1     Running   0
# webapp-6c9f8d7b5-def34    1/1     Running   0

kubectl get svc webapp-svc
# NAME         TYPE       CLUSTER-IP      PORT(S)        AGE
# webapp-svc   NodePort   10.96.xxx.xxx   80:30080/TCP   5s

curl http://localhost:30080
# <!DOCTYPE html>... nginx welcome page ✅
```

---

## Aufgabe 2

```yaml
# configmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config
data:
  APP_COLOR: "blue"
  APP_MESSAGE: "Hello from ConfigMap!"
```

```yaml
# deployment.yml – envFrom ergänzen
spec:
  template:
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          envFrom:
            - configMapRef:
                name: webapp-config
```

```bash
kubectl apply -f configmap.yml
kubectl apply -f deployment.yml

kubectl exec deploy/webapp -- printenv | grep APP_
# APP_COLOR=blue
# APP_MESSAGE=Hello from ConfigMap!
```

---

## Aufgabe 3

```bash
kubectl set image deployment/webapp nginx=nginx:1.25-alpine
# deployment.apps/webapp image updated

kubectl rollout status deployment/webapp
# Waiting for deployment "webapp" rollout to finish: 1 out of 2 new replicas have been updated...
# Waiting for deployment "webapp" rollout to finish: 1 old replicas are pending termination...
# deployment "webapp" successfully rolled out

kubectl rollout undo deployment/webapp
# deployment.apps/webapp rolled back

kubectl describe deployment webapp | grep Image
#     Image:  nginx:alpine   ← zurück zur alten Version
```
