#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing cinder"
pkg install -r 11amd64-head-xen -y py27-cinder

echo ">> Setting nfsshares"
echo $CINDER_NFS_SHARE > $CINDER_NFSSHARES

echo ">> Configuring cinder.conf"
crudini --set $CINDER_CONF DEFAULT nfs_shares_config $CINDER_NFSSHARES
crudini --set $CINDER_CONF DEFAULT volume_driver cinder.volume.drivers.nfs.NfsDriver

echo ">> Restarting services"
sysrc cinder_volume_enable="YES"
service cinder-volume restart

