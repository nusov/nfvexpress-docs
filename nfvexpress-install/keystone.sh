#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing keystone"
pkg install -r 11amd64-head-xen -y py27-keystone

echo ">> Creating keystone database"
ensure_db keystone $KEYSTONE_DBUSER $KEYSTONE_DBPASS

echo ">> Configuring keystone.conf"
crudini --set $KEYSTONE_CONF database connection "mysql+pymysql://$KEYSTONE_DBUSER:$KEYSTONE_DBPASS@$CONTROLLER_HOSTNAME/keystone"
crudini --set $KEYSTONE_CONF token provider fernet

echo ">> Creating endpoints"
su -m keystone -c "keystone-manage db_sync"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password "$ADMIN_PASS" \
  --bootstrap-admin-url http://$CONTROLLER_HOSTNAME:35357/v3/ \
  --bootstrap-internal-url http://$CONTROLLER_HOSTNAME:35357/v3/ \
  --bootstrap-public-url http://$CONTROLLER_HOSTNAME:5000/v3/ \
  --bootstrap-region-id RegionOne

cp ./conf/keystone.conf /usr/local/etc/apache24/Includes
service apache24 reload

sleep 2

openstack project create --domain default \
  --description "Service Project" service

openstack role create user

