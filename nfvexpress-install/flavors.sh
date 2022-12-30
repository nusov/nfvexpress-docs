#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Creating flavors"
openstack flavor create --id 1 --vcpus 1 --ram 512 --disk 4 m1.small
openstack flavor create --id 2 --vcpus 2 --ram 1024 --disk 10 m1.medium
