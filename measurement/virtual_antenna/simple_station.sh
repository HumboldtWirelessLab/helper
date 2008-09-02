#!/bin/sh

sleep 5

ifconfig ath0 192.168.1.2 up
iwconfig ath0

ping -c 5 -i 1 192.168.1.1

iwconfig ath0

ping -c 5 -i 1 192.168.1.1

arp -a

iwconfig ath0

exit 0
