#!/bin/sh

# Common options
_CONTROLLER_HOSTNAME=$(hostname -f)
_MY_IP="192.168.1.30"
_PUBLIC_INTERFACE="re0"
_FLAT_NETWORK_BRIDGE="br100"
_FLAT_INTERFACE="tap0"
_VIRT_TYPE="xen"
_VNC_PROXYCLIENT_ADDRESS="\$my_ip"
_CINDER_NFS_SHARE_DIR="/srv/cinder"
_CINDER_NFS_SHARE_OPTS="-alldirs -maproot=root -network 192.168.1.0/24"
_CINDER_NFS_SHARE="$_CONTROLLER_HOSTNAME:$_CINDER_NFS_SHARE_DIR"

# Passwords. Leave blank to generate them automatically
_MYSQL_PASSWORD=""
_RABBIT_PASS=""
_GLANCE_DBPASS=""
_NOVA_DBPASS=""
_CINDER_DBPASS=""
_KEYSTONE_DBPASS=""
_ADMIN_PASS=""
_DEMO_PASS=""
_GLANCE_PASS=""
_NOVA_PASS=""
_CINDER_PASS=""

if [ -z "$CONTROLLER_HOSTNAME" ]; then
    CONTROLLER_HOSTNAME="$_CONTROLLER_HOSTNAME"
fi

if [ -z "$MY_IP" ]; then
    MY_IP="$_MY_IP"
fi

if [ -z "$PUBLIC_INTERFACE" ]; then
    PUBLIC_INTERFACE="$_PUBLIC_INTERFACE"
fi

if [ -z "$FLAT_NETWORK_BRIDGE" ]; then
    FLAT_NETWORK_BRIDGE="$_FLAT_NETWORK_BRIDGE"
fi

if [ -z "$FLAT_INTERFACE" ]; then
    FLAT_INTERFACE="$_FLAT_INTERFACE"
fi

if [ -z "$VIRT_TYPE" ]; then
    VIRT_TYPE="$_VIRT_TYPE"
fi

if [ -z "$VNC_PROXYCLIENT_ADDRESS" ]; then
    VNC_PROXYCLIENT_ADDRESS="$_VNC_PROXYCLIENT_ADDRESS"
fi

if [ -z "$CINDER_NFS_SHARE_DIR" ]; then
    CINDER_NFS_SHARE_DIR="$_CINDER_NFS_SHARE_DIR"
fi

if [ -z "$CINDER_NFS_SHARE_OPTS" ]; then
    CINDER_NFS_SHARE_OPTS="$_CINDER_NFS_SHARE_OPTS"
fi

if [ -z "$CINDER_NFS_SHARE" ]; then
    CINDER_NFS_SHARE="$_CINDER_NFS_SHARE"
fi


NOVA_NETWORK_RANGE="10.0.0.0/16"
NOVA_NETWORK_CIDR="10.0.20.0/24"

MYSQL_BIND_ADDRESS="$MY_IP"
MYSQL_HOSTNAME="openstack"

CONTROLLER_ADDRESS="$MY_IP"

KEYSTONE_DBUSER="keystone"
GLANCE_DBUSER="glance"
NOVA_DBUSER="nova"
CINDER_DBUSER="cinder"

MYSQL_CONF="/usr/local/etc/mysql/my.cnf"
HTTPD_CONF="/usr/local/etc/apache24/httpd.conf"
WSGI4_CONF="/usr/local/etc/apache24/modules.d/270_mod_wsgi.conf"
PF_CONF="/etc/pf.conf"
KEYSTONE_CONF="/usr/local/etc/keystone/keystone.conf"
GLANCE_API_CONF="/usr/local/etc/glance/glance-api.conf"
GLANCE_REGISTRY_CONF="/usr/local/etc/glance/glance-registry.conf"
NOVA_CONF="/usr/local/etc/nova/nova.conf"
NOVA_COMPUTE_CONF="/usr/local/etc/nova/nova-compute.conf"
CINDER_CONF="/usr/local/etc/cinder/cinder.conf"

CPU_MODE=none
NOVNC_PATH="/usr/local/share/novnc"
CINDER_NFSSHARES="/usr/local/etc/cinder/nfsshares"

IMAGE_DIR="$HOME/nfvexpress-images"

OPENRC_SH="$HOME/nfvexpress-openrc.sh"
OPENRC_CSH="$HOME/nfvexpress-openrc.csh"

if [ $VIRT_TYPE == "xen" ]; then
    VIRT_CPU_TRACKING=True
    SERIAL_CONSOLE_ENABLED=False
else
    VIRT_CPU_TRACKING=False
    SERIAL_CONSOLE_ENABLED=True
fi

DASHBOARD_DIR="/usr/local/lib/python2.7/site-packages/openstack_dashboard"

# Generate passwords
ensure_password() {
    p1=$(eval echo "\$$1")
    p2=$(eval echo "\$_$1")
    if [ -z "$p1" ]; then
        if [ -z "$p2" ]; then
            eval "$1"=$(head -c400 /dev/urandom | strings -n1 | tr -d '[:space:]' | tr -dc '[:alnum:]' | head -c 32)
        else
            eval "$1"="$p2"
        fi
    fi
}

ensure_password MYSQL_PASSWORD
ensure_password RABBIT_PASS
ensure_password GLANCE_DBPASS
ensure_password NOVA_DBPASS
ensure_password CINDER_DBPASS
ensure_password KEYSTONE_DBPASS
ensure_password ADMIN_PASS
ensure_password GLANCE_PASS
ensure_password NOVA_PASS
ensure_password CINDER_PASS

# Set environment variables for python-openstackclient
export OS_USERNAME=admin
export OS_PASSWORD="$ADMIN_PASS"
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_DOMAIN_NAME=default
export OS_AUTH_URL=http://$CONTROLLER_HOSTNAME:35357/v3
export OS_IDENTITY_API_VERSION=3
