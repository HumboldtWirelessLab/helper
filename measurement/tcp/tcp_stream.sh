#!/bin/sh

sleep 10

ifconfig ath0 192.168.1.2 up
route del default
route add default gw 192.168.1.1

ping -c 5 192.168.1.1

wget ftp://ftp.gnu.org/pub/gnu/gperf/gperf-2.7.2.tar.gz
rm -f gperf-2.7.2.tar.gz

exit 0