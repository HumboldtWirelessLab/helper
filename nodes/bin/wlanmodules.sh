#!/bin/sh

case "$1" in
    "install")
	if [ "x$MODOPTIONS" = "x" ]; then
	    . ../etc/madwifi/modoptions.default
	else
	    . $MODOPTIONS
	fi
	
	echo insmod ath_hal
	insmod ${MODULSDIR}/ath_hal.ko
	echo insmod wlan
	insmod ${MODULSDIR}/wlan.ko
	echo insmod ath_rate_sample
	insmod ${MODULSDIR}/ath_rate_sample.ko

	insmod ${MODULSDIR}/wlan_acl.ko
	insmod ${MODULSDIR}/wlan_ccmp.ko
	insmod ${MODULSDIR}/wlan_scan_ap.ko
	insmod ${MODULSDIR}/wlan_scan_sta.ko
	insmod ${MODULSDIR}/wlan_tkip.ko
	insmod ${MODULSDIR}/wlan_wep.ko
	insmod ${MODULSDIR}/wlan_xauth.ko

	echo insmod ath_pci $ATH_PCI
	insmod ${MODULSDIR}/ath_pci.ko $ATH_PCI 
	;;
    "uninstall")
	MODLIST="wlan_xauth wlan_wep wlan_tkip wlan_scan_sta wlan_ccmp wlan_acl wlan_scan_ap ath_pci ath_rate_sample ath_rate_minstrel wlan ath_hal hostap_pci hostap ieee80211_crypt "
    
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
