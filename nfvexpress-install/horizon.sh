#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Installing horizon"
pkg install -r 11amd64-head-xen -y py27-horizon

echo ">> Configuring horizon"
cp ./conf/local_settings.py $DASHBOARD_DIR/local/local_settings.py
sed -i.bak "s/%controller%/$CONTROLLER_HOSTNAME/g" $DASHBOARD_DIR/local/local_settings.py

echo ">> Setting permissions"
chown -R horizon $DASHBOARD_DIR/static
chown -R horizon $DASHBOARD_DIR/local

echo ">> Reloading apache24"
cp ./conf/horizon.conf /usr/local/etc/apache24/Includes
service apache24 reload

