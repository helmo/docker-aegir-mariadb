#!/bin/bash

# Config default, customize in config-include.sh:
export AEGIR_SITE=aegir01
export AEGIR_FRONTEND_URL=aegir01.mydomain.com
export AEGIR_EMAIL=aegir01@mydomain.com
export AEGIR_DB_PASSWORD=CHANGEME
export AEGIR_VERSION=7.x-3.x
export MYSQL_ROOT_PW=CHANGEME
export SOLR_PASS=CHANGEME
export SOLR_VERSION=4.6.0

export IMAGE_NAME=namespace/aegir_maria

if [ -f config-include.sh ]; then
  source config-include.sh
fi

docker run \
  --detach=false \
  -v /var/docker/aegir01/usr/share/solr4:/usr/share/solr4 \
  -v /var/docker/aegir01/var/aegir:/var/aegir \
  -v /var/docker/aegir01/var/log/apache2:/var/log/apache2 \
  -v /var/docker/aegir01/var/lib/mysql:/var/lib/mysql \
  -v /var/docker/aegir01/etc/mysql/conf.d:/etc/mysql/conf.d \
  -v /var/docker/aegir01/var/log/mysql:/var/log/mysql \
  -e AEGIR_SITE=$AEGIR_SITE \
  -e AEGIR_FRONTEND_URL=$AEGIR_FRONTEND_URL \
  -e AEGIR_EMAIL=$AEGIR_EMAIL \
  -e AEGIR_DB_PASSWORD=$AEGIR_DB_PASSWORD \
  -e AEGIR_VERSION=$AEGIR_VERSION \
  -e MYSQL_ROOT_PW=$MYSQL_ROOT_PW \
  -e SOLR_PASS=$SOLR_PASS \
  -e SOLR_VERSION=$SOLR_VERSION \
  -p 30880:8080 \
  -p 30080:80 \
  -p 30443:443 \
  -p 30022:22 \
  -h aegir01 \
  --name aegir01 \
  $IMAGE_NAME


#  --privileged=true \
