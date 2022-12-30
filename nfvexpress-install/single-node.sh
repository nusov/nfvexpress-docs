#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

if [ "$#" -ne 5 ]; then
    echo "NFV Express single-node installer"
    echo "Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>"
    echo ""
    echo "Usage:"
    echo "  $0 hypervisor hostname address pub_iface flat_iface"
    echo ""
    echo "Where"
    echo "  hypervisor - xen"
    echo "  hostname   - hostname to use for controller (`hostname -f`)"
    echo "  address    - IP address of controller"
    echo "  pub_iface  - public interface (for example em0)"
    echo "  flat_iface - interface for Flat Network between instances (either physical or tap)"
    echo ""
    echo "Example:"
    echo "  $0 xen  controller 192.168.1.20 em0 tap0"
    exit 1
fi

VIRT_TYPE="$1"
CONTROLLER_HOSTNAME="$2"
MY_IP="$3"
PUBLIC_INTERFACE="$4"
FLAT_INTERFACE="$5"
VNC_PROXYCLIENT_ADDRESS="127.0.0.1"
CINDER_NFS_SHARE_DIR="/srv/cinder"
CINDER_NFS_SHARE_OPTS="-alldirs -maproot=root"
CINDER_NFS_SHARE="$CONTROLLER_HOSTNAME:$CINDER_NFS_SHARE_DIR"

. ./config.sh
. ./include/functions.sh

case $VIRT_TYPE in
    xen)
        echo ">> Checking Xen"
        if [ -d /dev/xen ]; then
            echo "Xen hypervisor is active"
        else
            echo "Error: Xen is not installed."
            echo "Use xen-install.sh to install Xen hypervisor."
            exit 2
        fi
        ;;
    *)
        echo "Error: Unknown hypervisor $VIRT_TYPE"
        exit 2
esac


echo ">> Checking controller hostname"
if ! ping -c 1 -t 2 $CONTROLLER_HOSTNAME > /dev/null; then
    echo "Make sure you have $CONTROLER_HOSTNAME entry in /etc/hosts file"
    exit 3
fi

echo ">> Checking controller address"
if ! ping -c 1 -t 2 $CONTROLLER_ADDRESS > /dev/null; then
    echo "Error: $CONTROLLER_ADDRESS is unreachable."
    echo "Make sure you have specified correct IP address for controller"
    exit 4
fi

echo ">> Checking public interface"
if ! ifconfig $PUBLIC_INTERFACE > /dev/null; then
    exit 5
fi

echo ">> Checking flat interface"
if ! ifconfig $FLAT_INTERFACE > /dev/null; then
    case $FLAT_INTERFACE in tap*)
        echo "To use tap interface add $FLAT_INTERFACE to /etc/rc.conf"
        echo "  cloned_interfaces=\"$FLAT_INTERFACE\""
        echo "Create interface with"
        echo "  ifconfig tap create name $FLAT_INTERFACE"
        ;;
    esac
    exit 6
fi

. ./environment.sh
. ./middleware.sh
. ./keystone.sh
. ./glance.sh

. ./cinder-share.sh
. ./cinder.sh
. ./cinder-volume.sh

. ./nova.sh
. ./nova-compute.sh
. ./images.sh
. ./flavors.sh
. ./network.sh

if [ $VIRT_TYPE == "xen" ]; then
    . ./xen-metadata.sh
fi

. ./horizon.sh
. ./openrc.sh
. ./footer.sh
