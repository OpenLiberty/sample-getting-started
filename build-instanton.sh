#!/bin/bash

CONTAINER=getting-started-checkpoint
set -x

podman run --name $CONTAINER --privileged --env WLP_CHECKPOINT=applications dev.local/getting-started

podman commit $CONTAINER dev.local/getting-started-instanton

podman rm $CONTAINER
