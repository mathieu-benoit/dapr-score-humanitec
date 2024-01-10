![](hello-world-k8s.png)

Resources:
- https://github.com/dapr/quickstarts/blob/master/tutorials/hello-kubernetes
- https://github.com/dapr/samples/tree/master/hello-docker-compose

Locally with Docker:
```bash
make score-compose
make compose-up
```

In Kubernetes:
```bash
make score-helm
make k8s-up
```