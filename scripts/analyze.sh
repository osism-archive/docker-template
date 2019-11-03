#!/usr/bin/env bash

# Available environment variables
#
# REPOSITORY
# VERSION

docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e CI=true \
    wagoodman/dive:latest $REPOSITORY:$REPOSITORY
