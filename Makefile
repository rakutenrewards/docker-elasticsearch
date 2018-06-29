
ES_VERSION ?= 6.2.2
SG_VERSION = $(shell cat es-versions.json | jq '.["$(ES_VERSION)"]')
PROJECT_ID ?= id
CLOUD_PROVIDER ?= src/vendor_specific/gce
DOCKER_REPOSITORY ?= gcr.io
GENERATE_PASSWORDS ?= true

IMAGE_NAME = $(DOCKER_REPOSITORY)/$(PROJECT_ID)/es-6-sg:$(ES_VERSION)

default: deploy

image_build:
	@echo building image , es version $(ES_VERSION) , sg version $(SG_VERSION)
	docker build --build-arg ES_VERSION=$(ES_VERSION) --build-arg SG_VERSION=$(SG_VERSION) -t $(IMAGE_NAME)  .

image_push:
	docker push $(IMAGE_NAME)

create_network:
	cd $(CLOUD_PROVIDER);./create-network.sh

create_cluster:
	cd $(CLOUD_PROVIDER);./create-cluster.sh $(IMAGE_NAME) $(GENERATE_PASSWORDS)


deploy: image_build image_push create_network create_cluster
