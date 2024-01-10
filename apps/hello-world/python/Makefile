score-compose:
	score-compose run \
		-f score.yaml \
		-o compose.yaml

up:
	docker compose up -d

down:
	docker compose down \
		-v \
		--remove-orphans

score-humanitec:
	score-humanitec delta \
		--env development \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f score.yaml
		--deploy