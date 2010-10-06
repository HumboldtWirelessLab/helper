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

if [ "x$VERSION" = "x" ]; then
  VERSION="c"
fi

case "$VERSION" in
  "c")
    IP=$2
    PORT=$3

    ELEMENT=$4
    HANDLER=$5

    shift 5

    if [ "x$1" = "xwrite" ]; then
	$DIR/click_ctrl $IP $PORT $ELEMENT $HANDLER "$@" &
    else
	$DIR/click_ctrl $IP $PORT $ELEMENT $HANDLER "$@"
    fi

  ;;
  "java")
    java -jar $DIR/JClickClient.jar $@
  ;;
  "shell")
    #TODO: Timeout of 1 sec is used. Try to remove
    NETCAT="nc -w 1 $2 $3"

    if [ "x$1" = "xwrite" ]; then
      ELEMENT=$4
      HANDLER=$5
      shift 5
      echo "write $ELEMENT.$HANDLER $@" | $NETCAT | sed '1,3d'
    else
      if [ "x$1" = "xread" ]; then
        echo "read $4.$5" | $NETCAT | sed '1,3d'
      else
        echo "Unknown commend"
        exit 0
      fi
    fi
  ;;
esac

exit 0
