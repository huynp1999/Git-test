#!/bin/bash -x
# bash script CP1 CP2 ipvlan604

e1=$1
e2=$2
ip1=$3

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


cat << EOF > /etc/sysconfig/network-scripts/ifcfg-bond0.604
DEVICE=bond0.3007
NAME=bond0.3007
BOOTPROTO=none
ONPARENT=yes
IPADDR=$ip2
NETMASK=255.255.255.224
GATEWAY=172.31.3.65
DNS1=8.8.8.8
DOMAIN=localdomain
VLAN=yes
#NM_CONTROLLED=no
EOF

ifdown $e1; ifup $e1
ifdown $e2; ifup $e2

ifdown bond0.604; ifup bond0.604
systemctl restart NetworkManager
