#!/bin/bash

chmod +x /elasticsearch/plugins/search-guard-6/tools/hash.sh
cd /.backup/elasticsearch/config/searchguard/ssl

export CA_PWD=$(cat /.ca_pwd)
export TS_PWD=$(cat /.ts_pwd)
export KS_PWD=$(cat /.ks_pwd)

/run/auth/certificates/cleanup.sh
/run/auth/certificates/gen_root_ca.sh

/run/auth/certificates/gen_client_node_cert.sh elastic
/run/auth/certificates/gen_client_node_cert.sh kibana
/run/auth/certificates/gen_client_node_cert.sh logstash
/run/auth/certificates/gen_client_node_cert.sh beats
/run/auth/certificates/gen_client_node_cert.sh monitoring

