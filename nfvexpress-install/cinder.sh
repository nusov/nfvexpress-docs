#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing cinder"
pkg install -r 11amd64-head-xen -y py27-cinder

echo ">> Creating cinder database" 
ensure_db cinder $CINDER_DBUSER $CINDER_DBPASS

echo ">> Creating endpoints"
openstack user create --domain default --password $CINDER_PASS cinder
openstack role add --project service --user cinder admin

openstack service create --name cinder \
  --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 \
  --description "OpenStack Block Storage" volumev2

openstack endpoint create --region RegionOne \
  volume public http://$CONTROLLER_HOSTNAME:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  volume internal http://$CONTROLLER_HOSTNAME:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  volume admin http://$CONTROLLER_HOSTNAME:8776/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne \
  volumev2 public http://$CONTROLLER_HOSTNAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  volumev2 internal http://$CONTROLLER_HOSTNAME:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  volumev2 admin http://$CONTROLLER_HOSTNAME:8776/v2/%\(tenant_id\)s

echo ">> Configuring cinder.conf"
echo > $CINDER_CONF
cinder_config

echo ">> Syncing databases"
su -m cinder -c "cinder-manage db sync"

echo ">> Restarting cinder services"
sysrc cinder_api_enable="YES"
sysrc cinder_scheduler_enable="YES"

service cinder-api restart
service cinder-scheduler restart

