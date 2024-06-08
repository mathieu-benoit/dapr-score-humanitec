![](hello-world-k8s.png)

## Deploy locally with Docker

```bash
make compose-test

docker logs hello-world-nodeapp-nodeapp-1
```

## Deploy to Kubernetes

```bash
make k8s-test
```

## Deploy to Humanitec

```bash
export HUMANITEC_ORG=FIXME
export HUMANITEC_APP=FIXME
export HUMANITEC_ENVIRONMENT=development

humctl login

make humanitec-deploy
```

## Resources

- https://github.com/dapr/quickstarts/blob/master/tutorials/hello-kubernetes
- https://github.com/dapr/samples/tree/master/hello-docker-compose