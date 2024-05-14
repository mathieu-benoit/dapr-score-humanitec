![](hello-world-k8s.png)

## Deploy locally with Docker

```bash
make compose-test
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
export HUMANITEC_APP=FIXME
export HUMANITEC_ENVIRONMENT=development

humctl login

make score-humanitec
```

## Resources

- https://github.com/dapr/quickstarts/blob/master/tutorials/hello-kubernetes
- https://github.com/dapr/samples/tree/master/hello-docker-compose