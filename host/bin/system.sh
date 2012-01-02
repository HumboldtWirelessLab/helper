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
		      run_on_node $node "if [ -f /sbin/reboot ]; then /sbin/reboot; else reboot; fi" "/" $DIR/../etc/keys/id_dsa
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

		    SSH_RUNNING=`nmap --host-timeout 2s -p22 $node 2>/dev/null | grep 22 | grep tcp | awk '{print $2}'`
		    while [ "x$SSH_RUNNING" != "xopen" ]; do
			sleep 5;
			SSH_RUNNING=`nmap --host-timeout 2s -p22 $node 2>/dev/null | grep 22 | grep tcp | awk '{print $2}'`
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
		    WNDR=""
		    while [ "x$WNDR" = "x" ]; do
			WNDR=`run_on_node $node "cat /proc/cpuinfo | grep 'WNDR' | wc -l" "/" $DIR/../etc/keys/id_dsa`
			if [ "x$WNDR" = "x" ]; then
			    sleep 1
			fi
		    done
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

		FILE=$DIR/../../nodes/lib/standalone/node_check.sh TARGETDIR=/tmp NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh scp_remote

		for node in $NODELIST; do
		  
		  START_TEST="0 0 0"
		  
		  while [ "$START_TEST" != "$node 1 1" ]; do
		    run_on_node $node "./node_check.sh start &" "/tmp" $DIR/../etc/keys/id_dsa
		    START_TEST=`NODELIST="$NODELIST" $0 test_node_check`
		    echo "$START_TEST"
		  done

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
		    echo "$node $PID_EX $PROC_EX"
		done
		;;
	"reset_driver")
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
		    run_on_node $node "if [ -f /tmp/brn_driver ]; then rm -f /tmp/brn_driver; fi" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
