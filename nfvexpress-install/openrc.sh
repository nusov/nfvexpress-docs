#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Generating $OPENRC_SH file"
tee $OPENRC_SH >/dev/null <<EOF
#!/bin/sh
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$CONTROLLER_HOSTNAME:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

echo ">> Generating $OPENRC_CSH file"
tee $OPENRC_CSH >/dev/null <<EOF
setenv OS_USERNAME admin
setenv OS_PASSWORD $ADMIN_PASS
setenv OS_PROJECT_NAME admin
setenv OS_USER_DOMAIN_NAME Default
setenv OS_PROJECT_DOMAIN_NAME Default
setenv OS_AUTH_URL http://$CONTROLLER_HOSTNAME:35357/v3
setenv OS_IDENTITY_API_VERSION 3
EOF
