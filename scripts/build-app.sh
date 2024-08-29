#!/bin/bash

#########################################################################################
#
#           Script to build the multi arch images for sample app
#
#########################################################################################

set -Eeox pipefail

readonly usage="Usage: $0 --image <image>"

main() {
    parse_args "$@"
    check_args

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
    docker system prune -af --volumes
    mvn clean package

    # Build and push the app image
    ARCH_IMAGE="${IMAGE}-${arch}"

    for i in {1..10}
    do
        echo "ITERATION: $i"
        docker system prune -af --volumes
        docker pull icr.io/appcafe/open-liberty:full-java21-openj9-ubi-minimal
        echo "****** Building image: ${ARCH_IMAGE}"
        docker build -t "${ARCH_IMAGE}" .
        if [ "$?" != "0" ]; then
            echo "Error building app image: ${ARCH_IMAGE}"
            exit 1
        fi 
    done



    # echo "****** Pushing image: ${ARCH_IMAGE}"
    # docker push "${ARCH_IMAGE}"
    # if [ "$?" != "0" ]; then
    #     echo "Error pushing app image: ${ARCH_IMAGE}"
    #     exit 1
    # fi 
}

check_args() {
    if [[ -z "${IMAGE}" ]]; then
        echo "****** Missing target image for app build, see usage"
        echo "${usage}"
        exit 1
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