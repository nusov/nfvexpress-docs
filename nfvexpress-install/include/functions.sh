#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

ensure_db() {
    echo "Creating database $1"
    mysql -uroot -p$MYSQL_PASSWORD -e "DROP DATABASE IF EXISTS $1"
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE $1"
    mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost' IDENTIFIED BY '$3'"
    mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'%' IDENTIFIED BY '$3'"
}

pull_image() {
    echo ">> Pulling image $1 from $4"
    if openstack image show $1 > /dev/null 2>/dev/null; then
        return
    fi

    mkdir -p $IMAGE_DIR
    FILENAME="${4##*/}"
    DEST="$IMAGE_DIR/$FILENAME"

    fetch $4 -o $DEST
    IMAGE_FILE="$IMAGE_DIR/$FILENAME"

    if file $DEST | grep -q bzip2; then
        IMAGE_FILE="$IMAGE_DIR/${FILENAME%.tar.bz2}"
        tar xvf $DEST -C $IMAGE_DIR
    fi

    openstack image create $1 \
        --file $IMAGE_FILE \
        --disk-format qcow2 --container-format bare \
        --min-disk $2 --min-ram $3 \
        --public
}


nova_config() {
    crudini --set $NOVA_CONF DEFAULT dhcpbridge_flagfile /usr/local/etc/nova/nova.conf
    crudini --set $NOVA_CONF DEFAULT dhcpbridge /usr/local/bin/nova-dhcpbridge
    crudini --set $NOVA_CONF DEFAULT log-dir /var/log/nova
    crudini --set $NOVA_CONF DEFAULT state_path /var/lib/nova
    crudini --set $NOVA_CONF DEFAULT force_dhcp_release False
    crudini --set $NOVA_CONF DEFAULT verbose True
    crudini --set $NOVA_CONF DEFAULT ec2_private_dns_show_ip True
    crudini --set $NOVA_CONF DEFAULT enabled_apis osapi_compute,metadata
    crudini --set $NOVA_CONF DEFAULT rpc_backend rabbit
    crudini --set $NOVA_CONF DEFAULT auth_strategy keystone
    crudini --set $NOVA_CONF DEFAULT my_ip $MY_IP
    crudini --set $NOVA_CONF DEFAULT use_neutron False
    crudini --set $NOVA_CONF DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
    crudini --set $NOVA_CONF DEFAULT use_ipv6 False
    crudini --set $NOVA_CONF DEFAULT osapi_compute_listen "0.0.0.0"
    crudini --set $NOVA_CONF DEFAULT osapi_compute_listen_port 8774
    crudini --set $NOVA_CONF DEFAULT network_driver nova.network.freebsd_net
    crudini --set $NOVA_CONF DEFAULT libvirt_vif_driver nova.virt.libvirt.vif.LibvirtGenericVIFDriver
    crudini --set $NOVA_CONF DEFAULT freebsdnet_interface_driver nova.network.freebsd_net.FreeBSDBridgeInterfaceDriver
    crudini --set $NOVA_CONF DEFAULT l3_lib nova.network.l3.FreeBSDNetL3
    crudini --set $NOVA_CONF DEFAULT network_api_class nova.network.api.API
    crudini --set $NOVA_CONF DEFAULT security_group_api nova
    crudini --set $NOVA_CONF DEFAULT network_manager nova.network.manager.FlatDHCPManager
    crudini --set $NOVA_CONF DEFAULT network_size 254
    crudini --set $NOVA_CONF DEFAULT allow_same_net_traffic False
    crudini --set $NOVA_CONF DEFAULT multi_host True
    crudini --set $NOVA_CONF DEFAULT send_arp_for_ha False
    crudini --set $NOVA_CONF DEFAULT share_dhcp_address True
    crudini --set $NOVA_CONF DEFAULT public_interface $PUBLIC_INTERFACE
    crudini --set $NOVA_CONF DEFAULT flat_network_bridge $FLAT_NETWORK_BRIDGE
    crudini --set $NOVA_CONF DEFAULT flat_interface $FLAT_INTERFACE
    crudini --set $NOVA_CONF DEFAULT transport_url "rabbit://openstack:$RABBIT_PASS@$CONTROLLER_HOSTNAME"
    crudini --set $NOVA_CONF DEFAULT auth_strategy keystone
    crudini --set $NOVA_CONF DEFAULT web /usr/local/share/novnc
    crudini --set $NOVA_CONF database connection "mysql+pymysql://$NOVA_DBUSER:$NOVA_DBPASS@$CONTROLLER_HOSTNAME/nova"
    crudini --set $NOVA_CONF api_database connection "mysql+pymysql://$NOVA_DBUSER:$NOVA_DBPASS@$CONTROLLER_HOSTNAME/nova_api"
    crudini --set $NOVA_CONF keystone_authtoken auth_uri http://$CONTROLLER_HOSTNAME:5000
    crudini --set $NOVA_CONF keystone_authtoken auth_url http://$CONTROLLER_HOSTNAME:35357
    crudini --set $NOVA_CONF keystone_authtoken memcached_servers $CONTROLLER_HOSTNAME:11211
    crudini --set $NOVA_CONF keystone_authtoken auth_type password
    crudini --set $NOVA_CONF keystone_authtoken project_domain_name default
    crudini --set $NOVA_CONF keystone_authtoken user_domain_name default
    crudini --set $NOVA_CONF keystone_authtoken project_name service
    crudini --set $NOVA_CONF keystone_authtoken username nova
    crudini --set $NOVA_CONF keystone_authtoken password $NOVA_PASS
    crudini --set $NOVA_CONF oslo_concurrency lock_path /var/lock/nova 
    crudini --set $NOVA_CONF glance api_servers http://$CONTROLLER_HOSTNAME:9292
    crudini --set $NOVA_CONF libvirt use_virtio_for_bridges True
    crudini --set $NOVA_CONF libvirt cpu_mode $CPU_MODE
    crudini --set $NOVA_CONF vnc vncserver_proxyclient_address "$VNC_PROXYCLIENT_ADDRESS"
    crudini --set $NOVA_CONF vnc vnc_server_listen "\$my_ip"
    crudini --set $NOVA_CONF wsgi api_paste_config /usr/local/etc/nova/api-paste.ini
    crudini --set $NOVA_CONF serial_console enabled $SERIAL_CONSOLE_ENABLED
    crudini --set $NOVA_CONF cinder os_region_name RegionOne
}

