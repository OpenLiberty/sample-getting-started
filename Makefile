CONTAINER_REGISTRY ?= icr.io
REGISTRY_REPO ?= appcafe/open-liberty/samples/getting-started
IMAGE_TAG ?= daily
IMAGE ?= ${CONTAINER_REGISTRY}/${REGISTRY_REPO}:${IMAGE_TAG}

docker-login:
	echo ${PIPELINE_PASSWORD} | docker login ${CONTAINER_REGISTRY} -u "${PIPELINE_USERNAME}" --password-stdin

setup-prereq:
	./scripts/setup-prereq.sh

build-app-pipeline: docker-login
	./scripts/build-app.sh --image "${IMAGE}"

build-manifest-pipeline:
	./scripts/build-manifest.sh --image "${IMAGE}"
check-build:
	./scripts/pipeline/check-build.sh