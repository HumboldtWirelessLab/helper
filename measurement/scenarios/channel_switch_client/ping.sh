#!/bin/sh

ping -c 1 192.168.1.1

ifconfig ath0 192.168.1.2 up
route del default
route add default gw 192.168.1.1

echo ""
iwconfig ath0
ifconfig ath0
route -n

echo ""
ping -c 5 192.168.1.1

echo ""
arp -a

echo ""
iwconfig ath0

exit 0
