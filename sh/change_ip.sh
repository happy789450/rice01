#!/bin/bash
file=/etc/sysconfig/network-scripts/ifcfg-ens33

local_ip=$(ifconfig | egrep -A 1 "ens33:|eth0:" | grep inet | awk '{print $2}')
gateway=$(route -n  | grep ens33 | awk '{print $2}'| head -1)

cat >> $file <<EOF
IPADDR=$local_ip
DNS1=8.8.8.8
DNS2=114.114.114.114
NETMASK=255.255.255.0
GATEWAY=$gateway
EOF 

sed -i 's/DHCP/static/g' $file 

systemctl restart network

echo "当前ip修改为固定ip"
