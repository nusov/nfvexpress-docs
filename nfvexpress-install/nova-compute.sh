#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing nova"
pkg install -r 11amd64-head-xen -y py27-nova

echo ">> Installing libvirt"
pkg install -r 11amd64-head-xen -y libvirt

echo ">> Configuring nova.conf"
crudini --set $NOVA_CONF vnc enabled True
crudini --set $NOVA_CONF vnc novncproxy_base_url "http://$CONTROLLER_ADDRESS:6080/vnc_auto.html"
crudini --set $NOVA_CONF vnc vnc_server_listen 0.0.0.0

echo ">> Configuring nova-compute.conf"
echo > $NOVA_COMPUTE_CONF
crudini --set $NOVA_COMPUTE_CONF DEFAULT compute_driver libvirt.LibvirtDriver
crudini --set $NOVA_COMPUTE_CONF DEFAULT force_raw_images True
crudini --set $NOVA_COMPUTE_CONF DEFAULT use_cow_images False
crudini --set $NOVA_COMPUTE_CONF libvirt virt_type $VIRT_TYPE
crudini --set $NOVA_COMPUTE_CONF libvirt force_xen_phy True
crudini --set $NOVA_COMPUTE_CONF libvirt online_cpu_tracking $VIRT_CPU_TRACKING

echo ">> Restarting services"
sysrc libvirtd_enable="YES"
sysrc virtlogd_enable="YES"
sysrc nova_compute_enable="YES"
sysrc nova_network_enable="YES"

service libvirtd restart
service virtlogd restart
service nova-compute restart
service nova-network restart

sleep 3
