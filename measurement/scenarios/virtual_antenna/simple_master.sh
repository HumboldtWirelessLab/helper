#!/bin/sh

sleep 1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE -s 192.168.1.0/24 

ifconfig ath0 192.168.1.1 up
iwconfig ath0

sleep 10

arp -a

exit 0
