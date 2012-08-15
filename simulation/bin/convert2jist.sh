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

    if [ -f $DIR/../etc/ns/distances/$RADIO ]; then
      . $DIR/../etc/ns/distances/$RADIO
      if [ "x$FIELDSIZE" = "xRXRANGE" ]; then
        FIELDSIZE=$RXRANGE
      fi
    fi

    echo ""
    FIELDSIZE=`expr $FIELDSIZE + 1`
    
    if [ $FIELDSIZE -lt $MAX_X ]; then
      FIELDSIZE=$MAX_X
      FIELDSIZE=`expr $FIELDSIZE + 1`
    fi
    if [ $FIELDSIZE -lt $MAX_Y ]; then
      FIELDSIZE=$MAX_Y
      FIELDSIZE=`expr $FIELDSIZE + 1`
    fi
    
    echo "field.size.x = $FIELDSIZE"
    echo "field.size.y = $FIELDSIZE"

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
		        NODECONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
		      fi
		    fi
		  fi

		  . $NODECONFIG

		  echo "node.$NODE.name = $NODENAME"
		  echo "node.$NODE.device = $NODEDEVICE"
		  echo "node.$NODE.config = $NODENAME"
		  echo "node.$NODE.click = $NODECLICK"

		  WIFITYPE=802

		  if [ "x$WIFITYPE" = "x" ]; then
		    echo "node.$NODE.wifitype = 806"
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
