#!/bin/bash

BRANCH=$(get_env branch)

"${COMMONS_PATH}"/compliance-checks/run.sh
