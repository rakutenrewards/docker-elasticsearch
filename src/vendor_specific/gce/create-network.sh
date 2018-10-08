#!/bin/bash
source ./prepare_env.sh

echo Creating Network $NETWORK
gcloud compute networks create $NETWORK --project=$PROJECT_ID

echo Firerwall rules
gcloud compute firewall-rules create $NETWORK-allow-intracluster \
  --source-tags $TAGS --target-tags $TAGS --allow tcp:1-65535 \
  --network $NETWORK --project=$PROJECT_ID

gcloud compute firewall-rules create $NETWORK-allow-load-balancer \
  --source-ranges="130.211.0.0/22,35.191.0.0/16" --target-tags $TAGS \
  --allow tcp:9200 --network $NETWORK --project=$PROJECT_ID

gcloud compute firewall-rules create $NETWORK-allow-ssh \
  --source-ranges="0.0.0.0/0" --target-tags $TAGS \
  --allow tcp:22 --network $NETWORK --project=$PROJECT_ID
