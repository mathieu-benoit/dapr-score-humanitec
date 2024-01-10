![](hello-world-k8s.png)

## Deploy locally with Docker

```bash
make score-compose
make compose-up
```

## Deploy to Kubernetes

```bash
make score-helm
make k8s-up
```

## Resources

- https://github.com/dapr/quickstarts/blob/master/tutorials/hello-kubernetes
- https://github.com/dapr/samples/tree/master/hello-docker-compose