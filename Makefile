
PROJECT_ID ?= id
CLOUD_PROVIDER ?= gce
DOCKER_REPOSITORY ?= gcr.io

IMAGE_NAME = $(DOCKER_REPOSITORY)/$(PROJECT_ID)/es-6-sg:latest

default: deploy

image_build:
	echo Building $(IMAGE_NAME)
	docker build -t $(IMAGE_NAME) .

image_push:
	docker push $(IMAGE_NAME)

create_network:
	cd $(CLOUD_PROVIDER);./create-network.sh

create_cluster:
	cd $(CLOUD_PROVIDER);./create-cluster.sh $(IMAGE_NAME)


deploy: image_build image_push create_network create_cluster