cinder_config() {
    crudini --set $CINDER_CONF DEFAULT rootwrap_config /usr/local/etc/cinder/rootwrap.conf
    crudini --set $CINDER_CONF DEFAULT api_paste_confg /usr/local/etc/cinder/api-paste.ini
    crudini --set $CINDER_CONF DEFAULT volume_name_template volume-%s
    crudini --set $CINDER_CONF DEFAULT volume_group cinder-volumes
    crudini --set $CINDER_CONF DEFAULT verbose True
    crudini --set $CINDER_CONF DEFAULT auth_strategy keystone
    crudini --set $CINDER_CONF DEFAULT state_path /var/lib/cinder
    crudini --set $CINDER_CONF DEFAULT lock_path /var/lock/cinder
    crudini --set $CINDER_CONF DEFAULT volumes_dir /var/lib/cinder/volumes
    crudini --set $CINDER_CONF DEFAULT transport_url rabbit://openstack:$RABBIT_PASS@$CONTROLLER_HOSTNAME
    crudini --set $CINDER_CONF DEFAULT my_ip $MY_IP
    crudini --set $CINDER_CONF database connection "mysql+pymysql://$CINDER_DBUSER:$CINDER_DBPASS@$CONTROLLER_HOSTNAME/cinder"
    crudini --set $CINDER_CONF keystone_authtoken auth_uri http://$CONTROLLER_HOSTNAME:5000
    crudini --set $CINDER_CONF keystone_authtoken auth_url http://$CONTROLLER_HOSTNAME:35357
    crudini --set $CINDER_CONF keystone_authtoken memcached_servers $CONTROLLER_HOSTNAME:11211
    crudini --set $CINDER_CONF keystone_authtoken auth_type password
    crudini --set $CINDER_CONF keystone_authtoken project_domain_name default
    crudini --set $CINDER_CONF keystone_authtoken user_domain_name default
    crudini --set $CINDER_CONF keystone_authtoken project_name service
    crudini --set $CINDER_CONF keystone_authtoken username cinder
    crudini --set $CINDER_CONF keystone_authtoken password $CINDER_PASS
    crudini --set $CINDER_CONF oslo_concurrency lock_path /var/lib/cinder/tmp
}
