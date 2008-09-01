#!/bin/sh

sleep 5

ifconfig ath0 192.168.1.3 up
route del default
route add default gw 192.168.1.1

iwconfig ath0

ping -c 5 -i 1 192.168.1.1

iwconfig ath0
ping -c 20 -i 0.2 192.168.1.2

ping -c 20 -i 0.2 141.20.21.163

#iwconfig ath0
#ping -c 50 -i 0.2 192.168.1.1

#ping -c 10 -s 990 192.168.1.2
#ping -c 100 -s 1000 -i 0.2 192.168.1.2
arp -a


iwconfig ath0
exit 0