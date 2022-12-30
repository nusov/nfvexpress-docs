#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

pull_image "cirros" 1 128 "http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img"

if [ $VIRT_TYPE == "xen" ]; then
    pull_image "freebsd-11" 4 512 "http://s3.amazonaws.com/nfvexpress/images/freebsd-11-xen-xn0.qcow2.tar.bz2"
else
    pull_image "freebsd-11" 4 512 "http://s3.amazonaws.com/nfvexpress/images/freebsd-11-qemu.qcow2.tar.bz2"
fi
