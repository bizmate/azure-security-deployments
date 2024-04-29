SHELL := /usr/bin/env bash
COMPOSER_HOME := $(HOME)/.config/composer
COMPOSER_CACHE_DIR := $(HOME)/.cache/composer

check_nessus_activation:
	if [ -z "$(ACTIVATION_CODE)" ]; then echo "ACTIVATION_CODE variable required, please run 'export ACTIVATION_CODE' before running make task"; exit 1 ; fi

check_uid_set:
	if [ -z "$(UID)" ]; then echo "UID variable required, please run 'export UID' before running make task"; exit 1 ; fi

up: check_uid_set check_nessus_activation
	export UID && docker-compose up -d --force-recreate
	../bin/wait_for_docker.bash "entered RUNNING state"
#	../bin/wait-for-it.sh -t 120 https://localhost:8834

logs_tail:
	if [ -z "$(UID)" ]; then echo "UID variable required, please run 'export UID' before running make task"; exit 1 ; fi
	export UID && docker-compose logs -f

down:
	docker-compose down

build:
	docker-compose build

bash:
	export UID && docker-compose run --rm nessus bash

docker_clean:
	docker rm $(docker ps -a -q) || true
	docker rmi < echo $(docker images -q | tr "\n" " ")
