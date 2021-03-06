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

. $DIR/../../measurement/etc/wifitypes

case "$1" in
	"help")
		echo "Use $0 convert des-file"
		;;
	"convert")
	  . $2

	  NONODES=`cat $NODEPLACEMENTFILE | wc -l`

	  echo "sim.duration = $TIME"
    echo "sim.nonodes = $NONODES"
    echo -n "radio.placementopts = ";
    NODE=1
    MAX_X=0
    MAX_Y=0
    while read line; do
      X=`echo $line | awk '{print $2}'`
      Y=`echo $line | awk '{print $3}'`
      if [ $NODE -ne 1 ]; then
        echo -n ":$X,$Y"
      else
        echo -n "$X,$Y"
      fi
      NODE=`expr $NODE + 1`
      if [ $X -gt $MAX_X ]; then
        MAX_X=$X
      fi
      if [ $Y -gt $MAX_Y ]; then
        MAX_Y=$Y
      fi
    done < $NODEPLACEMENTFILE

    #linebreak at the end
    echo ""

    echo "field.size.x = $POS_X_MAX"
    echo "field.size.y = $POS_Y_MAX"

    NODE=1
		while read line; do
		  NODENAME=`echo $line | awk '{print $1}'`
		  NODEDEVICE=`echo $line | awk '{print $2}'`
		  NODECONFIG=`echo $line | awk '{print $5}'`
		  NODECLICK=`echo $line | awk '{print $7}'`


		  if [ ! -f $NODECONFIG ]; then
		    if [ -f $DIR/../../nodes/etc/wifi/$NODECONFIG ]; then
                      NODECONFIG="$DIR/../../nodes/etc/wifi/$NODECONFIG"
		    else
		      if [ -f ./$NODECONFIG ]; then
		        NODECONFIG=./$NODECONFIG
                      else
			if [ -f $CONFIGDIR/$NODECONFIG ]; then
			  NODECONFIG=$CONFIGDIR/$NODECONFIG
			else
		          NODECONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
                        fi
		      fi
		    fi
		  fi

		  #TODO: fix this
		  if [ -f ./$NODECONFIG ]; then
                    NODECONFIG=./$NODECONFIG
                  fi

		  . $NODECONFIG

		  echo "node.$NODE.name = $NODENAME"
		  echo "node.$NODE.device = $NODEDEVICE"
		  echo "node.$NODE.config = $NODENAME"
		  echo "node.$NODE.click = $NODECLICK"

#TODO: don't force to use extra encap
		  WIFITYPE=$WIFITYPE_EXTRA

		  if [ "x$WIFITYPE" = "x" ]; then
		    echo "node.$NODE.wifitype = $WIFITYPE_EXTRA"
		  else
		    echo "node.$NODE.wifitype = $WIFITYPE"
		  fi

		  NODE=`expr $NODE + 1`

		done < $NODETABLE
		;;
	*)
		$0 help
		;;
esac

exit 0
