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
	    
	    echo "/usr/sbin/wlanconfig $DEVICE create wlandev $PHYDEV wlanmode $MODE"
	    /usr/sbin/wlanconfig $DEVICE create wlandev $PHYDEV wlanmode $MODE
	;;
    "delete")
	    echo "ifconfig $DEVICE down"
	    ifconfig $DEVICE down
	    echo "wlanconfig $DEVICE destroy"
	    wlanconfig $DEVICE destroy
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

	    echo "/usr/sbin/iwconfig $DEVICE channel $CHANNEL"
	    /usr/sbin/iwconfig $DEVICE channel $CHANNEL

	    echo "/usr/sbin/iwconfig $DEVICE txpower $POWER"
	    /usr/sbin/iwconfig $DEVICE txpower $POWER

	    if [ ! "x$RATE" = "x" ]; then
		if [ $RATE -gt 0 ]; then
		    echo "/usr/sbin/iwconfig $DEVICE rate $RATE"
		    /usr/sbin/iwconfig $DEVICE rate $RATE
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
		    iwconfig $DEVICE essid $SSID 
		fi
	    fi
	    
#	    sleep 1
	    
#	    echo "iwpriv ath0 macclone 1"
#	    iwpriv $DEVICE macclone 1
	;;
    "start")
	    if [ "x$CONFIG" = "x" ]; then
		echo "Use CONFIG to set the config"
		exit 0
	    fi
	    
	    echo "/sbin/ifconfig $DEVICE up"
	    /sbin/ifconfig $DEVICE up
	;;	    
    *)
	;;
esac

exit 0
