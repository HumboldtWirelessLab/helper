#!/bin/sh

sleep 1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo "1" > /proc/sys/net/ipv4/ip_forward

#iptables -A INPUT -p udp -j LOG --log-prefix "INPUT (UDP): "
#iptables -A OUTPUT -p udp -j LOG --log-prefix "OUTPUT: "
#iptables -A FORWARD -p udp -j LOG --log-prefix "FORWARD: "
iptables -A POSTROUTING -t nat -p udp -j LOG --log-prefix "POSTROUTING: "
#iptables -A PREROUTING -t nat -p udp -j LOG --log-prefix "PREROUTING: "
iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE -s 192.168.1.0/24 
iptables -A PREROUTING -t nat -p udp --dport 10000 -j DNAT --to 1.0.0.4:10002

exit 0