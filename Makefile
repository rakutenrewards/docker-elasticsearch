ES_VERSION ?= 6.6.1
SG_VERSION = $(shell cat es-versions.json | jq '.["$(ES_VERSION)"]'| tr -d '"')
CLOUD_PROVIDER ?= gce
DOCKER_REPOSITORY ?= gcr.io
GENERATE_PASSWORDS ?= false
DOKCER_NAMESPACE =
CLOUD_PROVIDER_PATH=src/vendor_specific/

ifeq ($(CLOUD_PROVIDER), gce) 
ifndef DOKCER_NAMESPACE
$(error Please set DOKCER_NAMESPACE to the name of GCE project)
endif
endif

ifeq ($(SG_VERSION), null) 
$(error ES Version $(ES_VERSION) not supported)
endif

IMAGE_NAME = $(DOCKER_REPOSITORY)/$(DOKCER_NAMESPACE)/es-6-sg-$(CLOUD_PROVIDER):$(ES_VERSION)_$(SG_VERSION)

default: deploy

ifeq ($(strip $(SG_VERSION)),)
$(error Please install jq from https://stedolan.github.io/jq/)
endif

image_build:
	@echo building docker image: es version $(ES_VERSION) , sg version $(SG_VERSION) , provider $(CLOUD_PROVIDER)
	docker build --build-arg ES_VERSION=$(ES_VERSION) --build-arg SG_VERSION=$(SG_VERSION) --build-arg CLOUD_PROVIDER=$(CLOUD_PROVIDER) -t es_builder:$(ES_VERSION)_$(SG_VERSION) . -f Dockerfile
	docker build --build-arg ES_VERSION=$(ES_VERSION) --build-arg SG_VERSION=$(SG_VERSION) -t $(IMAGE_NAME) . -f Dockerfile.$(CLOUD_PROVIDER)

image_push:
	docker push $(IMAGE_NAME)

create_network:
	cd $(CLOUD_PROVIDER_PATH)/$(CLOUD_PROVIDER); ./create-network.sh $(GENERATE_PASSWORDS)

create_cluster:
	cd $(CLOUD_PROVIDER_PATH)/$(CLOUD_PROVIDER); ./create-cluster.sh $(IMAGE_NAME) $(GENERATE_PASSWORDS)

create_lb:
	cd $(CLOUD_PROVIDER_PATH)/$(CLOUD_PROVIDER); ./create-lb.sh


deploy: image_build image_push create_network create_cluster
