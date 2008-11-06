#!/bin/sh

sleep 3
ifconfig ath0 192.168.0.110 up
#route add 192.168.0.18 gw 192.168.0.2

#sleep 1
#ping -c 5 192.168.0.110
#ping -c 5 192.168.0.111
#ping -c 5 192.168.0.112


sleep 5

iperf -c 192.168.0.111

touch fin

exit 0
