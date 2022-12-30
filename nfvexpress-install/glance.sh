#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing glance"
pkg install -r 11amd64-head-xen -y py27-glance

echo ">> Creating glance database" 
ensure_db glance $GLANCE_DBUSER $GLANCE_DBPASS

echo ">> Creating endpoints"
openstack user create --domain default --password $GLANCE_PASS glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne \
  image public http://$CONTROLLER_HOSTNAME:9292
openstack endpoint create --region RegionOne \
  image internal http://$CONTROLLER_HOSTNAME:9292
openstack endpoint create --region RegionOne \
  image admin http://$CONTROLLER_HOSTNAME:9292

echo ">> Configuring glance-api.conf"
crudini --set $GLANCE_API_CONF database connection "mysql+pymysql://$GLANCE_DBUSER:$GLANCE_DBPASS@$CONTROLLER_HOSTNAME/glance"
crudini --set $GLANCE_API_CONF keystone_authtoken auth_uri http://$CONTROLLER_HOSTNAME:5000
crudini --set $GLANCE_API_CONF keystone_authtoken auth_url http://$CONTROLLER_HOSTNAME:35357
crudini --set $GLANCE_API_CONF keystone_authtoken memcached_servers $CONTROLLER_HOSTNAME:11211
crudini --set $GLANCE_API_CONF keystone_authtoken auth_type password
crudini --set $GLANCE_API_CONF keystone_authtoken project_domain_name default
crudini --set $GLANCE_API_CONF keystone_authtoken user_domain_name default
crudini --set $GLANCE_API_CONF keystone_authtoken project_name service
crudini --set $GLANCE_API_CONF keystone_authtoken username glance
crudini --set $GLANCE_API_CONF keystone_authtoken password $GLANCE_PASS
crudini --set $GLANCE_API_CONF paste_deploy flavor keystone
crudini --set $GLANCE_API_CONF glance_store stores file,http
crudini --set $GLANCE_API_CONF glance_store default_store file
crudini --set $GLANCE_API_CONF glance_store filesystem_store_datadir /var/lib/glance/images/

echo ">> Configuring glance-registry.conf"
crudini --set $GLANCE_REGISTRY_CONF database connection "mysql+pymysql://$GLANCE_DBUSER:$GLANCE_DBPASS@$CONTROLLER_HOSTNAME/glance"
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken auth_uri http://$CONTROLLER_HOSTNAME:5000
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken auth_url http://$CONTROLLER_HOSTNAME:35357
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken memcached_servers $CONTROLLER_HOSTNAME:11211
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken auth_type password
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken project_domain_name default
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken user_domain_name default
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken project_name service
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken username glance
crudini --set $GLANCE_REGISTRY_CONF keystone_authtoken password $GLANCE_PASS
crudini --set $GLANCE_REGISTRY_CONF paste_deploy flavor keystone

echo ">> Syncing databases"
su -m glance -c "glance-manage db_sync"

echo ">> Restarting services"
sysrc glance_api_enable="YES"
sysrc glance_registry_enable="YES"
service glance-api restart
service glance-registry restart
