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

if [ "x$1" = "x" ]; then
    $0 help
    exit 0
fi

CONFIGS=0

recursive() {
  local VALUES=(${VALUEFIELD[$1]})
  local CURINDEX=0;
  local NEXT=`expr $1 - 1`
  local SEDARG=""

  while [ $CURINDEX -lt ${#VALUES[@]} ]; do
    GLOBALINDEX[$1]=$CURINDEX
    
    if [ $1 -eq 0 ]; then
 
      rm -rf $MDIR.$CONFIGS
      mkdir $MDIR.$CONFIGS
      
      ALLDIRS="$ALLDIRS $MDIR.$CONFIGS"
      
      local i=0;
      while [ $i -lt ${#VARFIELD[@]} ]; do
        ACVALUE=(${VALUEFIELD[$i]})
        SEDARG="$SEDARG -e s#${VARFIELD[$i]}#${ACVALUE[${GLOBALINDEX[$i]}]}#g"
 
        echo "${VARFIELD[$i]}=${ACVALUE[${GLOBALINDEX[$i]}]}" >> $MDIR.$CONFIGS/config
 
        let "i = $i +1"
      done
      
      for acfile in  `ls $MDIR`; do
        local i=0;
        cat $MDIR/$acfile | sed $SEDARG > $MDIR.$CONFIGS/$acfile
      done
      
      SEDARG=""
      
      let "CONFIGS=$CONFIGS + 1"
           
    else
      recursive $NEXT
    fi
      
    let "CURINDEX = $CURINDEX +1"
  done
  
}

case "$1" in
    "help")
	echo "Use $0 collectionfile"
	echo "Skript to run measurement with different parameters (e.g. TXPOWER, CHANNEL,...). The collectionfile include the parameter and the name of the templatefiles (configfile with Vars as parameters)."
	;;
    "run")
	echo "Start Collection"
	MDIR=$3
	VARS=`cat $2 | sed -e "s#=# #g" | awk '{print $1}'`
	
	VARFIELD=($VARS)
	
	. $2
	
	i=0
	for v in $VARS; do
	    VALUEFIELD[$i]=${!v}
#	    echo "${VALUEFIELD[$i]}"
		let "i=$i + 1"
	done
	
	ALLDIRS=""
	
	INDEX=`expr ${#VARFIELD[@]} - 1`
	recursive $INDEX
	
	echo "$CONFIGS configs created"
	
	for acdir in $ALLDIRS; do
	  echo $acdir
	  NOW=`pwd`
	  ( cd $ACDIR; $DIR/run_measurement.sh run $3; cd $NOW)
	done
	
	
	;;
esac

exit 0
