# nfvexpress-install
This bundle of scripts deploys a single-node OpenStack on FreeBSD 11 from NFV Express binary repository that includes these services

- MySQL 5.7, RabbitMQ, Memcached
- Command line OpenStack client (openstack, keystone, glance, nova commands)
- Keystone (managing authentication, authorization)
- Glance (virtual machine images)
- Nova (compute service)
- Cinder (block storage service, available only on Xen installations)
- Horizon (OpenStack Dashboard)

# Notice

**Starting 9 of March 2017, new deployments from binary repository are not encouraged.**

# Requirements
- Fresh installed FreeBSD 11 server on x86-64 hardware with at least 8GB RAM
- EPT and IOMMU processor features to use Xen hypervisor
- Configured Xen Dom0 with 6GB RAM
- At least 1 NIC with Static IP

# Networking
Make sure you have correct ``/etc/hosts`` entry that points to the machine hostname.

```
192.168.1.30 openstack
```

Also NIC should be configured statically

```
hostname="openstack"
ifconfig_re0="inet 192.168.1.30 netmask 255.255.255.0"
defaultrouter="192.168.1.1"
```

Determine the public interface name that will be for sharing internet connection to instances using NAT.

```
# ifconfig
re0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=8209b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,WOL_MAGIC,LINKSTATE>
	ether aa:bb:cc:dd:ee:ae
	inet 192.168.1.30 netmask 0xffffff00 broadcast 192.168.1.255 
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect (1000baseT <full-duplex>)
	status: active
```

Create a TAP interface for the Flat Network (between instances). 

```
# sysrc cloned_interfaces="tap0"
# ifconfig tap create name tap0
```

# Installation for Xen
Xen provides almost baremetal performance comparing to QEMU and this is a preferable option.
For more information how to install Xen on FreeBSD 11 machine please refer to [FreeBSD Wiki](https://wiki.freebsd.org/Xen)
You can also install xen hypervisor by using xen-install.sh script from this bundle.

```
# sh xen-install.sh 
Usage:
  xen-install.sh dom0_mem dom0_max_vcpus
Where
  dom0_mem       - Memory allocated for Dom0
  dom0_max_vcpus - Virtual CPUs allocated for Dom0
Example:
  xen-install.sh 6144M 4
```

Launch installation script

```
sh single-node.sh xen openstack 192.168.1.30 re0 tap0
```

# Finishing installation
When installaction completes you can navigate to the OpenStack Dashboard and try to launch a Virtual Machine.
To use command-line OpenStack clients create a openrc files and source it every time before running ``openstack`` command.

OpenRC files for sh and csh are automatically generated and located in your home directory.

```
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

CSH version is slighly different

```
setenv OS_USERNAME admin
setenv OS_PASSWORD ADMIN_PASS
setenv OS_PROJECT_NAME admin
setenv OS_USER_DOMAIN_NAME Default
setenv OS_PROJECT_DOMAIN_NAME Default
setenv OS_AUTH_URL http://controller:35357/v3
setenv OS_IDENTITY_API_VERSION 3
```

# Images
We provide a pre-built FreeBSD 11.0 image that works with NFV Express.

- https://s3.amazonaws.com/nfvexpress/images/freebsd-11-xen-xn0.qcow2.tar.bz2

# Other tested images
It's possible to boot popular Linux-based cloud images as well as *BSD

- [CentOS 7.1](http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1503.qcow2)
- [Ubuntu 14.04 LTS](https://cloud-images.ubuntu.com/trusty/current/)
- [HardenedBSD-11-STABLE-libressl-amd64-s201701160802](https://s3.amazonaws.com/nfvexpress/images/hardened.qcow2.tar.bz2) *

Images marked by asterisk are built for testing and may not be up to date.


# Uploading boot images
When using Xen hypervisor it's important to set the proper metadata for glance image in order to launch the virtual machine. This can be done by running ``xen-metadata.sh`` script or setting it manually

Please specify ``_ADMIN_PASS`` variable in ``config.sh`` before starting the ``xen-metadata.sh`` script.

```
echo ">> Setting metadata for glance images"
$ . ~/nfvexpress-openrc.sh
$ for i in $(openstack image list -f value | awk '{print $1}'); do
    glance image-update $i \
        --property hypervisor_type=xen \
        --property vm_mode=hvm \
        --property hw_disk_bus=xen
done
```

# Documentation
Full installation guide for FreeBSD® is available on our [website](http://docs.nfvexpress.com/install-guide/).

# Planned features

- ZFS support for block storage
- iSCSI drivers with multipath support
- Live migrations and quick snapshots
- Neutron service, support for rich network topologies
- VLANs and QoS
- Security groups
- Performance monitoring using Ceilometer
- Database as a Service (Trove)
- Elastic Map Reduce (Sahara)
- OpenStack Orchestration (Heat)

For more information regarding NFV Express project status read [here](https://github.com/nfvexpress/nfvexpress/blob/master/README.md).


