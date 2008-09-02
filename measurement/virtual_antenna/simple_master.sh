#!/bin/sh

sleep 1

ifconfig ath0 192.168.1.1 up
iwconfig ath0

sleep 10

arp -a

exit 0