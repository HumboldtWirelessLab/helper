#!/bin/sh

SUF=`ifconfig eth0 | grep "inet addr" | sed "s#:# #g" | awk '{print $3}' |sed "s#\.# #g" | awk '{print $4}'`

sleep 2;

ifconfig ath0 10.10.0.$SUF

exit 0
