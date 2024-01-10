build:
	docker build \
		-t nodeapp:latest \
		--platform linux/amd64 \
		.

score-compose:
	score-compose run \
		-f score.yaml \
		-o compose.yaml

compose-up:
	docker compose \
		-f compose.yaml \
		-f compose.override.yaml \
		-f compose.dapr-sidecar.yaml \
		-f compose.dapr-placement.yaml \
		up \
		-d

compose-down:
	docker compose down \
		-v \
		--remove-orphans

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
	humctl apply \
		-f ../../../humanitec-resources/dapr-workload.yaml \
		--org ${HUMANITEC_ORG} \
		--token ${HUMANITEC_TOKEN}
	
	humctl apply \
		-f ../../../humanitec-resources/in-cluster-redis.yaml \
		--org ${HUMANITEC_ORG} \
		--token ${HUMANITEC_TOKEN}

	humctl apply \
		-f ../../../humanitec-resources/redis-dapr-state.yaml \
		--org ${HUMANITEC_ORG} \
		--token ${HUMANITEC_TOKEN}
	
	score-humanitec delta \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f score.yaml \
		--deploy \
		--retry