#!/bin/bash
IMAGE_NAME=$1

source ./prepare_env.sh

gcloud beta compute instance-templates create-with-container $TEMPLATE_NAME \
--tags=$TAGS --container-image=$IMAGE_NAME --machine-type=$INSTANCE_TYPE \
--no-boot-disk-auto-delete --boot-disk-size=$DISK_SIZE --boot-disk-type=pd-ssd \
--scopes=default,storage-full,compute-rw --network=$NETWORK  \
--container-mount-host-path host-path=/mnt/stateful_partition/es-data,mount-path=/elasticsearch/data \
--container-mount-host-path host-path=/mnt/stateful_partition/es-logs,mount-path=/elasticsearch/logs \
--container-env-file=elastic.env \
--metadata-from-file startup-script=instance-startup.sh \
--can-ip-forward --project=$PROJECT_ID
