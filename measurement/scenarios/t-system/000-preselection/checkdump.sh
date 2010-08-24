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

. $DIR/config

case "$1" in
  "test")
    echo "Testdump"
    if [ -e $RESULTDIR/devel.ath0.dump ]; then
      echo "Dumpfile exist"
    else
      echo "No Dumpfile"
      exit 0;
    fi

    DUMPSIZE=`ls -lisa $RESULTDIR/devel.ath0.dump | awk '{print $7}'`
    if [ $DUMPSIZE -gt 0 ]; then
       echo "Dumpfile size ok."
     else
       echo "Dumpfile too small"
       exit 0;
    fi

    (cd $RESULTDIR; /home/testbed/click-brn/userlevel/click $DIR/checkdump.click > testresult.log 2>&1)
    
    STARTTIME=`cat $RESULTDIR/testresult.log | head -n 1 | sed "s#\.# #g" | awk '{print $2}'`
    ENDTIME=`cat $RESULTDIR/testresult.log | tail -n 1 | sed "s#\.# #g" | awk '{print $2}'`
    DURATION=`expr $ENDTIME - $STARTTIME`
    
    TESTDURATION=`expr $DURATION + 5`
    if [ $TESTDURATION -gt $RUNTIME ]; then
      echo "Duration ok";
    else
      echo "Duration not ok"
      exit 0
    fi
    ;;
esac
