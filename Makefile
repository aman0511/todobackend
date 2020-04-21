PROJECT_NAME ?= todobackend


# File name
DEV_COMPOSE_FILE := docker/dev/docker-compose.yml 
RELEASE_COMPOSE_FILE := docker/release/docker-compose.yml 


REL_PROJECT = $(PROJECT_NAME)$(BUILD_ID)
DEV_PROJECT = $(PROJECT_NAME)dev

.PHONY: test build release clean

test:
	docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) build
	docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up agent
	docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up test

build:
	docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE) up builder

release:
	docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) build
	docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) up agent
	docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) run --rm app manage.py collectstatic --noinput
	docker-compose -p $(REL_PROJECT) -f $(RELEASE_COMPOSE_FILE) run --rm app manage.py migrate --noinput

clean:
	docker-compose -f $(DEV_COMPOSE_FILE) kill
	docker-compose -f $(DEV_COMPOSE_FILE) rm -f
	docker-compose -f $(RELEASE_COMPOSE_FILE) kill
	docker-compose -f $(RELEASE_COMPOSE_FILE) rm -f