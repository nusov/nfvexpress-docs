#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing nova"
pkg install -r 11amd64-head-xen -y py27-nova libvirt

echo ">> Installing novnc"
if [ -d $NOVNC_PATH ]; then
    rm -fr $NOVNC_PATH
fi

mkdir -p $NOVNC_PATH

fetch "https://github.com/novnc/noVNC/archive/v0.6.2.tar.gz" -o /tmp/novnc.tar.gz
tar xvf /tmp/novnc.tar.gz --strip 1 -C $NOVNC_PATH

echo ">> Creating keystone database"
ensure_db nova_api $NOVA_DBUSER $NOVA_DBPASS
ensure_db nova $NOVA_DBUSER $NOVA_DBPASS

echo ">> Creating endpoints"
openstack user create --domain default \
  --password $NOVA_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova \
  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne \
  compute public http://$CONTROLLER_HOSTNAME:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  compute internal http://$CONTROLLER_HOSTNAME:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne \
  compute admin http://$CONTROLLER_HOSTNAME:8774/v2.1/%\(tenant_id\)s

echo ">> Configuring nova.conf"
echo > $NOVA_CONF
nova_config

echo ">> Syncing databases"
su -m nova -c "nova-manage api_db sync"
su -m nova -c "nova-manage db sync"

echo ">> Creating directory for instances"
su -m nova -c "mkdir /var/lib/nova/instances"

echo ">> Restarting services"
sysrc nova_api_enable="YES"
sysrc nova_scheduler_enable="YES"
sysrc nova_conductor_enable="YES"
sysrc nova_consoleauth_enable="YES"
sysrc nova_novncproxy_enable="YES"

service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-consoleauth restart
service nova-novncproxy restart

sleep 3

