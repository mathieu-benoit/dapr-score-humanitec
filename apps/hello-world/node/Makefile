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

compose.yaml: score.yaml
	score-compose init \
		--no-sample
	score-compose generate score.yaml

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose \
		-f compose.yaml \
		-f compose.dapr-sidecar.yaml \
		-f compose.dapr-placement.yaml \
		up \
		--build \
		-d \
		--remove-orphans

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	sleep 5
	curl $$(score-compose resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}:8080')

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

score-helm:
	score-helm run \
		-f score.yaml \
		-p containers.nodeapp.variables.STATE_STORE_NAME=statestore \
		-o values.yaml

k8s-up:
	kubectl create deployment redis \
		--image=redis:alpine \
		-n ${NAMESPACE}
	kubectl expose deployment redis \
		--port 6379 \
		-n ${NAMESPACE}
	
	kubectl apply \
		-f ../components/statestore.yaml \
		-n ${NAMESPACE}
	
	helm upgrade \
		-n ${NAMESPACE} \
		--install \
		--create-namespace \
		nodeapp \
		--repo https://score-spec.github.io/score-helm-charts \
		workload \
		--values values.yaml \
		--set workload.containers.annotations."dapr\.io/enabled"=\"true\" \
		--set workload.containers.annotations."dapr\.io/app-port"=\"3000\" \
		--set workload.containers.annotations."dapr\.io/app-id"=nodeapp

	kubectl patch deployment nodeapp -p '{"spec": {"template":{"metadata":{"annotations":{"dapr.io/enabled":"true"}}}} }'
	kubectl patch deployment nodeapp -p '{"spec": {"template":{"metadata":{"annotations":{"dapr.io/app-port":"3000"}}}} }'

k8s-down:
	kubectl delete deployment redis \
		-n ${NAMESPACE}
	kubectl delete svc redis \
		-n ${NAMESPACE}
	
	kubectl delete \
		-f ../components/statestore.yaml \
		-n ${NAMESPACE}
	
	helm uninstall \
		-n ${NAMESPACE} \
		nodeapp

score-humanitec:
	score-humanitec delta \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f score.yaml \
		--deploy \
		--retry