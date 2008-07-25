#!/bin/sh

sleep 1
ifconfig eth0:5 192.168.5.148 up
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.168.1.0/24 
echo "1" > /proc/sys/net/ipv4/ip_forward

exit 0