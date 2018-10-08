#!/bin/bash

export $(cat gce.env | xargs)

GENERATE_PASSWORDS=${1:true}

# extend the environment file
if [ "$GENERATE_PASSWORDS" = true ] ; then
  echo "
  ELASTIC_PWD=$(openssl rand -hex 16)
  KIBANA_PWD=$(openssl rand -hex 16)
  LOGSTASH_PWD=$(openssl rand -hex 16)
  BEATS_PWD=$(openssl rand -hex 16)
  MONITORING_PWD=$(openssl rand -hex 16)
  APP_PWD=$(openssl rand -hex 16)
  READER_PWD=$(openssl rand -hex 16)
  " > elastic.env
else
  $(cat passwords > elastic.env)
fi


cat gce.env >> elastic.env
echo "PROJECT_ID=$PROJECT_ID" >> elastic.env
