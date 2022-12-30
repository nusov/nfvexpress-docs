#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Adding NFV Express repository"
if [ ! -d /usr/local/etc/pkg/repos ]; then
    mkdir -p /usr/local/etc/pkg/repos
fi
cp ./conf/11amd64-head-xen.conf /usr/local/etc/pkg/repos
pkg update

echo ">> Installing packages"
pkg install -r 11amd64-head-xen -y py27-pymysql py27-python-memcached py27-crudini py27-python-openstackclient
pkg install -r 11amd64-head-xen -y ca_root_nss sudo qemu-utils

echo ">> Configuring NTP Daemon using default ntp.conf"
sysrc ntpd_enable="YES"
sysrc ntpd_sync_on_start="YES"
service ntpd restart

echo ">> Configuring Packet Filter"
if [ -f $PF_CONF ]; then
    if [ ! -f $PF_CONF.orig ]; then
        cp $PF_CONF $PF_CONF.orig
    fi
fi

cp ./conf/pf.conf $PF_CONF

sysrc pf_enable="YES"
sysrc pflog_enable="YES"
kldload -n pf
kldload -n pflog
service pf restart
service pflog restart
pfctl -e

echo ">> Enabling procfs"
if ! grep -q procfs /etc/fstab; then
    echo -e "proc\t\t/proc\t\tprocfs\trw\t0\t0" >> /etc/fstab
    mount proc
fi

echo ">> Enabling NFS client"
sysrc nfs_client_enable="YES"
service nfsclient restart

if [ $VIRT_TYPE == "xen" ]; then
    echo ">> Creating /var/lib/xen directory"
    mkdir -p /var/lib/xen
fi
