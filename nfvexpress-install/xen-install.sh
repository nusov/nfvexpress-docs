#!/bin/sh
# Copyright (C) 2017, Alexander Nusov <alexander.nusov@nfvexpress.com>

SYSCTL_CONF="/etc/sysctl.conf"
LOADER_CONF="/boot/loader.conf"
TTYS="/etc/ttys"
MENU_RC="/boot/menu.rc.local"

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 dom0_mem dom0_max_vcpus"
    echo "Where"
    echo "  dom0_mem       - Memory allocated for Dom0"
    echo "  dom0_max_vcpus - Virtual CPUs allocated for Dom0"
    echo "Example:"
    echo "  $0 2048M 4"
    exit 1
fi

XEN_CMDLINE="dom0_mem=$1 dom0_max_vcpus=$2 dom0pvh=1 com1=115200,8n1 guest_loglvl=all loglvl=all"

echo "Installing Xen using configuration:"
echo "$XEN_CMDLINE"

echo ">> Installing Xen package"
pkg install -y xen

echo ">> Enabling Xen services"
sysrc xendriverdomain_enable="YES"
sysrc xencommons_enable="YES"

echo ">> Setting $SYSCTL_CONF variables"
sed -i '' '/vm\.max_wired/d' $SYSCTL_CONF
echo "vm.max_wired=-1" >> $SYSCTL_CONF

echo ">> Setting $LOADER_CONF variables"
sed -i '' '/hw\.pci\.mcfg/d' $LOADER_CONF
sed -i '' '/xen_kernel/d'    $LOADER_CONF
sed -i '' '/xen_cmdline/d'   $LOADER_CONF

echo "hw.pci.mcfg=0"                >> $LOADER_CONF
echo "xen_kernel=\"/boot/xen\""     >> $LOADER_CONF
echo "xen_cmdline=\"$XEN_CMDLINE\"" >> $LOADER_CONF

echo ">> Setting $TTYS device"
if ! grep -q xc0 $TTYS; then
    cp $TTYS $TTYS.bak
    echo 'xc0     "/usr/libexec/getty Pc"         xterm   on  secure' >> $TTYS
fi

echo ">> Setting $MENU_RC"
if [ -f $MENU_RC ]; then
    if [ ! -f $MENU_RC.bak ]; then
        cp $MENU_RC /boot/$MENU_RC.bak
    fi
fi

echo "try-include /boot/xen.4th" > $MENU_RC
echo "Installation complete. Please reboot your machine."

