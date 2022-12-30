#!/bin/sh
# Copyright (C) 2017, Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Setting metadata for glance images"
for i in $(openstack image list -f value | awk '{print $1}'); do
    glance image-update $i \
        --property hypervisor_type=xen \
        --property vm_mode=hvm \
        --property hw_disk_bus=xen
done

