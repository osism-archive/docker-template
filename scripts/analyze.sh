#!/usr/bin/env bash

# Available environment variables
#
# REPOSITORY
# VERSION

# list image

docker images

# inspect image

docker inspect $REPOSITORY:$VERSION

# analyze image with dive

CI=true dive $REPOSITORY:$VERSION
