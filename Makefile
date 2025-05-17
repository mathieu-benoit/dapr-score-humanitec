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

.score-compose/state.yaml:
	score-compose init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-compose/10-service.provisioners.yaml \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dapr-state-store/score-compose/10-redis-dapr-state-store.provisioners.yaml \
		--patch-templates https://raw.githubusercontent.com/score-spec/community-patchers/refs/heads/main/score-compose/dapr.tpl


compose.yaml: score-node.yaml score-python.yaml .score-compose/state.yaml Makefile
	score-compose generate score-node.yaml
	score-compose generate score-python.yaml

## Generate a compose.yaml file from the score spec and launch it.
.PHONY: compose-up
compose-up: compose.yaml
	docker compose -f compose.yaml up --build -d --remove-orphans
	sleep 5

## Generate a compose.yaml file from the score spec, launch it and test (curl) the exposed container.
.PHONY: compose-test
compose-test: compose-up
	curl $$(score-compose resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}:8080') # Will return "Cannot GET" but that's not an error per se.
	docker logs dapr-score-humanitec-nodeapp-nodeapp-1

## Delete the containers running via compose down.
.PHONY: compose-down
compose-down:
	docker compose down -v --remove-orphans || true

.score-k8s/state.yaml:
	score-k8s init \
		--no-sample \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/service/score-k8s/10-service.provisioners.yaml \
		--provisioners https://raw.githubusercontent.com/score-spec/community-provisioners/refs/heads/main/dapr-state-store/score-k8s/10-redis-dapr-state-store.provisioners.yaml

manifests.yaml: score-node.yaml score-python.yaml .score-k8s/state.yaml Makefile
	score-k8s generate score-node.yaml
	score-k8s generate score-python.yaml

## Create a local Kind cluster.
.PHONY: kind-create-cluster
kind-create-cluster:
	scripts/setup-kind-cluster.sh

NAMESPACE ?= default
## Generate a manifests.yaml file from the score spec and apply it in Kubernetes.
.PHONY: k8s-up
k8s-up: manifests.yaml
	kubectl apply \
		-f manifests.yaml \
		-n ${NAMESPACE}
	kubectl wait deployments/nodeapp \
		-n ${NAMESPACE} \
		--for condition=Available \
		--timeout=90s
	kubectl wait pods \
		-n ${NAMESPACE} \
		-l app.kubernetes.io/name=nodeapp \
		--for condition=Ready \
		--timeout=90s
	sleep 5

## Test the exposed endpoint and show the logs.
.PHONY: k8s-test
k8s-test: k8s-up
	curl $$(score-k8s resources get-outputs dns.default#nodeapp.dns --format '{{ .host }}') # Will return "Cannot GET" but that's not an error per se.
	kubectl logs -l app.kubernetes.io/name=nodeapp -n ${NAMESPACE}

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
		--org ${HUMANITEC_ORG} \
		--deploy-config score.deploy.yaml
