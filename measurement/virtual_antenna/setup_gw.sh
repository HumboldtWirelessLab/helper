#!/bin/sh

sleep 1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.168.1.0/24 
echo "1" > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A PREROUTING -i eth0 -p TCP --dport 10001 -j DNAT --to 192.168.1.4
iptables -I FORWARD -i eth0 -o tun0 -p TCP --dport 10001 --sport 1024:65535 -d 192.168.1.4 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

exit 0