#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing memcached"
pkg install -r 11amd64-head-xen -y memcached py27-python-memcached
sysrc memcached_enable="YES"
service memcached restart

echo ">> Installing mysql57-server"
pkg install -r 11amd64-head-xen -y mysql57-server py27-pymysql
sysrc mysql_enable="YES"

crudini --set $MYSQL_CONF mysqld bind-address $MYSQL_BIND_ADDRESS
service mysql-server restart
sleep 3
if [ -f "$HOME/.mysql_secret" ]; then
    password=$(cat "$HOME/.mysql_secret" | grep -v '^#')
    mysql --connect-expired-password -uroot -p$password -e "SET PASSWORD = '$MYSQL_PASSWORD'"
    echo "$MYSQL_PASSWORD" > "$HOME/.mysql_secret"
fi

mysql -uroot -p$MYSQL_PASSWORD -e "SELECT 1"

echo ">> Installing rabbitmq"
pkg install -r 11amd64-head-xen -y rabbitmq
sysrc rabbitmq_enable="YES"
service rabbitmq restart
sleep 15

if rabbitmqctl list_users | grep -q openstack; then
    rabbitmqctl delete_user openstack
fi

rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

echo ">> Installing apache24"
pkg install -r 11amd64-head-xen -y apache24 ap24-mod_wsgi4
sed -i.bak "s/^#ServerName.*/ServerName $CONTROLLER_HOSTNAME/" $HTTPD_CONF
sed -i.bak "s/^ServerName.*/ServerName $CONTROLLER_HOSTNAME/" $HTTPD_CONF
sed -i.bak 's/#Load/Load/' $WSGI4_CONF
sysrc apache24_enable="YES"
service apache24 restart
