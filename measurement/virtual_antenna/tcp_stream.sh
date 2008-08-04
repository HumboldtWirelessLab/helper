#!/bin/sh

sleep 10

ifconfig ath0 192.168.1.3 up
route del default
route add default gw 192.168.1.1

ping -c 10 192.168.1.1
ping -c 10 -s 990 192.168.1.2
#ping -c 100 -s 1000 -i 0.2 192.168.1.2
arp -a

exit 0