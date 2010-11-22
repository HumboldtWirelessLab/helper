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


if [ "x$1" = "xhelp" ]; then
    echo "Use $0 PREFIX MEASUREMENTCONFIG NODECONFIG"
    exit 0
fi

if [ "x$1" = "x" ]; then
    MPREFIX=004
else
    MPREFIX=00$1
fi


DURATION=20
STARTTIME=60
MIDDURATION=40
ENDDURATION=60

MAXNODES=43

if [ "x$3" != "x" ]; then
  if [ -f $3 ]; then
    . $3
  fi
fi

if [ "x$2" = "x" ]; then
  echo "no measurement file"
  exit 1
fi

CONFIGFILE=$2

CONFIGS=`cat $CONFIGFILE | grep -v "#" | awk '{print $1}' | uniq`

for i in $CONFIGS; do
    LINE=`cat $CONFIGFILE | grep -v "#" | grep $i | head -n 1`

    FT=`echo $LINE | awk '{print $2}'`
    FTSIZE=`echo $LINE | awk '{print $3}'`
    FTINTERVAL=`echo $LINE | awk '{print $4}'`
    FTBURST=`echo $LINE | awk '{print $5}'`
    FTRATE=`echo $LINE | awk '{print $6}'`
    FTCCA=`echo $LINE | awk '{print $7}'`

    cat foreign_node.click.tmpl | sed "s#SIZE VARSIZE#SIZE $FTSIZE#g" | sed "s#INTERVAL VARINTERVAL#INTERVAL $FTINTERVAL#g" | sed "s#BURST VARBURST#BURST $FTBURST#g" | sed "s#RATE VARRATE#RATE $FTRATE#g" > foreign_node.click

    if [ ! -e $MPREFIX-$i ]; then
	echo "Running $i: Foreign traffic: $FT NOCCA: $FTCCA"
	FT=$FT CCA=$FTCCA ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION
	cp ./foreign_node.click ./1
	mv 1 $MPREFIX-$i
    fi

    rm foreign_node.click

done

exit 0
