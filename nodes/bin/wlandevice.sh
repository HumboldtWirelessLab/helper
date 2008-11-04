#!/bin/sh

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

case "$SIGN" in
    "/")
	DIR=$dir
	;;
    ".")
	DIR=$pwd/$dir
	;;
    *)
	echo "Error while getting directory"
	exit -1
	;;
esac

get_phy_dev() {
    NUMBER=`echo $1 | cut -b 4`
    echo "wifi$NUMBER"
}

if [ -e /usr/sbin/iwconfig ]; then
    IWCONFIG=/usr/sbin/iwconfig
else
    if [ -e /sbin/iwconfig ]; then
	IWCONFIG=/sbin/iwconfig
    fi
fi

if [ -e /usr/sbin/iwpriv ]; then
    IWPRIV=/usr/sbin/iwpriv
else
    if [ -e /sbin/iwpriv ]; then
	IWPRIV=/sbin/iwpiv
    fi
fi

if [ -e /usr/sbin/ifconfig ]; then
    IFCONFIG=/usr/sbin/ifconfig
else
    if [ -e /sbin/ifconfig ]; then
	IFCONFIG=/sbin/ifconfig
    fi
fi

if [ -e /usr/sbin/wlanconfig ]; then
    WLANCONFIG=/usr/sbin/wlanconfig
else
    if [ -e /sbin/wlanconfig ]; then
	WLANCONFIG=/sbin/wlanconfig
    fi
fi

case "$1" in
    "help")
	echo "Use $0 create | delete | config"
	exit 0;
	;;
    "create")
	    if [ "x$CONFIG" = "x" ]; then
		echo "Use CONFIG to set the config"
		exit 0
	    fi
	    
	    PHYDEV=`get_phy_dev $DEVICE`
	    
	    if [ -f  $DIR/../../nodes/etc/wifi/$CONFIG ]; then
		. $DIR/../../nodes/etc/wifi/$CONFIG
	    else
		. $CONFIG
	    fi
	    
	    echo "$WLANCONFIG $DEVICE create wlandev $PHYDEV wlanmode $MODE"
	    ${WLANCONFIG} $DEVICE create wlandev $PHYDEV wlanmode $MODE
	;;
    "delete")
	    echo "$IFCONFIG $DEVICE down"
	    ${IFCONFIG} $DEVICE down
	    echo "$WLANCONFIG $DEVICE destroy"
	    ${WLANCONFIG} $DEVICE destroy
	;;
    "config")
	    if [ "x$CONFIG" = "x" ]; then
		echo "Use CONFIG to set the config"
		exit 0
	    fi
	    
	    PHYDEV=`get_phy_dev $DEVICE`
	    
	    if [ -f  $DIR/../../nodes/etc/wifi/$CONFIG ]; then
		. $DIR/../../nodes/etc/wifi/$CONFIG
	    else
		. $CONFIG
	    fi

	    echo "$IWCONFIG $DEVICE channel $CHANNEL"
	    ${IWCONFIG} $DEVICE channel $CHANNEL

	    echo "$IWCONFIG $DEVICE txpower $POWER"
	    ${IWCONFIG} $DEVICE txpower $POWER

	    if [ ! "x$RATE" = "x" ]; then
		if [ $RATE -gt 0 ]; then
		    echo "$IWCONFIG $DEVICE rate $RATE"
		    ${IWCONFIG} $DEVICE rate $RATE
		fi
	    fi

	    echo "echo \"$DIVERSITY\" > /proc/sys/dev/$PHYDEV/diversity"
	    echo "$DIVERSITY" > /proc/sys/dev/$PHYDEV/diversity

	    echo "sysctl -w dev.$PHYDEV.txantenna=$TXANTENNA"
	    sysctl -w dev.$PHYDEV.txantenna=$TXANTENNA

	    echo "sysctl -w dev.$PHYDEV.rxantenna=$RXANTENNA"
	    sysctl -w dev.$PHYDEV.rxantenna=$RXANTENNA

	    echo "echo $WIFITYPE > /proc/sys/net/$DEVICE/dev_type"
	    echo $WIFITYPE > /proc/sys/net/$DEVICE/dev_type

	    echo "sysctl -w dev.$PHYDEV.intmit=$INTMIT"
	    sysctl -w dev.$PHYDEV.intmit=$INTMIT

	    echo "echo  \"1\" > /proc/sys/net/$DEVICE/monitor_crc_errors"
	    echo "1" > /proc/sys/net/$DEVICE/monitor_crc_errors

	    echo "echo \"1\" > /proc/sys/net/$DEVICE/monitor_phy_errors"
	    echo "1" > /proc/sys/net/$DEVICE/monitor_phy_errors
	    
	    if [ "$MODE" = "sta" ] || [ "$MODE" = "ap" ] || [ "$MODE" = "adhoc" ]; then
		if [ ! "x$SSID" = "x" ]; then
		    sleep 1
		    ${IWCONFIG} $DEVICE essid $SSID 
		fi
	    fi
	    
	    sleep 1
	    
	    echo "$IWPRIV ath0 macclone 1"
	    ${IWPRIV} $DEVICE macclone 1
	;;
    "start")
	    if [ "x$CONFIG" = "x" ]; then
		echo "Use CONFIG to set the config"
		exit 0
	    fi
	    
	    echo "$IFCONFIG $DEVICE up"
	    ${IFCONFIG} $DEVICE up
	;;	    
    *)
	;;
esac

exit 0
