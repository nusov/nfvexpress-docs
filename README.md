# NFV Express
NFV Express is an open-source R&D project dedicated to build a scalable cloud computing platform based on OpenStack for FreeBSD Operating System started in October, 2016.

# R&D iterations
Each R&D iteration lasts for three months.
After ending the first iteration it became possible to start exploring OpenStack on FreeBSD, perform basic tasks like managing users in keystone, upload images to glance, spin-up virtual machines and connect to them via SSH or VNC in the Dashboard from your browser.


## Q4 2016
Done:
- Ported client libraries and clients for OpenStack services (python-openstackclient)
- Ported Keystone (authentication and authorization service for OpenStack services)
- Ported Glance (stores and retrieves virtual machine disk images)
- Ported Nova (manages the lifecycle of compute instances in an OpenStack environment)
- Ported Horizon (web-based dashboard and portal for OpenStack)
- Ported Cinder (persistent block storage to running instances)
- Platform-specific fixes to use Xen Dom0 as hypervisor for Nova
- Network driver for Nova and FreeBSD 11
- Floating IP support for Nova using PF
- Initial NFS support for Cinder
- Submitted all ports to the FreeBSD ports tree

## Q1 2017 (ongoing)
Done:
- Documentation for OpenStack on FreeBSD
- Installation scripts for single-node OpenStack deployment
- Binary packages with default options from FreeBSD ports tree to speed up the installation of OpenStack (building from sources takes up four hours)
- Fixed serial console (to get instance log in nova and horizon)
- FreeBSD 11 cloud images to use on FreeBSD (Xen and QEMU flavors)
- Tested compatibility with Linux (CentOS 7 and Ubuntu 14.04 LTS)

In Progress:
- Stabilizing core services
- Preparing for OpenStack Ocata
- Make a FreeBSD ports tree consistent
- Security groups
- Scripts to deploy multi-node OpenStack
- Build services (up to date FreeBSD cloud images with latest updates)
- Support for Windows Server 2012R2 (selective disk backend)

## Backlog
- Migrate to Ocata
- Support for ISO
- Backport nova-network to Ocata
- Rootwrap support
- ZFS support for block storage
- iSCSI drivers with multipath support
- Live migrations and quick snapshots
- Neutron service, support for rich network topologies
- Support for overlapping IPs (multiple private networks with the same CIDR)
- VLANs and QoS
- IPv6 support
- ARP anti-spoofing
- Devstack and code coverage
- Performance monitoring and telemetry (Ceilometer)
- Port Database as a Service (Trove)
- Port Elastic Map Reduce (Sahara)
- Port OpenStack Orchestration (Heat)
- Add support for bhyve hypervisor

# References
Before I run NFV Express I was actively searching for any information about OpenStack and FreeBSD in the internet. Here is a list of resources I found which insipired me to start the project.

- http://empt1e.blogspot.ru/2015/06/openstack-on-freebsdxen-proof-of-concept.html (Roman Borogodskiy's blog, 2015)
- http://www.semihalf.com/pub/eurobsdcon/2014_OpenStack_OpenContrail_FreeBSD.pdf (OpenStack	and	OpenContrail on	FreeBSD Platform by Semihalf and Michał	Dubiel at EuroBSDCon, 2014)
- https://github.com/pellaeon/bsd-cloudinit (BSD cloud-init scripts by Pellaeon Lin)

