# Disable all the default make stuff
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

## Display a list of the documented make targets
.PHONY: help
help:
	@echo Documented Make targets:
	@perl -e 'undef $$/; while (<>) { while ($$_ =~ /## (.*?)(?:\n# .*)*\n.PHONY:\s+(\S+).*/mg) { printf "\033[36m%-30s\033[0m %s\n", $$2, $$1 } }' $(MAKEFILE_LIST) | sort

.PHONY: .FORCE
.FORCE:

WORKLOAD_NAME = nodeapp

.score-compose/state.yaml:
	score-compose init \
		--no-sample

compose.yaml: score.yaml .score-compose/state.yaml Makefile
	score-compose generate score.yaml
	yq --inplace '(.services) += (.services | with_entries(select((.value | has("hostname")) and (.value.annotations | has("dapr.io/enabled")))) | with_entries(. as $e | .key |= . + "-sidecar"| .value |= { "image": "daprio/daprd:latest", "command": [ "./daprd", ("--app-id=" + ($e.value.annotations."dapr.io/app-id" // error("missing app-id annotation"))), ("--app-port=" + ($e.value.annotations."dapr.io/app-port" // "")), ("--enable-api-logging=" + ($e.value.annotations."dapr.io/enable-api-logging" // "false")), "--placement-host-address=placement:50006", "--resources-path=/components" ], "network_mode": ("service:" + $e.key), "volumes": [".score-compose/mounts/dapr-components/:/components"], "depends_on": ["placement"] }))' compose.yaml
	yq --inplace '.services.placement = {"image": "daprio/dapr", "command": ["./placement", "-port", "50006"], "ports": ["50006:50006"]}' compose.yaml

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose \
		-f compose.yaml \
		up \
		--build \
		-d \
		--remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	curl $$(score-compose resources get-outputs dns.default#${WORKLOAD_NAME}.dns --format '{{ .host }}:8080')

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

manifests.yaml: score.yaml
	score-k8s init \
		--no-sample
	score-k8s generate score.yaml

NAMESPACE ?= default
## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up: manifests.yaml
	$(MAKE) k8s-down || true
	$(MAKE) compose-down || true
	kubectl apply \
		-f manifests.yaml \
		-n ${NAMESPACE}

## Expose the container deployed in Kubernetes via port-forward.
.PHONY: k8s-test
k8s-test: k8s-up
	kubectl wait pods \
		-n ${NAMESPACE} \
		-l score-workload=${WORKLOAD_NAME} \
		--for condition=Ready \
		--timeout=90s
	kubectl -n nginx-gateway port-forward service/ngf-nginx-gateway-fabric 8080:80

## Delete the deployment of the local container in Kubernetes.
.PHONY: k8s-down
k8s-down:
	kubectl delete \
		-f manifests.yaml \
		-n ${NAMESPACE}

## Deploy the workload to Humanitec.
.PHONY: humanitec-deploy
humanitec-deploy:
	humctl score deploy \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		-f score.yaml