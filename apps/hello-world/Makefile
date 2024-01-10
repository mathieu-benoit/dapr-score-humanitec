score-compose:
	score-compose run \
		-f node/score.yaml \
		-o node-compose.yaml
	score-compose run \
		-f python/score.yaml \
		-o python-compose.yaml

up:
	docker compose \
		-f node-compose.yaml \
		-f python-compose.yaml \
		-f compose.override.yaml \
		up \
		-d

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
		-f node/score.yaml
		--deploy
	score-humanitec delta \
		--env development \
		--app ${HUMANITEC_APP} \
		--org="${HUMANITEC_ORG}" \
		--token "${HUMANITEC_TOKEN}" \
		-f python/score.yaml
		--deploy