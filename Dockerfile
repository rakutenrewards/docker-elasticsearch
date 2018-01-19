FROM centos:7

MAINTAINER Roman Kournjaev <kournjaev@gmail.com>
LABEL Description="elasticsearch searchguard search-guard xpack gce gcs"

ENV ES_VERSION 6.1.1
ENV SG_VERSION "20.1"
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
ENV ES_TARBALL_ASC "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz.asc"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"
ENV PATH /elasticsearch/bin:$PATH

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk

RUN yum update -y && \
    yum install -y nc java-1.8.0-openjdk-headless unzip wget which bash ca-certificates util-linux curl openssl rsync && \
    yum clean all

# Install Elasticsearch.
RUN cd /tmp \
  && echo "===> Install Elasticsearch..." \
  && curl -o elasticsearch.tar.gz -Lskj "$ES_TARBAL"; \
	if [ "$ES_TARBALL_ASC" ]; then \
		curl -o elasticsearch.tar.gz.asc -Lskj "$ES_TARBALL_ASC"; \
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
		gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
		rm -r "$GNUPGHOME" elasticsearch.tar.gz.asc; \
	fi; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$ES_VERSION /elasticsearch \
  && groupadd -g 1000 elasticsearch \
  && adduser -u 1000 -g 1000 -d /elasticsearch elasticsearch \
  && echo "===> Installing search-guard..." \
  && /elasticsearch/bin/elasticsearch-plugin install -b "com.floragunn:search-guard-6:$ES_VERSION-$SG_VERSION" \
  && echo "===> Installing discovery-gce..." \
  && /elasticsearch/bin/elasticsearch-plugin install discovery-gce \
  && echo "===> Installing repository-gcs..." \
  && /elasticsearch/bin/elasticsearch-plugin install repository-gcs \
  && echo "===> Installing x-pack..." \
  && /elasticsearch/bin/elasticsearch-plugin install x-pack \
  && echo "===> Creating Elasticsearch Paths..." \
  && for path in \
  	/elasticsearch/config \
  	/elasticsearch/config/scripts \
  	/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /tmp/* \
  && rm /elasticsearch/config/elasticsearch.yml \
  && rm /elasticsearch/config/jvm.options \
  && rm /elasticsearch/config/log4j2.properties \
  && yum clean all

RUN  mkdir -p /.backup/elasticsearch/
COPY config /.backup/elasticsearch/config

VOLUME /elasticsearch/config
VOLUME /elasticsearch/data
EXPOSE 9200 9300

# env
ENV CLUSTER_NAME="elasticsearch" \
    HOSTS="127.0.0.1, [::1]" \
    MINIMUM_MASTER_NODES=1 \
    NODE_MASTER=true \
    NODE_DATA=true \
    NODE_INGEST=true \
    HTTP_ENABLE=true \
    HTTP_CORS_ENABLE=true \
    HTTP_CORS_ALLOW_ORIGIN=* \
    NETWORK_HOST="0.0.0.0" \
    ELASTIC_PWD="changeme" \
    KIBANA_PWD="changeme" \
    LOGSTASH_PWD="changeme" \
    BEATS_PWD="changeme" \
    MONITORING_PWD="changeme" \
    HEAP_SIZE="1g" \
		HTTP_SSL=false \
    LOG_LEVEL=INFO

RUN openssl rand -hex 16 > /.ca_pwd
RUN openssl rand -hex 16 > /.ts_pwd
RUN openssl rand -hex 16 > /.ks_pwd

COPY ./src/ /run/

RUN chmod +x -R /run/
RUN /run/auth/certificates/gen_all.sh

ENTRYPOINT ["/run/entrypoint.sh"]
CMD ["elasticsearch"]
