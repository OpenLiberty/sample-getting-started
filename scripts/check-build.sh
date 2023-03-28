#!/bin/bash

#########################################################################################
#
#           Script to validate production image for sample app
#
#########################################################################################

set -Eeo pipefail

readonly usage="Usage: $0"

main() {
    echo "Validate image is available on icr.io"
    # move login, pull, run and log check to make target
    echo $PIPELINE_PROD_PASSWORD | docker login "$PROD_CONTAINER_REGISTRY" -u "$PIPELINE_USERNAME" --password-stdin
    docker pull $PROD_IMAGE
    docker images
            
    docker run -d --name getting-started-sample -p 9080:9080 $PROD_IMAGE
    sleep 5
    if [[ $(docker logs getting-started-sample) == *"CWWKF0011I"* ]]; then
        echo "image is good"
    else
        echo "image is not good"
        exit 1	
    fi
}

main "$@"
