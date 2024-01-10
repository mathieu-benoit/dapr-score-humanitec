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
		-o values.yaml

k8s-up:
	helm upgrade \
		-n ${NAMESPACE} \
		--install \
		--create-namespace \
		pythonapp \
		--repo https://score-spec.github.io/score-helm-charts \
		workload \
		--values values.yaml \
		--set workload.containers.annotations."dapr\.io/enabled"=\"true\" \
		--set workload.containers.annotations."dapr\.io/app-id"=pythonapp
	
	kubectl patch deployment pythonapp -p '{"spec": {"template":{"metadata":{"annotations":{"dapr.io/enabled":"true"}}}} }'

k8s-down:
	helm uninstall \
		-n ${NAMESPACE} \
		pythonapp

score-humanitec:
	humctl apply \
		-f ../../../humanitec-resources/dapr-workload.yaml \
		--org ${HUMANITEC_ORG} \
		--token ${HUMANITEC_TOKEN}
	
	score-humanitec delta \
		--env ${HUMANITEC_ENVIRONMENT} \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f score.yaml \
		--deploy