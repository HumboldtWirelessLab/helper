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

if [ "x$1" != "xstart_node_check" ] && [ "x$1" != "xtest_node_check" ]; then
  if [ "x$NODELIST" = "x" ]; then
    ls  $DIR/../etc/nodegroups/
  fi
fi

case "$1" in
	"help")
		echo "Use $0 reboot | status"
		echo "Use NODELIST"
		;;
	"reboot")
		for node in $NODELIST; do
		    echo -n "$node: "
		    DENYREBOOT=`cat $DIR/../etc/reboot.deny | grep -e "^$node$" | wc -l`
		    if [ $DENYREBOOT -eq 1 ]; then
		      echo "Reboot not allowed !"
		    else
		      echo "Reboot"
		      run_on_node $node "reboot" "/" $DIR/../etc/keys/id_dsa
		    fi  
		done
		;;
	"status")	
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "uptime" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"waitfornodes")
		for node in $NODELIST; do
		    echo "$node"
		    AVAILABLE=`node_available $node`
		    while [ $AVAILABLE = "n" ]; do
			sleep 1;
			AVAILABLE=`node_available $node`
		    done
		done
		;;	    
	"waitfornodesandssh")
		for node in $NODELIST; do
		
		    AVAILABLE=`node_available $node`
		    while [ $AVAILABLE = "n" ]; do
			sleep 5;
			AVAILABLE=`node_available $node`
		    done

		    ARCH=`run_on_node $node "uname -m" "/" $DIR/../etc/keys/id_dsa 2> /dev/null`
		    while [ "x$ARCH" = "x" ]; do
 			sleep 10;
			ARCH=`run_on_node $node "uname -m" "/" $DIR/../etc/keys/id_dsa 2> /dev/null`
		    done

		done
		;;
	"nodeinfo")	
		for node in $NODELIST; do
		    WNDR=`run_on_node $node "cat /proc/cpuinfo | grep 'WNDR' | wc -l" "/" $DIR/../etc/keys/id_dsa | grep "WNDR" | wc -l`
		    if [ $WNDR -gt 0 ]; then
		      ARCH="mips-wndr3700"
		    else
		      ARCH=`run_on_node $node "uname -m" "/" $DIR/../etc/keys/id_dsa`
		    fi
		    KERNEL=`run_on_node $node "uname -r" "/" $DIR/../etc/keys/id_dsa`
		    echo "$node $ARCH $KERNEL"
		done
		;;
	"backbone")	
		for node in $NODELIST; do
		    if [ "$node" = "localhost" ]; then
		      echo "$node wired"
		    fi

		    DEFAULT=`run_on_node $node "/sbin/route -n 2>&1 | grep '^0.0.0.0' | grep '192.168.3'" "/" $DIR/../etc/keys/id_dsa | awk '{print $8}'`

		    if [ "x$DEFAULT" = "xeth0" ]; then 
		      echo "$node wired"
		    else
		      echo "$node wireless"
		    fi
		done
		;;
	"olsrbackbone")	
		for node in $NODELIST; do
		    OLSRD=`run_on_node $node "ps | grep olsrd | grep -v grep" "/" $DIR/../etc/keys/id_dsa | wc -l`
		    
		    if [ "x$OLSRD" = "x0" ]; then 
		      echo "no"
		    else
		      echo "yes"
		    fi
		done
		;;
	"start_node_check")
		if [ "x$NODELIST" = "x" ]; then
		  if [ "x$2" = "x" ]; then
		    exit 0
		  else
		    if [ ! -f $2 ]; then
		      exit 0
		    else
		      NODELIST=`cat $2 | grep -v "#" | awk '{print $1}'`
		    fi
	          fi
	        fi

		for node in $NODELIST; do
		    scp -i $DIR/../etc/keys/id_dsa $DIR/../../nodes/lib/standalone/node_check.sh root@$node:/tmp/
		    START_RESULT=`run_on_node $node "./node_check.sh start &" "/tmp" $DIR/../etc/keys/id_dsa`
		    echo "$node $START_RESULT"
		done
		;;
	"test_node_check")
		if [ "x$NODELIST" = "x" ]; then
		  if [ "x$2" = "x" ]; then
		    exit 0
		  else
		    if [ ! -f $2 ]; then
		      exit 0
		    else
		      NODELIST=`cat $2 | grep -v "#" | awk '{print $1}'`
		    fi
	          fi
	        fi

		for node in $NODELIST; do
		    PID_EX=`run_on_node $node "ls /tmp/run/node_check.pid 2> /dev/null | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`
		    PROC_EX=`run_on_node $node "ps | grep node_check | grep -v grep 2> /dev/null | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`
		    echo "$node $PID_EX $PROC_EX "
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
