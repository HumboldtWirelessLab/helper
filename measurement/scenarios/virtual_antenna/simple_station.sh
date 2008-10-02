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
iwconfig ath0

echo ""
ping -c 5 141.20.21.165

echo ""
iperf -M 1400 -c 141.20.21.165 -p 20000 -t 2

echo ""
arp -a

echo ""
iwconfig ath0

exit 0
