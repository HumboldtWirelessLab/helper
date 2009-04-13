#!/bin/sh

sleep 2

ifconfig ath0 192.168.1.2 up
route del default
route add default gw 192.168.1.1
echo ""
iwconfig ath0

echo ""
ping -c 5 192.168.1.1

echo ""
arp -a

echo ""
iwconfig ath0

exit 0
