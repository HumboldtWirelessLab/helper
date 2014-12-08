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
  local VALUES=""
  VALUES=(${VALUEFIELD[$1]})
  local CURINDEX=0;
  local NEXT=`expr $1 - 1`
  local SEDARG=""

  while [ $CURINDEX -lt ${#VALUES[@]} ]; do
    GLOBALINDEX[$1]=$CURINDEX
    
    if [ $1 -eq 0 ]; then
 
      rm -rf $MDIR/PARAMS_$CONFIGS
      mkdir -p $MDIR/PARAMS_$CONFIGS
      
      ALLDIRS="$ALLDIRS $MDIR/PARAMS_$CONFIGS"
      
      local i=0;
      while [ $i -lt ${#VARFIELD[@]} ]; do
        ACVALUE=(${VALUEFIELD[$i]})
        SEDARG="$SEDARG -e s#${VARFIELD[$i]}#${ACVALUE[${GLOBALINDEX[$i]}]}#g"
 
        echo "${VARFIELD[$i]}=${ACVALUE[${GLOBALINDEX[$i]}]}" >> $MDIR/PARAMS_$CONFIGS/config
 
        let "i = $i +1"
      done
      
      for acfile in  `ls $MDIR`; do
        if [ "$acfile" = "$PARAMSFILE" ]; then
          cp $MDIR/$acfile $MDIR/PARAMS_$CONFIGS/
        else
	  if [ "x$acfile" = "x" ]; then
	    echo "No acfile"
	  else
	    #echo "foo $MDIR $acfile"
	    if [ -f $MDIR/$acfile ]; then
        	cat $MDIR/$acfile | sed $SEDARG > $MDIR/PARAMS_$CONFIGS/$acfile
	    else
		if [ "x$acfile" = "xevaluation" ]; then
		  cp -r $MDIR/$acfile $MDIR/PARAMS_$CONFIGS/$acfile
		fi
	    fi

	    #echo "foo2"
	  fi
        fi
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
	echo "Use $0 [sim|measurement] desfile"
	echo "Skript to run measurement with different parameters (e.g. TXPOWER, CHANNEL,...). The collectionfile include the parameter and the name of the templatefiles (configfile with Vars as parameters)."
	;;
    "run"|"sim")

        if [ "$1" = "sim" ]; then
          SIMULATION=1
          PREPARE_ONLY=1
        else
          SIMULATION=0
          PREPARE_ONLY=
        fi

        if [ "x$PARAMSRUNMODE" = "x" ]; then
          PARAMSRUNMODE="REBOOT"
        fi

		MDIR=`dirname $2`
		. $2
		
		if [ "x$MDIR" = "x." ]; then
		  MDIR=$(pwd)
		fi
		
		if [ "x$PARAMSFILE" = "x" ]; then
		  echo "Missing PARAMSFILE in $2"
		  exit 0
		fi
		
		if [ ! -f $MDIR/$PARAMSFILE ]; then
		  echo "PARAMSFILE $PARAMSFILE doesn't exists"
		  exit 0
		fi
					
		VARS=`cat $MDIR/$PARAMSFILE | sed -e "s#=# #g" | awk '{print $1}'`
		
		VARFIELD=($VARS)
		
		echo $VARFIELD
		
		. $MDIR/$PARAMSFILE
		
		i=0
		for v in $VARS; do
			VALUEFIELD[$i]=${!v}
			let "i=$i + 1"
		done
		
		ALLDIRS=""
		
		INDEX=`expr ${#VARFIELD[@]} - 1`
		recursive $INDEX
		
		echo "Create $CONFIGS configs !"
		
		CURRUN=1
		
		#echo $ALLDIRS
		
	for acdir in $ALLDIRS; do

	  if [ "x$PARAMSWAIT" = "x1" ]; then
	    echo -n "Press any key to run $CURRUN. params measurement"
	    read -n 1 trash
	  fi
	  if [ $SIMULATION -eq 0 ]; then
		echo "Run $CURRUN. params"
	  else
		echo "Prepare $CURRUN. params"
	  fi
		  NOW=`pwd`
		  ( cd $acdir; SIMULATION=$SIMULATION TESTONLY=$TESTONLY PREPARE_ONLY=$PREPARE_ONLY FIRSTRUNMODE=$FIRSTRUNMODE MULTIRUNMODE=$MULTIRUNMODE MULTIMODE="LOOP" RUNS=$MULTIREPEAT MULTIWAIT=$MULTIWAIT $DIR/run_multiple_measurments.sh $2; cd $NOW)
		  let "CURRUN=$CURRUN + 1"

		  #TODO think about
		  FIRSTRUNMODE=$PARAMSRUNMODE
	done

	if [ $SIMULATION -eq 1 ]; then
	  run_para_sim.sh
	fi

	if [ "x$PARAMSEVALUATION" != "x" ]; then
	  $PARAMSEVALUATION
	fi

	;;
esac

exit 0
