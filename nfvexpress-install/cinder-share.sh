#!/bin/sh
# Copyright (C) 2017 Alexander Nusov <alexander.nusov@nfvexpress.com>

. ./config.sh
. ./include/functions.sh

echo ">> Creating cinder share directory ($CINDER_NFS_SHARE_DIR)"
mkdir -p "$CINDER_NFS_SHARE_DIR"
#rm -fr "$CINDER_NFS_SHARE_DIR/*"

echo ">> Adding directory to NFS exports"
echo "$CINDER_NFS_SHARE_DIR $CINDER_NFS_SHARE_OPTS" >> /etc/exports

echo ">> Restarting services"
sysrc rpcbind_enable="YES"
sysrc nfs_server_enable="YES"
sysrc nfsv4_server_enable="YES"
sysrc nfsuserd_enable="YES"
sysrc mountd_enable="YES"
sysrc mountd_flags="-r"
sysrc rpc_lockd_enable="YES"
sysrc rpc_statd_enable="YES"
service nfsd restart
service mountd reload

