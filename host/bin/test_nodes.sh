#!/bin/sh

if [ "x$1" = "x" ]; then
    echo "Use $0 outputfile"
    exit 0
fi

echo "Node Ping SSH" > $1
N=1
while [ $N -lt 110 ]; do

  RESULT=`ping -c 2 wgt$N 2>&1 | grep trans | awk '{print $4}'`
  
  echo -n "wgt$N "
  
  if [ "x$RESULT" = "x" ]; then
      echo "unknown"
  else
    if [ $RESULT -eq 0 ]; then
	echo "no"
	echo "wgt$N no no" >> $1
    else
	echo -n "yes"
	DIR=`echo -n | ssh -i ../etc/keys/id_dsa root@wgt$N pwd 2>&1`
	if [ "x$DIR" = "x" ]; then
	  echo " SSH not(!!) available"
	  echo "wgt$N yes no" >> $1
	else
	    if [ "$DIR" = "/root" ]; then
	        echo " SSH available"
		echo "wgt$N yes yes" >> $1
	    else
		echo " SSH not(!!) available"
		echo "wgt$N yes no" >> $1
	    fi
	fi
    fi
  fi

  N=`expr $N + 1` 
done