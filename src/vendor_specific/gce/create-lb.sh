#!/bin/bash

source ./prepare_env.sh false

HEALTH_CHECK_NAME=$TEMPLATE_NAME"-health-check"
BACKEND_SERVICE_NAME=$TEMPLATE_NAME"-lb"
FORWARDING_RULE_NAME=$TEMPLATE_NAME"-forward-rule"

if [ -z "$LB_NETWORK" ]
then
    LB_NETWORK=$NETWORK
fi

if [ -z "$LB_SUBNET" ]
then
    LB_SUBNET=$SUBNET
fu

echo Cleanup
gcloud --quiet compute forwarding-rules delete $FORWARDING_RULE_NAME \
    --project $PROJECT_ID \
    --region $REGION
gcloud --quiet compute backend-services delete $BACKEND_SERVICE_NAME \
    --project $PROJECT_ID \
    --region $REGION
gcloud --quiet compute health-checks delete $HEALTH_CHECK_NAME \
    --project $PROJECT_ID

echo Creating health check with name $HEALTH_CHECK_NAME
gcloud compute health-checks create tcp $HEALTH_CHECK_NAME \
    --project $PROJECT_ID \
    --port 9200

echo Creating backend service with name $BACKEND_SERVICE_NAME
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
    --project $PROJECT_ID \
    --protocol TCP \
    --health-checks $HEALTH_CHECK_NAME \
    --timeout 5m \
    --port-name 9200 \
    --load-balancing-scheme=INTERNAL \
    --region $REGION \
    --protocol TCP \
    --timeout "120s"
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --project=$PROJECT_ID \
    --instance-group=$TEMPLATE_NAME \
    --region $REGION \
    --instance-group-zone $ZONE

echo Creating forwarding rule with name $FORWARDING_RULE_NAME
gcloud compute forwarding-rules create $FORWARDING_RULE_NAME \
    --project=$PROJECT_ID \
    --backend-service=$BACKEND_SERVICE_NAME \
    --ip-protocol TCP \
    --load-balancing-scheme INTERNAL \
    --network $LB_NETWORK \
    --subnet $LB_SUBNET \
    --subnet-region $REGION \
    --backend-service-region $REGION \
    --region $REGION \
    --ports 9200


