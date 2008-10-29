#!/bin/sh

sleep 3
ifconfig ath0 192.168.0.3 up
route add 192.168.0.1 gw 192.168.0.2

exit 0
