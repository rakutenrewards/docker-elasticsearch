#!/bin/bash

set -m

#Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

/run/miscellaneous/restore_config.sh
cat /elasticsearch/config/elasticsearch.yml

export CA_PWD=$(cat /.ca_pwd)
export TS_PWD=$(cat /.ts_pwd)
export KS_PWD=$(cat /.ks_pwd)
export ES_JAVA_OPTS="-Xms$HEAP_SIZE -Xmx$HEAP_SIZE"

if [ "$NODE_NAME" = "" ]; then
	export NODE_NAME=NODE-$HOSTNAME
fi

if [ ! -f .node_crt ] ; then
  /run/auth/certificates/gen_node_cert.sh
  touch .node_crt
fi

chown -R elasticsearch:elasticsearch /elasticsearch
 

if [[ !  -z  $GCS_SERVICE_ACCOUNT  ]]; then
  elasticsearch-keystore create
  echo $GCS_SERVICE_ACCOUNT | base64 -d > /tmp/gcs.client.default.credentials_file
  elasticsearch-keystore add-file -f gcs.client.default.credentials_file /tmp/gcs.client.default.credentials_file
fi


if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
  exec chroot --userspec=1000 / "$@" &
else
	$@ &
fi

/run/miscellaneous/wait_until_started.sh
/run/miscellaneous/index_level_settings.sh

/run/auth/users.sh
/run/auth/sgadmin.sh

fg
