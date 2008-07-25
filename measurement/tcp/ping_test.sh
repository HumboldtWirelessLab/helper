#!/bin/sh

sleep 10

ifconfig ath0 192.168.1.2 up
route del default
route add default gw 192.168.1.1

ping -c 5 192.168.1.1
echo ""
echo ""
ping -c 5 192.168.5.148
echo ""
echo ""
ping -c 5 209.85.135.147
echo ""
echo ""
ping -c 5 www.google.de

#arp -a

exit 0