#!/bin/bash

# User must be root

if [ "$(id -u)" != "0" ]; then
	echo "You must be root to run this script."
	exit 1
fi

############ START VARIABLES #################

GUEST_NAME=lab-${RANDOM}

TEMPLATE=\
/data/images/cpaquin-rhel7.3.qcow2

GUEST_IMAGE=\
/data/images/${GUEST_NAME}.qcow2

############ END VARIABLES ####################

/usr/bin/qemu-img create -f qcow2 -b ${TEMPLATE} ${GUEST_IMAGE}

cat > /tmp/ifcfg-eth0 << EOF
DEVICE=eth0
NAME=eth0
BOOTPROTO=dhcp
ONBOOT=yes
EOF

export LIBGUESTFS_BACKEND_SETTINGS=network_bridge=br101

virt-customize -a ${GUEST_IMAGE} \
--uninstall cloud-init \
--copy-in /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/ \
--hostname $GUEST_NAME \
--ssh-inject root:file:/root/.ssh/laptop.pub --selinux-relabel

/usr/bin/virt-install \
--disk path=${GUEST_IMAGE} \
--network bridge:br101 \
--name ${GUEST_NAME} \
--ram 1024 \
--vcpus 2 \
--import \
--os-type=linux \
--os-variant=rhel7 \
--noautoconsole
