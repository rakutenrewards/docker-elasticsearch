
PROJECT_ID ?= dev

IMAGE_NAME = gcr.io/$(PROJECT_ID)/es-6-sg:latest

default: build_deploy

image_build:
	echo Building $(IMAGE_NAME)
	docker build -t $(IMAGE_NAME) .

image_push:
	gcloud docker --project $(PROJECT_ID) -- push $(IMAGE_NAME)

create_template:
	./cluster-template.sh $(IMAGE_NAME) 

create_instances:
	./cluster-up.sh $(IMAGE_NAME)

build_deploy: image_build image_push create_instances