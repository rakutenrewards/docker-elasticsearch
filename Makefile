ES_VERSION ?= 6.2.2
SG_VERSION = $(shell cat es-versions.json | jq '.["$(ES_VERSION)"]')
CLOUD_PROVIDER ?= src/vendor_specific/gce
DOCKER_REPOSITORY ?= gcr.io
GENERATE_PASSWORDS ?= true

ifndef PROJECT_ID
$(error Please set PROJECT_ID to the name of GCE project)
endif


IMAGE_NAME = $(DOCKER_REPOSITORY)/$(PROJECT_ID)/es-6-sg:$(ES_VERSION)

default: deploy

ifeq ($(strip $(SG_VERSION)),)
$(error Please install jq from https://stedolan.github.io/jq/)
endif

image_build:
	@echo building docker image: es version $(ES_VERSION) , sg version $(SG_VERSION)
	docker build --build-arg ES_VERSION=$(ES_VERSION) --build-arg SG_VERSION=$(SG_VERSION) -t $(IMAGE_NAME)  .

image_push:
	docker push $(IMAGE_NAME)

create_network:
	cd $(CLOUD_PROVIDER); ./create-network.sh $(GENERATE_PASSWORDS)

create_cluster:
	cd $(CLOUD_PROVIDER); ./create-cluster.sh $(IMAGE_NAME) $(GENERATE_PASSWORDS)

create_lb:
	cd $(CLOUD_PROVIDER); ./create-lb.sh


deploy: image_build image_push create_network create_cluster
