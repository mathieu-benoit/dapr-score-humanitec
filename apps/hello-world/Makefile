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

compose.yaml: node/score.yaml python/score.yaml
	cd node && $(MAKE) compose.yaml
	cd python && $(MAKE) compose.yaml

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose \
		-f node/compose.yaml \
		-f python/compose.yaml \
		-f node/compose.dapr-sidecar.yaml \
		-f python/compose.dapr-sidecar.yaml \
		-f python/compose.dapr-placement.yaml \
		up \
		-d \
		--remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	cd node
	curl $$(score-compose resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}:8080/ports')

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	cd node && $(MAKE) compose-down
	cd python && $(MAKE) compose-down

manifests.yaml: node/score.yaml python/score.yaml
	cd node && $(MAKE) manifests.yaml
	cd python && $(MAKE) manifests.yaml

NAMESPACE ?= default
## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up:
	cd node && $(MAKE) k8s-up
	cd python && $(MAKE) k8s-up

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
	cd node && $(MAKE) k8s-down
	cd python && $(MAKE) k8s-down

humanitec-deploy:
	cd python && $(MAKE) humanitec-deploy
	cd node && $(MAKE) humanitec-deploy
