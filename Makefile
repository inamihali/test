# -*- mode: makefile -*-
PROJECT_NAME = golang-demo-app

DOCKER = docker
VERSION = $(shell git rev-parse --short HEAD)
TO := _

ifdef JOB_BASE_NAME
PROJECT_ENCODED_SLASH = $(subst %2F,$(TO),$(JOB_BASE_NAME))
PROJECT = $(subst /,$(TO),$(PROJECT_ENCODED_SLASH))
# Run on CI
COMPOSE = COMPOSE_DOCKER_CLI_BUILD=1 docker-compose -f docker-compose.yml -f docker-compose.ci.yml -p $(PROJECT_NAME)_$(PROJECT)_$(NUMBER)
else
# Run Locally
COMPOSE = docker-compose -p $(PROJECT_NAME)
endif

.PHONY: build test

CLUSTER_NAME="dev-orscale-01-dm-dc3"
IMAGE_TAG=$(shell git rev-parse --short HEAD)-dirty

test: test-unit

test-unit:
	$(COMPOSE) build test-unit
	$(COMPOSE) run test-unit

.PHONY: build
build:
	$(COMPOSE) build app
	$(COMPOSE) run -d --service-ports app

# Build Sonar properties file (sonar-project.properties)
# Set version with the short hash commit
prepare-sonar:
	cp sonar-project.properties.default sonar-project.properties
	echo "sonar.projectVersion=$(IMAGE_TAG)" >> sonar-project.properties

.PHONY: init
init:
	# This following command is used to provision the network
	$(COMPOSE) up --no-start --no-build app | true

.PHONY: down
down:
	$(COMPOSE) down --volumes
