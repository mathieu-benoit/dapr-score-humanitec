score-compose:
	cd node && $(MAKE) score-compose
	cd python && $(MAKE) score-compose

compose-up:
	docker compose \
		-f node/compose.yaml \
		-f python/compose.yaml \
		-f node/compose.override.yaml \
		-f python/compose.override.yaml \
		-f node/compose.dapr-sidecar.yaml \
		-f python/compose.dapr-sidecar.yaml \
		-f python/compose.dapr-placement.yaml \
		up \
		-d

compose-down:
	docker compose down \
		-v \
		--remove-orphans

score-helm:
	cd node && $(MAKE) score-helm
	cd python && $(MAKE) score-helm

k8s-up:
	cd node && $(MAKE) k8s-up
	cd python && $(MAKE) k8s-up

score-humanitec:
	cd python && $(MAKE) score-humanitec
	cd node && $(MAKE) score-humanitec
