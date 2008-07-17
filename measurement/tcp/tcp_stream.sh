#!/bin/sh

sleep 10

ifconfig ath0 192.168.1.2 up
ping -c 10 192.168.1.1

exit 0