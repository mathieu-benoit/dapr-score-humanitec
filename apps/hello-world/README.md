![](hello-world-k8s.png)

## Deploy locally with Docker

```bash
make score-compose
make compose-up
```

## Deploy to Kubernetes

```bash
export NAMESPACE=default

make score-helm
make k8s-up
```

## Deploy to Humanitec

```bash
export HUMANITEC_ORG=FIXME
export HUMANITEC_TOKEN=FIXME
export HUMANITEC_APP=FIXME
export HUMANITEC_ENVIRONMENT=development

make score-humanitec
```

## Resources

- https://github.com/dapr/quickstarts/blob/master/tutorials/hello-kubernetes
- https://github.com/dapr/samples/tree/master/hello-docker-compose