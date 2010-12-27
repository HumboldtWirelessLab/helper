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

case "$1" in
    "responsible")
		#check whether ath_pci.ko exists. if so, then his script is responsible 
                KERNELVERSION=`uname -r`
                NODEARCH=`$DIR/../../bin/system.sh get_arch`
		
                FINMODULSDIR=`echo $MODULSDIR | sed -e "s#KERNELVERSION#$KERNELVERSION#g" -e "s#NODEARCH#$NODEARCH#g"`
#                echo "$MODULSDIR <--> $FINMODULSDIR"
		if [ -f ${FINMODULSDIR}/ath9k.ko ] || [ -f ${FINMODULSDIR}/ath5k.ko ]; then
#		    echo "i'm resp"
		    exit 0
		else
#		    echo "i'm not resp"
		    exit 1
		fi
		;;
    "install")
                . $DIR/../../etc/wifi/default

		if [ "x$MODOPTIONS" = "x" ]; then
			MODOPTIONS=$DEFAULT_RECOMMENDMODOPTIONS
		fi
		if [ "x$MODOPTIONS" = "x" ]; then
			. $DIR/../../etc/madwifi/modoptions.default
		else
			if [ -e $MODOPTIONS ]; then
			. $MODOPTIONS
			else
			if [ -e ../etc/madwifi/$MODOPTIONS ]; then
			  . $DIR/../../etc/madwifi/$MODOPTIONS
			else
				echo "Modoptionsfile $MODOPTIONS doesn't exist ! Use default"
				. $DIR/../../etc/madwifi/modoptions.default
			fi
			fi
		fi
		
                KERNELVERSION=`uname -r`
                NODEARCH=`$DIR/../../bin/system.sh get_arch`
		
                FINMODULSDIR=`echo $MODULSDIR | sed -e "s#KERNELVERSION#$KERNELVERSION#g" -e "s#NODEARCH#$NODEARCH#g"`
#                echo "Use $FINMODULSDIR"
			
		MODLIST="cfg80211.ko mac80211.ko ath.ko ath9k_hw.ko ath9k_common.ko ath9k.ko ath5k.ko"
		for mod in $MODLIST
		do
			if [ -f ${FINMODULSDIR}/$mod ]; then
			echo "insmod $mod"
			insmod ${FINMODULSDIR}/$mod
			fi
		done
		;;
    "uninstall")
		MODLIST="ath9k ath5k ath9k_common ath9k_hw ath mac80211 cfg80211 wlan_xauth wlan_wep wlan_tkip wlan_scan_ap wlan_scan_sta wlan_ccmp wlan_acl ath_pci ath_rate_sample ath_rate_minstrel wlan ath_hal hostap_pci hostap ieee80211_crypt "
		
		for mod in $MODLIST
		do
			MOD_EX=`lsmod | grep $mod | wc -l`

			if [ ! $MOD_EX = 0 ]; then
			echo "rmmod $mod"
			rmmod $mod
			fi

		done
		;;
    *)
		echo "unknown options"
		;;
esac

exit 0
