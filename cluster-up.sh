#!/bin/bash
IMAGE_NAME=$1

source ./prepare_env.sh

# concat all nodes addresses
hosts=""
for ((i=1; i<$CLUSTER_SIZE + 1; i++)); do
    hosts+="$INSTANCE_NAME-$i"
	[ $i != $(($CLUSTER_SIZE)) ] && hosts+=","
done

echo "HOSTS=$hosts" >> elastic.env

# starting nodes
for ((i=1; i<$CLUSTER_SIZE+1; i++)); do
    echo "Starting node $INSTANCE_NAME-$i"
    gcloud beta compute instances create-with-container $INSTANCE_NAME-$i \
    --tags=$TAGS --container-image=$IMAGE_NAME --machine-type=$INSTANCE_TYPE \
    --no-boot-disk-auto-delete --boot-disk-size=$DISK_SIZE --boot-disk-type=pd-ssd \
    --network=$NETWORK --scopes=default,storage-full,compute-rw --zone=$ZONE \
    --container-mount-host-path host-path=/mnt/stateful_partition/es-data,mount-path=/elasticsearch/data \
    --container-mount-host-path host-path=/mnt/stateful_partition/es-logs,mount-path=/elasticsearch/logs \
    --container-env-file=elastic.env \
    --metadata-from-file startup-script=instance-startup.sh \
    --can-ip-forward --project=$PROJECT_ID
done
