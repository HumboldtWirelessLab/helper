#!/bin/sh

RESULTDIR=$1
EVALSCRIPT=$2
EVALRESULTDIR=$3
ONLINESCRIPT=$4
MEASUREMENTNAME=$5

mkdir $EVALRESULTDIR

if [ "x$WAITTIME" = "x" ]; then
    WAITTIME=60
fi

DIRS=""

while [ ! -f $STOPMARKER ]; do

    sleep $WAITTIME    

    NEWDIR=`(cd $RESULTDIR; ls)`
    
    for d in $NEWDIR; do
	DIRCOMPLETE=`echo $DIRS | grep ";$d;" | wc -l`
      
	if [ $DIRCOMPLETE -eq 0 ]; then
	    DIRS="$DIRS;$d;"
	    echo "DIR: $d"
	    sleep $WAITTIME
	    $EVALSCRIPT $RESULTDIR/$d $EVALRESULTDIR
            $ONLINESCRIPT $EVALRESULTDIR $MEASUREMENTNAME $d
	fi
    done
done

exit 0
