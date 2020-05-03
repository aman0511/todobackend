PROJECT_NAME ?= todobackend

ORG_NAME := aman0511
REPO_NAME := todobackend

# File name
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml 
RELEASE_COMPOSE_FILE := docker/release/docker-compose.yml 


REL_PROJECT := $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT := $(PROJECT_NAME)dev

DOCKER_REGISTRY := docker.io
# inspect

APP_SERVICE_NAME := app


# Build tag expression - can be used to evaluate a shell expression at runtime
BUILD_TAG_EXPRESSION ?= date -u +%Y%m%d%H%M%S

# Execute shell expression
BUILD_EXPRESSION := $(shell $(BUILD_TAG_EXPRESSION))

# Build tag - defaults to BUILD_EXPRESSION if not defined
BUILD_TAG ?= $(BUILD_EXPRESSION)


INSPECT := $$(docker-compose -p $$1 -f $$2 ps -q $$3 | xargs -I ARGS docker inspect -f "{{.State.ExitCode }}" ARGS)

CHECK := @bash -c '\
	if [[ $(INSPECT) -ne 0 ]]; \
	then exit $(INSPECT); fi' value
.PHONY: test build release clean tag buildtag

test:
	$(INFO) "Building images ....."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) pull
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build --pull test
	$(INFO) "Ensuering database is ready  ....."
	docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) run --rm agent
	$(INFO) "Running test ....."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q test):/reports/. reports
	@ ${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) test
	$(INFO) "Testing complete"


build:
	$(INFO) "Building application artifacts ....."
	@ docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up  builder
	@ ${CHECK} $(DEV_PROJECT) $(DEV_COMPOSE_FILE) builder
	$(INFO) "Copying artifacts to target folder ....."
	@ docker cp $$(docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) ps -q builder):/wheelhouse/. target
	$(INFO) "Build complete ........."

release:
	$(INFO) "Building images ....."
	@ docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) build
	$(INFO) "Ensuering database is ready  ....."
	@ docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) run --rm agent
	$(INFO) "Collecting static files"
	@ docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) run --rm app manage.py collectstatic --noinput
	$(INFO) "Running migrations..."
	@ docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) up nginx

clean:
	$(INFO) "Destroying development enviornment ....."
	@ docker-compose -f $(DEV_COMPOSE_FILE) kill
	@ docker-compose -f $(DEV_COMPOSE_FILE) rm -f -v
	@ docker-compose -f $(RELEASE_COMPOSE_FILE) kill
	@ docker-compose -f $(RELEASE_COMPOSE_FILE) rm -f -v
	@ docker images -q -f dangling=true | xargs -I ARGS docker rmi -f ARGS

	$(INFO) "Clean complete"

tag:
	${INFO} "Tagging release image with tags $(TAG_ARGS)..."
	@ $(foreach tag,$(TAG_ARGS),docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag);)
	${INFO} "Tagging complete"

buildtag:
	${INFO} "Tagging release with suffix $(BUILD_TAG) and build tags $(BUILDTAG_ARGS)..."
	@ $(foreach tag,$(BUILDTAG_ARGS),docker tag $(IMAGE_ID) $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME):$(tag).$(BUILD_TAG);)
	${INFO} "Tagging complete"

login:
	${INFO} "Logging in to Docker registry $$DOCKER_REGISTRY..."
	@ docker login --username=$$DOCKER_USER --password=$$DOCKER_PASSWORD --email=$$DOCKER_EMAIL $(DOCKER_REGISTRY_AUTH)
	${INFO} "Logged in to Docker registry $$DOCKER_REGISTRY"

logout:
	${INFO} "Logging out of Docker registry $$DOCKER_REGISTRY..."
	@ docker logout
	${INFO} "Logged out of Docker registry $$DOCKER_REGISTRY"

publish:
	${INFO} "Publishing release image $(IMAGE_ID) to $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)..."
	@ $(foreach tag,$(shell echo $(REPO_EXPR)),docker push $(tag);)
	${INFO} "Publish complete"


YELLOW := "\e[1;33m"

NC := "\e[0m"

INFO := @bash -c '\
		printf $(YELLOW);\
		echo "=>$$1";\
		printf $(NC)' value


APP_CONTAINER_ID := $$(docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) ps -q $(APP_SERVICE_NAME))
IMAGE_ID := $$(docker inspect -f '{{ .Image }}' $(APP_CONTAINER_ID))

# Repository filter
ifeq ($(DOCKER_REGISTRY), docker.io)
	REPO_FILTER := $(ORG_NAME)/$(REPO_NAME)[^[:space:]|\$$]*
else
	REPO_FILTER := $(DOCKER_REGISTRY)/$(ORG_NAME)/$(REPO_NAME)[^[:space:]|\$$]*
endif

# Introspect repository tags
REPO_EXPR := $$(docker inspect -f '{{ range .RepoTags }}{{.}} {{end}}' $(IMAGE_ID) | grep -oh "$(REPO_FILTER)" | xargs)


# Extract build tag arguments
ifeq (buildtag,$(firstword $(MAKECMDGOALS)))
	BUILDTAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(BUILDTAG_ARGS),)
  	$(error You must specify a tag)
  endif
  $(eval $(BUILDTAG_ARGS):;@:)
endif



# Extract tag arguments
ifeq (tag,$(firstword $(MAKECMDGOALS)))
  TAG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  ifeq ($(TAG_ARGS),)
    $(error You must specify a tag)
  endif
  $(eval $(TAG_ARGS):;@:)
endif