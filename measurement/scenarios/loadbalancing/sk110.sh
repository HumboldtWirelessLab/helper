#!/bin/sh

sleep 3
ifconfig ath0 192.168.0.1 up
route add 192.168.0.3 gw 192.168.0.2

exit 0
