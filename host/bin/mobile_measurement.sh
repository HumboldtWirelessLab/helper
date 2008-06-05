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

. $DIR/functions.sh

if [ "x$NODELIST" = "x" ]; then
    ls  $DIR/../etc/nodegroups/
fi

case "$1" in
	"help")
		echo "Use $0 setup"
		echo "Use NODELIS"
		;;
	"setup")
		ssh root@127.0.0.1 "ifdown eth0"
		ssh root@127.0.0.1 "ifconfig eth0 up"
		ssh root@127.0.0.1 "ifconfig eth0:1 192.168.4.3 up"
		ssh root@127.0.0.1 "/etc/init.d/arno-iptables-firewall stop"
		ssh root@127.0.0.1 "/etc/init.d/nfs-kernel-server restart"		
		;;
	"stop")
		ssh root@127.0.0.1 "ifconfig eth0 down"
		ssh root@127.0.0.1 "/etc/init.d/arno-iptables-firewall start"
		ssh root@127.0.0.1 "/etc/init.d/nfs-kernel-server restart"
		;;
	*)
		$0 help
		;;
esac

exit 0		
