#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo "======================================="
echo "Please keep these credentials"
echo
echo ">> MySQL Credentials"
echo "Username root"
echo "Password $MYSQL_PASSWORD"
echo

echo ">> MySQL Databases"
echo "Database Credentials"
echo "keystone $KEYSTONE_DBUSER:$KEYSTONE_DBPASS"
echo "glance   $GLANCE_DBUSER:$GLANCE_DBPASS"
echo "cinder   $CINDER_DBUSER:$CINDER_DBPASS"
echo "nova     $NOVA_DBUSER:$NOVA_DBPASS"
echo

echo ">> RabbitMQ Credentials"
echo "Username openstack"
echo "Password $RABBIT_PASS"
echo

echo ">> OpenStack Service Passwords"
echo "glance   $GLANCE_PASS"
echo "cinder   $CINDER_PASS"
echo "nova     $NOVA_PASS"
echo

echo "======================================="
echo "NFV Express has been installed."
echo "Navigate to http://$CONTROLLER_ADDRESS/"
echo
echo "Domain: default"
echo "Username: admin"
echo "Password: $ADMIN_PASS"

