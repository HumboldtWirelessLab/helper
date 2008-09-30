#!/bin/sh

case "$1" in
    "install")
	MODLIST="proclikefs.ko click.ko"
	
	mkdir /tmp/click
	
	for mod in $MODLIST
	do
	    if [ -f ${MODULSDIR}/$mod ]; then
		echo "insmod $mod"
		insmod ${MODULSDIR}/$mod
	    fi
	done
	
	mount -t click none /tmp/click
	
	;;
    "uninstall")
	MODLIST="click proclikefs"
    
	umount /tmp/click
	rm -rf /tmp/click
	
	for mod in $MODLIST
	do
	    MOD_EX=`lsmod | grep $mod | wc -l`

	    if [ ! $MOD_EX = 0 ]; then
		echo "rmmod $mod"
		rmmod $mod
	    fi
	done
	;;
    "reinstall")
	MODULSDIR=$MODULSDIR $0 uninstall
	MODULSDIR=$MODULSDIR $0 install
	;;
    *)
	echo "unknown options"
	;;
esac

exit 0
