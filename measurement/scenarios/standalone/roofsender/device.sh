#!/bin/sh
. ../config/wifi

case "$1" in
    "start")
	/usr/sbin/wlanconfig $DEVICE create wlandev $PHYDEV wlanmode $MODE
	sleep 10
	ifconfig $DEVICE up
	sleep 2
	/usr/sbin/iwconfig $DEVICE channel $CHANNEL
	/usr/sbin/iwconfig $DEVICE txpower $POWER
	sleep 2
	echo "$DIVERSITY" > /proc/sys/dev/$PHYDEV/diversity
	sysctl -w dev.$PHYDEV.txantenna=$TXANTENNA
	sysctl -w dev.$PHYDEV.rxantenna=$RXANTENNA
	echo $WIFITYPE > /proc/sys/net/$DEVICE/dev_type
	;;
    "stop")
	ifconfig $DEVICE down
	wlanconfig $DEVICE destroy
	;;
    *)
	echo "use $0 start | stop"
	;;
esac

exit 0
