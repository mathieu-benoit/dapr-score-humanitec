![](hello-world-k8s.png)

## Deploy locally with Docker

```bash
make compose-up

curl $(score-compose resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}:8080')
```

## Deploy to Kubernetes

```bash
kind create cluster
kubectl apply \
    -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
helm install ngf oci://ghcr.io/nginxinc/charts/nginx-gateway-fabric \
    --create-namespace \
    -n nginx-gateway \
    --set service.type=ClusterIP
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: default
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
EOF

helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
helm upgrade \
    dapr \
    dapr/dapr \
    --install \
    --create-namespace \
    -n dapr-system

make k8s-up

cd node
curl $(score-k8s resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}:8080')
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