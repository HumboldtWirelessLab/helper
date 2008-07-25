#!/bin/sh

sleep 10

ifconfig ath0 192.168.1.2 up
route del default
route add default gw 192.168.1.1

ping -c 10 192.168.1.1
ping -c 4 192.168.5.3
arp -a

exit 0