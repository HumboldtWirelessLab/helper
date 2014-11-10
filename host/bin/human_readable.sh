#!/bin/bash

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


if [ "x$1" != "x" ]; then
  FILE=$1
else
  if [ -f $PWD/nodes.mac ]; then
    FILE=$pwd/nodes.mac
  else
    if [ -f $dir/../etc/nodes.mac ]; then
      FILE=$dir/../etc/nodes.mac
    else
      FILE=""
    fi
  fi
fi

if [ "x$FILE" = "x" ]; then
  exit 1
fi

if [ "x$MAC2NUM" = "x1" ]; then
  SEDARG=`$DIR/generate_sedargs.py --nodesmacfile=$FILE --mode=mac2id`
  SEDARG="sed $SEDARG -e \"s#FF-FF-FF-FF-FF-FF#65535#g\""
elif [ "x$NAME2NUM" = "x1" ]; then
  SEDARG=`$DIR/generate_sedargs.py --nodesmacfile=$FILE --mode=name2id`
  SEDARG="sed $SEDARG -e \"s#Broadcast#65535#g\""
elif [ "x$MAC2NAME" = "x1" ]; then
  SEDARG=`$DIR/generate_sedargs.py --nodesmacfile=$FILE --mode=mac2name`
  SEDARG="sed $SEDARG -e \"s#FF-FF-FF-FF-FF-FF#Broadcast#g\""
elif [ "x$NUM2MAC" = "x1" ]; then
  SEDARG=`$DIR/generate_sedargs.py --nodesmacfile=$FILE --mode=id2mac`
  SEDARG="sed $SEDARG -e \"s#65535#FF-FF-FF-FF-FF-FF#g\""
elif [ "x$NUM2NAME" = "x1" ]; then
  SEDARG=`$DIR/generate_sedargs.py --nodesmacfile=$FILE --mode=id2name`
  SEDARG="sed $SEDARG -e \"s#65535#Broadcast#g\""
else
  echo "$0: Unknown mode!"
  exit 1
fi

eval $SEDARG
