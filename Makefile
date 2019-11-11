# Makefile for Docker image building, tagging and publishing to registry

MAKEFLAGS=--warn-undefined-variables

VERSION=latest
REPO_NAME=$(REPOSITORY:osism/=)
IMAGE_NAME=$(REPOSITORY)
BUILD_OPTS=
BUILD_CONTEXT=.
DOCKERFILE=Dockerfile
DOCKER_REGISTRY=docker.io
HADOLINT_IMAGE=hadolint/hadolint
ANCHORE_SCAN_URL=https://ci-tools.anchore.io/inline_scan-v0.3.3
NOW=$(shell date --utc --iso-8601=seconds)
SCM_URL=$(shell git config --get remote.origin.url)
SCM_REF=$(shell git rev-parse --short HEAD)

.PHONY: help image-name-defined build release publish publish-latest \
  publish-version tag tag-latest tag-version pull-linter-image lint \
  security-scan

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container
	docker build \
	  --squash \
	  --file $(DOCKERFILE) \
	  --build-arg "VERSION=$(VERSION)" \
	  --label "org.opencontainers.image.title=$(REPO_NAME)" \
	  --label "org.opencontainers.image.version=$(VERSION)" \
	  --label "org.opencontainers.image.created=$(NOW)" \
	  --label "org.opencontainers.image.source=$(SCM_URL)" \
	  --label "org.opencontainers.image.revision=$(SCM_REF)" \
	  --label "org.opencontainers.image.vendor=Betacloud Solutions GmbH" \
	  --label "org.opencontainers.image.url=https://osism.de" \
	  --tag "$(IMAGE_NAME):$(VERSION)" \
          $(BUILD_OPTS) $(BUILD_CONTEXT)

release: build publish ## Make a release by building and publishing `{version}` and `latest` tagged images

publish: publish-latest publish-version ## Publish the `{version}` and `latest` tagged image

publish-latest: tag-latest ## Publish the `latest` tagged image
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged image
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)

tag: tag-latest tag-version ## Generate container tags for the `{version}` and `latest` tags

tag-latest: ## Generate container `latest` tag
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

tag-version: ## Generate container `{version}` tag
	docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(VERSION)
	docker tag $(IMAGE_NAME) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(VERSION)

pull-linter-image:
	docker pull $(HADOLINT_IMAGE)

lint: pull-linter-image ## Lint Dockerfile
        docker run \
	  --rm \
	  --interactive \
	  --volume $(CURDIR)/.hadolint.yaml:/.hadolint.yaml \
	  $(HADOLINT_IMAGE) < $(DOCKERFILE)

security-scan: ## Perform vulnerability scan on docker image
	curl --fail --silent $(ANCHORE_SCAN_URL) |\
	  bash -s -- "$(REPOSITORY):$(VERSION)"
