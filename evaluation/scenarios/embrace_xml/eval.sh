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

. $CONFIGFILE

echo "<$NAME>" > $EVALUATIONSDIR/measurement.xml

if [ "x$MODE" = "xsim" ]; then
  if [ -f $RESULTDIR/measurement.log ]; then
    cat $RESULTDIR/measurement.log | grep -e "^[[:space:]]*<" >> $EVALUATIONSDIR/measurement.xml
    if [ "x$EVALUATION_LEVEL" != "x" ]; then
      cat $RESULTDIR/measurement.log | grep -v "^[[:space:]]*<" > $EVALUATIONSDIR/measurement_debug.log
    fi
  else
    if [ -f $RESULTDIR/measurement.log.bz2 ]; then
      bzcat $RESULTDIR/measurement.log.bz2 | grep -e "^[[:space:]]*<" >> $EVALUATIONSDIR/measurement.xml
      if [ "x$EVALUATION_LEVEL" != "x" ]; then
        cat $RESULTDIR/measurement.log.bz2 | grep -v "^[[:space:]]*<" > $EVALUATIONSDIR/measurement_debug.log
      fi
    fi
  fi


else
  cat $NODETABLE | awk '{print $8}' | sed -e "s/^-$//g" | xargs cat 2> /dev/null | grep -e "^[[:space:]]*<" >> $EVALUATIONSDIR/measurement.xml 2> /dev/null
  if [ "x$EVALUATION_LEVEL" != "x" ]; then
    cat $NODETABLE | awk '{print $8}' | sed -e "s/^-$//g" | xargs cat 2> /dev/null | grep -v -e "^[[:space:]]*<" > $EVALUATIONSDIR/measurement_debug.log 2> /dev/null
  fi
fi

echo "</$NAME>" >> $EVALUATIONSDIR/measurement.xml

exit 0

