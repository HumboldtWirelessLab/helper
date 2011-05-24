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
			ALREADY_MOUNTED=`run_on_node $node "mount | grep $NFSHOME | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`
			echo "Check mount ($NFSHOME). Result: ->$ALREADY_MOUNTED<-"
			if [ "x$ALREADY_MOUNTED" = "x0" ]; then
			    if [ "x$NFSOPTIONS" = "x" ]; then
				NFSOPTIONS="nolock,soft,vers=2,proto=udp,wsize=16384,rsize=16384"
			    fi
			    run_on_node $node "mkdir -p $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			    run_on_node $node "if [ -f /sbin/mount ]; then /sbin/mount -t nfs -o $NFSOPTIONS $NFSSERVER:$NFSHOME $NFSHOME; else mount -t nfs -o $NFSOPTIONS $NFSSERVER:$NFSHOME $NFSHOME; fi" "/" $DIR/../etc/keys/id_dsa
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

		    	ALREADY_MOUNTED=`run_on_node $node "mount | grep $EXTRANFS | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`
			if [ "x$ALREADY_MOUNTED" = "x0" ]; then
			    if [ "x$NFSOPTIONS" = "x" ]; then
				NFSOPTIONS="nolock,soft,vers=2,proto=udp,wsize=16384,rsize=16384"
			    fi
			    run_on_node $node "mkdir -p $EXTRANFSTARGET" "/" $DIR/../etc/keys/id_dsa
			    run_on_node $node "if [ -f /sbin/mount ]; then /sbin/mount -t nfs -o $NFSOPTIONS $EXTRANFSSERVER:$EXTRANFS $EXTRANFSTARGET; else mount -t nfs -o $NFSOPTIONS $EXTRANFSSERVER:$EXTRANFS $EXTRANFSTARGET; fi" "/" $DIR/../etc/keys/id_dsa
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
			ALREADY_MOUNTED=`run_on_node $node "mount | grep $NFSHOME | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`

			if [ "x$ALREADY_MOUNTED" != "x0" ]; then
			  echo "$NFSHOME already mounted. Umount to clean everything and to save space"
			  run_on_node $node "umount $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			fi

			run_on_node $node "mkdir -p $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			
			MOUNTED_SUCC=0;
			
			while [ "x$MOUNTED_SUCC" == "x0" ]; do

			  if [ "x$MOUNTED_SUCC" != "x0" ]; then
			    echo "$NFSHOME mounted successfull"
			  else
			    run_on_node $node "mount -t tmpfs none $NFSHOME" "/" $DIR/../etc/keys/id_dsa
			  fi

			  MOUNTED_SUCC=`run_on_node $node "mount | grep $NFSHOME | wc -l" "/" $DIR/../etc/keys/id_dsa | awk '{print $1}'`

			done

		    else
			echo "TMPHOME not set, so no mount."
		    fi
		done
		;;
	"scp_remote")
		for node in $NODELIST; do
		    echo "$node"
		    MD5SUM=`md5sum $FILE | awk '{print $1}'`
		    SCP_SUCC=0
		    FILEBASENAME=`basename $FILE`

		    while [ $SCP_SUCC -eq 0 ]; do
		      echo "scp -i $DIR/../etc/keys/id_dsa $FILE root@$node:$TARGETDIR"
		      scp -i $DIR/../etc/keys/id_dsa $FILE root@$node:$TARGETDIR
		      sleep 1
		      REMOTEMD5SUM=$(run_on_node $node "export PATH=\$PATH:/bin:/sbin/:/usr/bin:/usr/sbin; md5sum $TARGETDIR/$FILEBASENAME" "/" $DIR/../etc/keys/id_dsa)
		      REMOTEMD5SUM=`echo $REMOTEMD5SUM | awk '{print $1}'`
		      echo "MD5SUM: $MD5SUM REMOTE: $REMOTEMD5SUM"
		      if [ "x$REMOTEMD5SUM" == "x$MD5SUM" ]; then
		        SCP_SUCC=1
		      fi
		    done
		done
		;;
	"scp_check")
		RESULT=1;
		for node in $NODELIST; do
		    NODERESULT=`run_on_node $node "ls $TARGETDIR/$FILE 2> /dev/null" "/" $DIR/../etc/keys/id_dsa | wc -l`
		    if [ $NODERESULT -eq 0 ]; then
		      RESULT=`expr $RESULT + 1`
		    fi
		done
		
		echo $RESULT
		;;
	"unpack_remote")
		FINALFILE=`bzcat $TARGETDIR/$FILENAME | tar -t | tail -n 1`
		echo "Testfile is $FINALFILE"
 
		for node in $NODELIST; do
		    FILENAME=`basename $FILE`
		    SUCC_UNPACK=0
		    
		    while [ "x$SUCC_UNPACK" == "x0" ]; do
		      echo "bzcat $TARGETDIR/$FILENAME | tar xvf -"
		      run_on_node $node "export PATH=\$PATH:/bin:/sbin/:/usr/bin:/usr/sbin; bzcat $TARGETDIR/$FILENAME | tar xvf -" "/" $DIR/../etc/keys/id_dsa
		      SUCC_UNPACK=`run_on_node $node "export PATH=\$PATH:/bin:/sbin/:/usr/bin:/usr/sbin; ls $FINALFILE 2> /dev/null" "/" $DIR/../etc/keys/id_dsa`
		      SUCC_UNPACK=`echo $SUCC_UNPACK | wc -l`
		    done
		    echo "Unpack successful"
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
