#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

for i in $(echo mysql-server memcached rabbitmq apache24 glance nova cinder); do
    for j in $(service -e | grep $i); do
        $j stop
    done
done

for i in $(echo xen); do
    if virsh -c $i:///system list > /dev/null; then
        for j in $(virsh -c $i:///system list --all | grep instance | awk '{print $2}'); do
            virsh -c $i:///system destroy $j
            virsh -c $i:///system undefine $j
        done
    fi
done

pkill -9 dnsmasq
pkill -f nova-conductor

for i in $(echo nova cinder); do
    for j in $(mount | grep /var/lib/$i | grep nfs | awk '{print $3}'); do
        umount $j
    done
done

rm -fr /usr/local/etc/keystone/fernet-keys
rm -fr /usr/local/etc/keystone/credential-keys
rm -fr /var/lib/glance/*
rm -fr /var/lib/nova/*
rm -fr /var/lib/cinder/*

rm -f $HOME/nfvexpress-openrc.sh
rm -f $HOME/nfvexpress-openrc.csh
