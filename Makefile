
PROJECT_ID ?= dev

IMAGE_NAME = gcr.io/$(PROJECT_ID)/es-6-sg:latest

default: build_deploy

image_build:
	echo Building $(IMAGE_NAME)
	docker build -t $(IMAGE_NAME) .

image_push:
	docker push $(IMAGE_NAME)

create_network:
	./create-network.sh

create_template:
	./cluster-template.sh $(IMAGE_NAME)

create_instances:
	./cluster-up.sh $(IMAGE_NAME)

build_deploy: image_build image_push create_instances
