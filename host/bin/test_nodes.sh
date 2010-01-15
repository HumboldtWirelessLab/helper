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

if [ "x$1" = "x" ]; then
    echo "Use $0 nodefile"
    exit 0
fi

if [ "x$1" = "xall" ]; then
  echo "Node Ping SSH"
  N=1
  while [ $N -lt 110 ]; do
 
    RESULT=`ping -c 2 wgt$N 2>&1 | grep trans | awk '{print $4}'`
  
    echo -n "wgt$N "
  
    if [ "x$RESULT" = "x" ]; then
      echo "unknown"
    else
      if [ $RESULT -eq 0 ]; then
  	echo "no"
	echo "wgt$N no no"
      else
	echo -n "yes"
	DIR=`echo -n | ssh -i $DIR/../etc/keys/id_dsa root@wgt$N pwd 2>&1`
	if [ "x$DIR" = "x" ]; then
	  echo " SSH not(!!) available"
	  echo "wgt$N yes no"
	else
	    if [ "$DIR" = "/root" ]; then
	        echo " SSH available"
		echo "wgt$N yes yes"
	    else
		echo " SSH not(!!) available"
		echo "wgt$N yes no"
	    fi
	fi
      fi
    fi

    N=`expr $N + 1` 
  done
else
  NODES=`cat $1 | grep -v "#" | awk '{print $1}' | sort -u`
  
  for i in $NODES; do
    RESULT=`ping -c 2 $i 2>&1 | grep trans | awk '{print $4}'`
  
    echo -n "$i "
  
    if [ "x$RESULT" = "x" ]; then
      echo "unknown"
    else
      if [ $RESULT -eq 0 ]; then
  	echo "no"
	echo "$i no no"
      else
	echo -n "yes"
	LSDIR=`echo -n | ssh -i $DIR/../etc/keys/id_dsa root@$i pwd 2>&1`
	if [ "x$LSDIR" = "x" ]; then
	  echo " SSH not(!!) available"
	  echo "$i yes no"
	else
	    if [ "$LSDIR" = "/root" ] || [ "$LSDIR" = "/rw/root" ]; then
	        echo " SSH available"
		echo "$i yes yes"
	    else
		echo " SSH not(!!) available"
		echo "$i yes no"
	    fi
	fi
      fi
    fi
  done
fi
