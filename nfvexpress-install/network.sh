#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo "Creating security group rules"
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default

echo "Creating network"
nova network-create vmnet \
  --fixed-range-v4 $NOVA_NETWORK_RANGE --fixed-cidr $NOVA_NETWORK_CIDR --bridge $FLAT_NETWORK_BRIDGE
