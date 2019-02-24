include .env

SHELL := /bin/bash

.PHONY: build forcebuild up down shell status

export IMAGE_NAME = arris/go:latest
export CONTAINER_NAME = go

GOPATH ?= ${X_GOPATH}
PROJECT_NAME ?= ${PROJECT_NAME}
PROJECT_NS ?= ${PROJECT_NS} 
PROJECT_BIN ?= ${PROJECT_BIN}
PROJECT_DIR ?= ${PROJECT_DIR}

build:
	source .env && docker build \
	    --build-arg GOPATH=${X_GOPATH} \
	    --build-arg PROJECT_NAME=${PROJECT_NAME} \
	    --build-arg PROJECT_NS=${PROJECT_NS} \
	    --build-arg PROJECT_DIR=${PROJECT_DIR} \
	    -t ${IMAGE_NAME} .

forcebuild:
	source .env && docker build \
	    --no-cache \
	    --build-arg GOPATH=${X_GOPATH} \
	    --build-arg PROJECT_NAME=${PROJECT_NAME} \
	    --build-arg PROJECT_NS=${PROJECT_NS} \
	    --build-arg PROJECT_DIR=${PROJECT_DIR} \
	    -t ${IMAGE_NAME} .

up:
	docker run --rm -it --privileged \
		--name ${CONTAINER_NAME} \
                -e LINES=$(tput lines) \
                -e COLUMNS=$(tput cols) \
		-v /Users/arris/Code:/code \
		--mount type=bind,src=${PROJECT_DIR},dst=${GOPATH}/src/${PROJECT_NS} \
		-p 5554:5554 \
		-p 5555:5555 \
		-p 8081:8081 \
		-w ${GOPATH}/src/${PROJECT_NS} \
		${IMAGE_NAME} 

down: export CONTAINER_IDS := $(shell docker ps -qa --no-trunc --filter "status=exited")
down:
	docker stop $(CONTAINER_NAME)

clean: export CONTAINER_IDS=$(shell docker ps -qa --no-trunc --filter "status=exited")
clean:
	docker rm $(CONTAINER_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) bash

status:
	docker ps -a