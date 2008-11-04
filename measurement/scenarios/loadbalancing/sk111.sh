#!/bin/sh

sleep 3
ifconfig ath0 192.168.0.111 up
#route add 192.168.0.17 gw 192.168.0.1

#sleep 1
#ping -c 5 192.168.0.110
#ping -c 5 192.168.0.111
#ping -c 5 192.168.0.112

#sleep 1

iperf -s > /dev/null 2>&1 &

sleep 25

killall -9 iperf

exit 0
