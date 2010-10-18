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

get_arch() {
    uname -m
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
	IWPRIV=/sbin/iwpriv
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
    else
      if [ -e /usr/bin/wlanconfig ]; then
	WLANCONFIG=/usr/bin/wlanconfig
      fi
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

	    #############################
	    #      WLAN DEV STUFF       #
	    #############################
	    WLANDEV=`echo $DEVICE | grep "wlan" | wc -l`
	    if [ "x$WLANDEV" = "x1" ]; then
	      if [ -f  $DIR/../../nodes/etc/wifi/$CONFIG ]; then
		. $DIR/../../nodes/etc/wifi/$CONFIG
	      else
		. $CONFIG
	      fi

	      . $DIR/../../nodes/etc/wifi/default


	      if [ "x$MODE" = "x" ]; then
	        MODE=$DEFAULT_MODE
	      fi

	      ${IFCONFIG} $DEVICE down
	      echo "iwconfig $DEVICE mode $MODE"
	      ${IWCONFIG} $DEVICE mode $MODE
	      ${IFCONFIG} $DEVICE up
	      exit 0
	    fi

	    PHYDEV=`get_phy_dev $DEVICE`

	    if [ -f  $DIR/../../nodes/etc/wifi/$CONFIG ]; then
			. $DIR/../../nodes/etc/wifi/$CONFIG
	    else
			. $CONFIG
	    fi

	    . $DIR/../../nodes/etc/wifi/default

	    if [ "x$MODE" = "x" ]; then
		MODE=$DEFAULT_MODE
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
	    echo "Start device config"
	    if [ "x$CONFIG" = "x" ]; then
		echo "Use CONFIG to set the config"
		exit 0
	    fi

	    PHYDEV=`get_phy_dev $DEVICE`
	    ARCH=`get_arch`

	    if [ -f  $DIR/../../nodes/etc/wifi/$CONFIG ]; then
			. $DIR/../../nodes/etc/wifi/$CONFIG
	    else
			. $CONFIG
	    fi

	    . $DIR/../../nodes/etc/wifi/default


	    if [ "x$MODE" = "x" ]; then
	    	MODE=$DEFAULT_MODE
	    fi
	    if [ "$MODE" = "sta" ] || [ "$MODE" = "ap" ] || [ "$MODE" = "adhoc" ] || [ "$MODE" = "ahdemo" ]; then
			if [ ! "x$SSID" = "x" ]; then
		    	    sleep 1
		    	    echo "$IWCONFIG $DEVICE essid $SSID" 
		    	    ${IWCONFIG} $DEVICE essid $SSID 
			    sleep 1
			fi
	    fi
	    
	    if [ "$MODE" = "ahdemo" ]; then
		if [ "x$BSSID" = "x" ]; then
			BSSID=$DEFAULT_BSSID
		fi
		echo "$IWCONFIG $DEVICE ap $BSSID"
		${IWCONFIG} $DEVICE ap $BSSID
	    fi

	    if [ "x$CHANNEL" = "x" ]; then
		CHANNEL=$DEFAULT_CHANNEL
	    fi
	    echo "$IWCONFIG $DEVICE channel $CHANNEL"
	    ${IWCONFIG} $DEVICE channel $CHANNEL

	    if [ "x$POWER" = "x" ]; then
		POWER=$DEFAULT_POWER
	    fi
	    echo "$IWCONFIG $DEVICE txpower $POWER"
	    ${IWCONFIG} $DEVICE txpower $POWER

	    if [ ! "x$RATE" = "x" ]; then
			if [ $RATE -gt 0 ]; then
		    	echo "$IWCONFIG $DEVICE rate $RATE"
		    	${IWCONFIG} $DEVICE rate $RATE
			fi
	    fi

	    if [ "$MODE" = "sta" ] || [ "$MODE" = "ap" ] || [ "$MODE" = "adhoc" ] || [ "$MODE" = "ahdemo" ]; then
		if [ ! "x$WEPKEY" = "x" ] && [ ! "x$WEPMODE" = "x" ]; then
		    echo "$IWCONFIG $DEVICE key $WEPKEY key $WEPMODE" 
		    ${IWCONFIG} $DEVICE key $WEPKEY key $WEPMODE
		    sleep 1
		fi
	    fi

	    #############################
	    #      WLAN DEV STUFF       #
	    #############################
	    WLANDEV=`echo $DEVICE | grep "wlan" | wc -l`
	    if [ "x$WLANDEV" = "x1" ]; then
	      exit 0
	    fi

	    if [ "x$MODE_ABG" != "x" ]; then
	      # 802.11b/802.11g/802.11a
	      echo "iwpriv $DEVICE mode $MODE_ABG"
	      ${IWPRIV} $DEVICE mode $MODE_ABG
	    fi

	    if [ "x$PUREG" != "x" ]; then
	      # disable/enable b
	      echo "iwpriv $DEVICE pureg $PUREG"
	      ${IWPRIV} $DEVICE pureg $PUREG
	    fi

	    if [ "x$PROTMODE" != "x" ]; then
	      # no ofdm protection
	      echo "iwpriv $DEVICE protmode $PROTMODE"
	      ${IWPRIV} $DEVICE protmode $PROTMODE
	    fi

	    if [ "x$WMM" != "x" ]; then
	      # no multimedia
	      echo "iwpriv $DEVICE wmm $WMM"
	      ${IWPRIV} $DEVICE wmm $WMM
	    fi

	    if [ "x$AR" != "x" ]; then
	      # no adaptive radio
	      echo "iwpriv $DEVICE ar $AR"
	      ${IWPRIV} $DEVICE ar $AR
	    fi

	    if [ "x$BURST" != "x" ]; then
	      # no burst
	      echo "iwpriv $DEVICE burst $BURST"
	      ${IWPRIV} $DEVICE burst $BURST
	    fi

	    if [ "x$FAST_FRAME" != "x" ]; then
	      # no fast frame
	      echo "iwpriv $DEVICE ff $FAST_FRAME"
	      ${IWPRIV} $DEVICE ff $FAST_FRAME
	    fi

	    if [ "x$ABOLT" != "x" ]; then
	      # no atheros proprietary in general
	      echo "iwpriv $DEVICE abolt $ABOLT"
	      ${IWPRIV} $DEVICE abolt $ABOLT
	    fi

	    if [ "x$DIVERSITY" = "x" ]; then
		DIVERSITY=$DEFAULT_DIVERSITY
	    fi
	    echo "sysctl -w dev.$PHYDEV.diversity=$DIVERSITY"
	    sysctl -w dev.$PHYDEV.diversity=$DIVERSITY

	    if [ "x$TXANTENNA" = "x" ]; then
		TXANTENNA=$DEFAULT_TXANTENNA
	    fi
	    echo "sysctl -w dev.$PHYDEV.txantenna=$TXANTENNA"
	    sysctl -w dev.$PHYDEV.txantenna=$TXANTENNA

	    if [ "x$RXANTENNA" = "x" ]; then
		RXANTENNA=$DEFAULT_RXANTENNA
	    fi
	    echo "sysctl -w dev.$PHYDEV.rxantenna=$RXANTENNA"
	    sysctl -w dev.$PHYDEV.rxantenna=$RXANTENNA

	    if [ "x$INTMIT" = "x" ]; then
		INTMIT=$DEFAULT_INTMIT
	    fi
	    echo "sysctl -w dev.$PHYDEV.intmit=$INTMIT"
	    sysctl -w dev.$PHYDEV.intmit=$INTMIT

	    if [ "$MODE" = "monitor" ]; then
			
			if [ "x$WIFITYPE" = "x" ]; then
				WIFITYPE=$DEFAULT_WIFITYPE
			fi
			echo "echo $WIFITYPE > /proc/sys/net/$DEVICE/dev_type"
			echo $WIFITYPE > /proc/sys/net/$DEVICE/dev_type

			if [ "x$CRCERROR" = "x" ]; then
				CRCERROR=$DEFAULT_CRCERROR
			fi
			echo "echo \"$CRCERROR\" > /proc/sys/net/$DEVICE/monitor_crc_errors"
			echo "$CRCERROR" > /proc/sys/net/$DEVICE/monitor_crc_errors

			if [ "x$PHYERROR" = "x" ]; then
				PHYERROR=$DEFAULT_PHYERROR
			fi
			echo "echo \"$PHYERROR\" > /proc/sys/net/$DEVICE/monitor_phy_errors"
			echo "$PHYERROR" > /proc/sys/net/$DEVICE/monitor_phy_errors
			
			if [ "x$MACCLONE" = "x" ]; then
				MACCLONE=$DEFAULT_MACCLONE
			fi
			echo "$IWPRIV $DEVICE macclone $MACCLONE"
			${IWPRIV} $DEVICE macclone $MACCLONE

			if [ "x$CHANNELSWITCH" = "x" ]; then
				CHANNELSWITCH=$DEFAULT_CHANNELSWITCH
			fi
			echo "$IWPRIV $DEVICE channelswitch $CHANNELSWITCH"
			${IWPRIV} $DEVICE channelswitch $CHANNELSWITCH

	    fi
		
	    if [ "x$DISABLECCA" = "x" ]; then
			DISABLECCA=$DEFAULT_DISABLECCA
	    fi
	    echo "sysctl -w dev.$PHYDEV.disable_cca=$DISABLECCA"
	    sysctl -w dev.$PHYDEV.disable_cca=$DISABLECCA

	    if [ "x$CCA_THRESHOLD" = "x" ]; then
		    echo "sysctl -w dev.$PHYDEV.cca_thresh=$CCA_THRESHOLD"
		    sysctl -w dev.$PHYDEV.cca_thresh=$CCA_THRESHOLD
	    fi

	    echo "Finished device config"
	    ;;
    "start")
	    if [ "x$CONFIG" = "x" ]; then
              echo "Use CONFIG to set the config"
              exit 0
	    fi

	    echo "$IFCONFIG $DEVICE up"
	    ${IFCONFIG} $DEVICE up
	    ;;
    "getmac")
            MADDR=`$IFCONFIG $DEVICE | grep HWaddr | awk '{print $5}' | sed -e "s#-# #g" -e "s#:# #g" | awk '{print $1":"$2":"$3":"$4":"$5":"$6}'`
            echo $MADDR
            ;;
    "getiwconfig")
            PHYDEV=`get_phy_dev $DEVICE`
            ${IWCONFIG} $DEVICE
            sysctl dev.$PHYDEV.disable_cca
            sysctl dev.$PHYDEV.cca_thresh
            ${IWPRIV} $DEVICE get_macclone
            ;;
        *)
            ;;
esac

exit 0
