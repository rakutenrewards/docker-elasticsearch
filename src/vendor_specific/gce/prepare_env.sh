#!/bin/bash

export $(cat gce.env | xargs)

# extend the environment file
echo "
ELASTIC_PWD=$(openssl rand -hex 16)
KIBANA_PWD=$(openssl rand -hex 16)
LOGSTASH_PWD=$(openssl rand -hex 16)
BEATS_PWD=$(openssl rand -hex 16)
MONITORING_PWD=$(openssl rand -hex 16)
" > elastic.env

cat gce.env >> elastic.env
echo "PROJECT_ID=$PROJECT_ID" >> elastic.env
