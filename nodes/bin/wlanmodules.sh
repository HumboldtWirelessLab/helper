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
    "install")
    	. $DIR/../../nodes/etc/wifi/default

		if [ "x$MODOPTIONS" = "x" ]; then
			MODOPTIONS=$DEFAULT_RECOMMENDMODOPTIONS
		fi
		if [ "x$MODOPTIONS" = "x" ]; then
			. ../etc/madwifi/modoptions.default
		else
			if [ -e $MODOPTIONS ]; then
			. $MODOPTIONS
			else
			if [ -e ../etc/madwifi/$MODOPTIONS ]; then
			  . ../etc/madwifi/$MODOPTIONS
			else
				echo "Modoptionsfile $MODOPTIONS doesn't exist ! Use default"
				. ../etc/madwifi/modoptions.default
			fi
			fi
		fi
		
		MODLIST="ath_hal.ko wlan.ko ath_rate_sample.ko wlan_acl.ko wlan_ccmp.ko wlan_scan_ap.ko wlan_scan_sta.ko wlan_tkip.ko wlan_wep.ko wlan_xauth.ko"
		for mod in $MODLIST
		do
			if [ -f ${MODULSDIR}/$mod ]; then
			echo "insmod $mod"
			insmod ${MODULSDIR}/$mod
			fi
		done

		echo "insmod ath_pci $ATH_PCI"
		insmod ${MODULSDIR}/ath_pci.ko $ATH_PCI 
		;;
    "uninstall")
		MODLIST="ath5k ath wlan_xauth wlan_wep wlan_tkip wlan_scan_ap wlan_scan_sta wlan_ccmp wlan_acl ath_pci ath_rate_sample ath_rate_minstrel wlan ath_hal hostap_pci hostap ieee80211_crypt "
		
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
