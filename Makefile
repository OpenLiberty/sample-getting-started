# Default values if not set
CONTAINER_REGISTRY ?= icr.io
REGISTRY_REPO ?= appcafe/open-liberty/samples/getting-started
IMAGE_TAG ?= latest
IMAGE ?= ${CONTAINER_REGISTRY}/${REGISTRY_REPO}:${IMAGE_TAG}

docker-login:
	echo ${PIPELINE_PASSWORD} | docker login ${CONTAINER_REGISTRY} -u "${PIPELINE_USERNAME}" --password-stdin

build-app-pipeline: docker-login
	./scripts/build-app.sh --image "${IMAGE}"

build-manifest-pipeline:
	./scripts/build-manifest.sh --image "${IMAGE}"

check-build: docker-login
	./scripts/pipeline/check-build.sh --image "${IMAGE}"
