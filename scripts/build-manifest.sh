#!/bin/bash

#########################################################################################
#
#           Script to build manifest list for sample app
#
#########################################################################################

set -Eeo pipefail

readonly usage="Usage: $0 --image <image>"
readonly script_dir="$(dirname "$0")"

main() {
  parse_args "$@"
  check_args

  build_manifest "${IMAGE}"
}

build_manifest() {
    local target=$1
    export DOCKER_CLI_EXPERIMENTAL=enabled

    echo "Creating manifest list with $target-amd64"
    docker manifest create "$target" "$target-amd64"
    if [ "$?" != "0" ]; then
        echo "Error creating manifest list with $target-amd64"
        exit 1
    fi
    docker manifest annotate "$target" "$target-amd64" --os linux --arch amd64
    if [ "$?" != "0" ]; then
        echo "Error adding annotations for $target-amd64 to manifest list"
        exit 1
    fi

    if [[ "$arch" == "ZXP" ]]; then
      echo "Adding $target-s390x to manifest list"
      docker manifest create --amend "$target" "$target-s390x"
      if [ "$?" != "0" ]; then
          echo "Error adding $target-s390x to manifest list"
          exit 1
      fi
      docker manifest annotate "$target" "$target-s390x" --os linux --arch s390x
      if [ "$?" != "0" ]; then
          echo "Error adding annotations for $target-s390x to manifest list"
          exit 1
      fi

      echo "Adding $target-ppc64le to manifest list"
      docker manifest create --amend "$target" "$target-ppc64le"
      if [ "$?" != "0" ]; then
          echo "Error adding $target-ppc64le to manifest list"
          exit 1
      fi
      docker manifest annotate "$target" "$target-ppc64le" --os linux --arch ppc64le
      if [ "$?" != "0" ]; then
          echo "Error adding annotations for $target-ppc64le to manifest list"
          exit 1
      fi
    fi

    docker manifest inspect "$target"
    docker manifest push "$target" --purge
    if [ "$?" = "0" ]; then
    echo "Successfully pushed $target"
    else
    echo "Error pushing $target"
    exit 1
    fi
}

check_args() {
  if [[ -z "${IMAGE}" ]]; then
    echo "****** Missing target image for manifest lists, see usage"
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