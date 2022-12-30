#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo "Configuring NFS"
if [ ! -f /etc/ntp.conf.orig ]; then
    cp /etc/ntp.conf /etc/ntp.conf.orig
fi
sed -i.bak "s/^server/# server/" /etc/ntp.conf
awk "/# server/ && !x {print \"server $CONTROLLER_HOSTNAME iburst\"; x=1} 1" /etc/ntp.conf.bak > /etc/ntp.conf
service ntpd restart
