#!/bin/bash -x
# bash 0-setup-bond-centos-private-scaleio.sh CP1 CP2 FB1 FB2 ipvlan3004 ipvlan3007

e1=$1
e2=$2
e3=$3
e4=$4
ip1=$5
ip2=$6

echo "bonding" >> /etc/modules-load.d/bonding.conf
modprobe --first-time bonding

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$e1
DEVICE=$e1
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
#NM_CONTROLLED=no
MTU=9000
ip link set $e1 txqueuelen 10000
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$e2
DEVICE=$e2
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
MASTER=bond0
SLAVE=yes
#NM_CONTROLLED=no
MTU=9000
ip link set $e2 txqueuelen 10000
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$e3
DEVICE=$e3
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
#MASTER=bond0
#SLAVE=yes
#NM_CONTROLLED=no
MTU=9000
ip link set $e3 txqueuelen 10000
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$e4
DEVICE=$e4
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
#MASTER=bond0
#SLAVE=yes
#NM_CONTROLLED=no
MTU=9000
ip link set $e4 txqueuelen 10000
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0
NAME=bond0
DEVICE=bond0
BONDING_MASTER=yes
TYPE=Bond
ONBOOT=yes
BOOTPROTO=none
BONDING_OPTS="mode=4 miimon=100"
#NM_CONTROLLED=no
MTU=9000
ip link set bond0 txqueuelen 10000
EOF

#cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0
#NAME=bond0
#DEVICE=bond0
#BONDING_MASTER=yes
#TYPE=Bond
#ONBOOT=yes
#BOOTPROTO=none
#BONDING_OPTS="mode=4 miimon=100"
#NM_CONTROLLED=no
#MTU=9000
#ip link set bond0 txqueuelen 10000
#EOF

#cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0.3005
#DEVICE=bond0.3005
#NAME=bond0.3005
#BOOTPROTO=none
#ONPARENT=yes
#IPADDR=$ip1
#NETMASK=255.255.252.0
#VLAN=yes
#NM_CONTROLLED=no
#MTU=9000
#ip link set bond0.3005 txqueuelen 10000
#EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0.3004
DEVICE=bond0.3004
NAME=bond0.3004
BOOTPROTO=none
ONPARENT=yes
IPADDR=$ip1
NETMASK=255.255.252.0
VLAN=yes
#NM_CONTROLLED=no
MTU=9000
ip link set bond0.3004 txqueuelen 10000
EOF

cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0.3007
DEVICE=bond0.3007
NAME=bond0.3007
BOOTPROTO=none
ONPARENT=yes
IPADDR=$ip2
NETMASK=255.255.255.0
GATEWAY=172.24.7.254
DNS1=172.24.7.204
DNS2=8.8.8.8
DOMAIN=localdomain
VLAN=yes
#NM_CONTROLLED=no
EOF

ifdown $e1; ifup $e1
ifdown $e2; ifup $e2
ifdown $e3; ifup $e3
ifdown $e4; ifup $e4

ifdown bond0.3004; ifup bond0.3004
ifdown bond0.3007; ifup bond0.3007
systemctl restart NetworkManager
