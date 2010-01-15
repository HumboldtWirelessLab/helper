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

NETWORK=10
NETADDRESS=10.0.0.0
BROADCAST=10.255.255.255
NETMASK=255.0.0.0
NET_SLASH=8
BSSID_A="02:CA:FF:EE:BA:BA"
BSSID_B="02:CA:FF:EE:BA:BB"

get_ip_from_mac () {
        # e.g. "23:E1:5E  " (note the 2 spaces at the end)
	HEXNUM=$(ifconfig $1 | grep -e "[[:xdigit:]]*:[[:xdigit:]]*:[[:xdigit:]]*  $" | awk '{print $5}' | sed "s#:# #g" | awk '{print $4":"$5":"$6}')
	HEXNUM="$HEXNUM  "
        #HEXNUM=$(ifconfig $1 | grep -e "[[:xdigit:]]*:[[:xdigit:]]*:[[:xdigit:]]*  $")
        # 23:E1 (just a helper)
        FIRST_TWO_HEX=${HEXNUM%?????}
        # 0x"5E  "
        HEX3=0x${HEXNUM#??????}
        # 0x23
        HEX1=0x${HEXNUM%????????}
        # 0xE1
        HEX2=0x${FIRST_TWO_HEX#???}
        # 10.x.x.x
#        IP="$NETWORK.$HEX1.$HEX2.$HEX3"
        IP=$(printf $NETWORK."%d.%d.%d\n" $HEX1 $HEX2 $HEX3)
        echo $IP
}

setup_wlan0 () {
echo "FOO"
        iwconfig wlan0 essid Seismo
	iwconfig wlan0 channel 13
	iwconfig wlan0 rate 1M
	iwconfig wlan0 frag off
	iwconfig wlan0 rts off
	iwconfig wlan0 ap $BSSID_B

        # WEP encryption for OLSR interfaces
        iwconfig wlan0 key s:olsrchan1

        ifconfig wlan0 $(get_ip_from_mac wlan0) netmask $NETMASK broadcast $BROADCAST
#        route del -net "$NETADDRESS"/$NET_SLASH wlan0

}


setup_ip () {
  echo "ifconfig $1 $(get_ip_from_mac $1) netmask $NETMASK broadcast $BROADCAST"
  ifconfig $1 $(get_ip_from_mac $1) netmask $NETMASK broadcast $BROADCAST
}


start () {
    setup_wlan0
	
    echo "Starting OLSR..."
    
    olsrd -f /media/card/etc/olsr_ews_wlan0.conf -nofork &
}

stop () {
        echo "Stopping OLSR..."
        killall olsrd
}

get_arch () {
  ARCH=`uname -m`
  echo $ARCH
}

case "$1" in
    start)
        ARCH=$(get_arch)
	case "$ARCH" in
	    "i586")
		setup_ip ath1
		rm -f /tmp/olsr_ews_ath1.conf
		cp $DIR/olsrd/olsr_ews_ath1.conf /tmp
#		olsrd -f /tmp/olsr_ews_ath1.conf -i ath1 -nofork &
		olsrd -f /tmp/olsr_ews_ath1.conf -nofork &
		;;
	    "mips")
		setup_ip ath0
		rm -f /tmp/olsr_ews_ath0.conf
		cp $DIR/olsrd/olsr_ews_ath0.conf /tmp
#		olsrd -f /tmp/olsr_ews_ath0.conf -i ath0 -nofork &
		olsrd -f /tmp/olsr_ews_ath0.conf -nofork &
		;;
	    "armv5tel")
		start
	        ;;
	    *)
		echo "Unknown arch: $ARCH"
		;;
        esac
        ;;
    stop)
        stop
        ;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0

