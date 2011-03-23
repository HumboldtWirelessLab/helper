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
		echo "Use $0 mount | watchdogstart | status"
		echo "Use NODELIST"
		;;
	"mount")
		for node in $NODELIST; do
		    echo "$node"

		    ENVIRONMENTFILE=`cat $DIR/../../nodes/etc/environment/nodesenvironment.conf | grep "^$node" | awk '{print $2}'`
		    if [ -f $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE ]; then
			. $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE
		    fi

		    if [ "x$NFSOPTIONS" = "x" ]; then
			. $DIR/../../nodes/etc/environment/default.env
		    fi

		    if [ ! "x$NFSHOME" = "x" ]; then
			ALREADY_MOUNTED=`run_on_node $node "mount | grep $NFSHOME | wc -l" "/" $DIR/../etc/keys/id_dsa`
			if [ "x$ALREADY_MOUNTED" = "x0" ] ; then

			    if [ "x$NFSOPTIONS" = "x" ]; then
				NFSOPTIONS="nolock,soft,vers=2,proto=udp,wsize=16384,rsize=16384"
			    fi
			    run_on_node $node "mkdir -p $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			    run_on_node $node "mount -t nfs -o $NFSOPTIONS $NFSSERVER:$NFSHOME $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			else
			  echo "$NFSHOME already mounted"
			fi
		    else
			echo "NFSHOME not set, so no mount."
		    fi
		done
		;;
	"extramount")
		for node in $NODELIST; do
		    echo "EXTRAMOUNT: $node"

		    ENVIRONMENTFILE=`cat $DIR/../../nodes/etc/environment/nodesenvironment.conf | grep "^$node" | awk '{print $2}'`
		    if [ -f $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE ]; then
			. $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE
		    fi

		    if [ "x$NFSOPTIONS" = "x" ]; then
			. $DIR/../../nodes/etc/environment/default.env
		    fi

		    echo "$EXTRANFS;$EXTRANFSTARGET;$EXTRANFSSERVER"

		    if [ ! "x$EXTRANFS" = "x" ] && [ ! "x$EXTRANFSTARGET" = "x" ] &&  [ ! "x$EXTRANFSSERVER" = "x" ]; then
		     
		    	ALREADY_MOUNTED=`run_on_node $node "mount | grep $EXTRANFS | wc -l" "/" $DIR/../etc/keys/id_dsa`
			if [ "x$ALREADY_MOUNTED" != "x0" ] ; then

			    if [ "x$NFSOPTIONS" = "x" ]; then
				NFSOPTIONS="nolock,soft,vers=2,proto=udp,wsize=16384,rsize=16384"
			    fi
			    run_on_node $node "mkdir -p $EXTRANFSTARGET" "/" $DIR/../etc/keys/id_dsa
			    run_on_node $node "mount -t nfs -o $NFSOPTIONS $EXTRANFSSERVER:$EXTRANFS $EXTRANFSTARGET" "/" $DIR/../etc/keys/id_dsa
			else
			    echo "$EXTRANFS already mounted"
			fi
		    else
			echo "NFSHOME not set, so no mount."
		    fi
		done
		;;
	"mounttmpfs")
		for node in $NODELIST; do
		    echo "$node"

		    ENVIRONMENTFILE=`cat $DIR/../../nodes/etc/environment/nodesenvironment.conf | grep "^$node" | awk '{print $2}'`
		    if [ -f $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE ]; then
			. $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE
		    fi

		    if [ "x$NFSOPTIONS" = "x" ]; then
			. $DIR/../../nodes/etc/environment/default.env
		    fi

		    if [ ! "x$NFSHOME" = "x" ]; then
			ALREADY_MOUNTED=`run_on_node $node "mount | grep $NFSHOME | wc -l" "/" $DIR/../etc/keys/id_dsa`
			if [ "x$ALREADY_MOUNTED" = "x0" ] ; then
			  run_on_node $node "mkdir -p $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			  run_on_node $node "mount -t tmpfs none $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			else
			  echo "$NFSHOME already mounted"
			fi
		    else
			echo "TMPHOME not set, so no mount."
		    fi
		done
		;;
	"scp_remote")
		for node in $NODELIST; do
		    echo "$node"
		    echo "scp -i $DIR/../etc/keys/id_dsa $FILE root@$node:$TARGETDIR"
		    scp -i $DIR/../etc/keys/id_dsa $FILE root@$node:$TARGETDIR
		done
		;;
	"unpack_remote")
		for node in $NODELIST; do
		    FILENAME=`basename $FILE`
		    echo "bzcat $TARGETDIR/$FILENAME | tar xvf -"
		    run_on_node $node "export PATH=\$PATH:/bin:/sbin/:/usr/bin:/usr/sbin; bzcat $TARGETDIR/$FILENAME | tar xvf -" "/" $DIR/../etc/keys/id_dsa
		done
		;;		
	"watchdogstart")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "/etc/init.d/watchdog start" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"settime")
		for node in $NODELIST; do
		    echo "Set time on $node."
		    run_on_node $node "$DIR/../../nodes/bin/time.sh settime" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
