#!/bin/sh

sleep 1
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
echo "1" > /proc/sys/net/ipv4/ip_forward

iptables -A PREROUTING -t nat -p udp --dport 7776 -j DNAT --to 1.0.0.3:12100

iwconfig ath0

sleep 10

iwconfig ath0

sleep 10

iwconfig ath0

sleep 8

iwconfig ath0

exit 0