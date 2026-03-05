#!/bin/bash

#########################################################################################
#
#           Script to build the multi arch images for sample app
#
#########################################################################################

set -Eeo pipefail

readonly usage="Usage: $0 --image <image>"

DEFAULT_IMAGE="icr.io/appcafe/open-liberty/samples/getting-started:latest"

main() {
    parse_args "$@"
    check_args

    echo "IMAGE: $IMAGE"

    CONTAINER_REGISTRY=$(echo "$IMAGE" | cut -d '/' -f 1)
    echo "CONTAINER_REGISTRY: $CONTAINER_REGISTRY"

    # Docker login
    echo ${PIPELINE_PASSWORD} | docker login ${CONTAINER_REGISTRY} -u "${PIPELINE_USERNAME}" --password-stdin

    # Define current arch variable
    case "$(uname -p)" in
    "ppc64le")
        readonly arch="ppc64le"
        ;;
    "s390x")
        readonly arch="s390x"
        ;;
    *)
        readonly arch="amd64"
        ;;
    esac

    # Package and download base image
    mvn clean package
    docker pull icr.io/appcafe/open-liberty:kernel-slim-java11-openj9-ubi

    # Build and push the app image
    ARCH_IMAGE="${IMAGE}-${arch}"
    echo "****** Building image: ${ARCH_IMAGE}"
    docker build -t "${ARCH_IMAGE}" .
    if [ "$?" != "0" ]; then
        echo "Error building app image: ${ARCH_IMAGE}"
        exit 1
    fi 

    echo "****** Pushing image: ${ARCH_IMAGE}"
    docker push "${ARCH_IMAGE}"
    if [ "$?" != "0" ]; then
        echo "Error pushing app image: ${ARCH_IMAGE}"
        exit 1
    fi 
}

check_args() {
    if [[ -z "${IMAGE}" ]]; then
        echo "****** Missing target image for app build"
        echo "Setting the target image to default: ${DEFAULT_IMAGE}"
        IMAGE="${DEFAULT_IMAGE}"
    fi
}

parse_args() {
    while [ $# -gt 0 ]; do
    case "$1" in
    --image)
      shift
      readonly IMAGE="${1}"
      ;;
    *)
      echo "Error: Invalid argument - $1"
      echo "$usage"
      exit 1
      ;;
    esac
    shift
  done
}

main "$@"