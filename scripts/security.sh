#!/usr/bin/env bash

# Available environment variables
#
# REPOSITORY
# VERSION

# https://github.com/jenkinsci/docker/blob/master/update-official-library.sh
version-from-dockerfile() {
    grep VERSION: Dockerfile | sed -e 's/.*:-\(.*\)}/\1/'
}

if [[ -z $VERSION ]]; then
    VERSION=$(version-from-dockerfile)
fi

curl -s https://ci-tools.anchore.io/inline_scan-v0.3.3 | bash -s -- "$REPOSITORY:$VERSION"
