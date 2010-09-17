#!/bin/sh

sleep 5

ifconfig ath0 192.168.1.3 up
route del default
route add default gw 192.168.1.1

echo ""
iwconfig ath0

echo ""
ping -c 5 -i 1 192.168.1.1

echo ""
iwconfig ath0

echo ""
ping -c 10 -i 0.2 192.168.1.2

echo ""
ping -c 10 -i 0.2 141.20.21.163

echo ""
iperf -M 1400 -c 141.20.21.165 -p 20000 -t 2

echo ""
arp -a

echo ""
iwconfig ath0

exit 0
