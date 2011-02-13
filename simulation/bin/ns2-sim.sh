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

#Function used to get params for control part TODO: try to use arrays
function get_params() {
  shift 6
  echo $@
}

if [ ! "x$1" = "xrun" ]; then
	echo "Use $0 run dis-file"
	exit 0
fi

WORKDIR=$pwd
CONFIGDIR=$(dirname "$2")
SIGN=`echo $CONFIGDIR | cut -b 1`

case "$SIGN" in
  "/")
      ;;
  ".")
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
   *)
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
esac

if [ -f $2 ]; then
    DISCRIPTIONFILE=$2
    . $DISCRIPTIONFILE
else
    echo "$2 : No such file !"
    exit 0;
fi

FINALRESULTDIR=`echo $RESULTDIR | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

if [ "x$3" = "x" ]; then
    echo "RESULTDIR is target. No Subdir."
else
    if [ -e $FINALRESULTDIR/$3 ]; then
	echo "Measurement already exits"
	exit 0
    else
	FINALRESULTDIR=$FINALRESULTDIR/$3
    fi
fi

mkdir $FINALRESULTDIR
chmod 777 $FINALRESULTDIR

case "$1" in
	"run")
		POSTFIX=ns2

		DISCRIPTIONFILENAME=`basename $DISCRIPTIONFILE`

                if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ]; then
		  cat $DISCRIPTIONFILE | sed -e "s#[[:space:]]*NODEPLACEMENTFILE[[:space:]]*=.*##g" -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		  echo "" >> $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		  echo "NODEPLACEMENTFILE=$FINALRESULTDIR/placementfile.plm" >> $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		else
		  cat $DISCRIPTIONFILE | sed -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		fi
			    
		CONFIGDIR=$CONFIGDIR POSTFIX=$POSTFIX $DIR/prepare-sim.sh prepare $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX

		mv $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp
		cat $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp | sed -e "s#$NODETABLE#$FINALRESULTDIR/$NODETABLE.$POSTFIX#g" > $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		rm $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp		

		SIMDIS=$FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
		. $SIMDIS
		TCLFILE="$FINALRESULTDIR/$NAME.tcl"
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | uniq`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`
		cat $DIR/../etc/ns/radio/$RADIO\.tcl > $TCLFILE

                if [ "x$NODEPLACEMENT" = "x" ]; then
		  echo "use default plm"
		  NODEPLACEMENT="random"
		fi
		if [ "x$FIELDSIZE" = "x" ]; then
		  FIELDSIZE=1000
		fi
		
                if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ] || [ "x$NODEPLACEMENT" = "xstring" ]; then
#		  echo "Gen Placement: $NODEPLACEMENT"
		  $DIR/generate_placement.sh $NODEPLACEMENT $NODETABLE $FIELDSIZE > $FINALRESULTDIR/placementfile.plm
		  FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
                else
             	  if [ -e $DIR/../etc/nodeplacement/$NODEPLACEMENTFILE ]; then
		    FINALPLMFILE="$DIR/../etc/nodeplacement/$NODEPLACEMENTFILE"
                  else
                    if [ -e $CONFIGDIR/$NODEPLACEMENTFILE ]; then
                      FINALPLMFILE="$CONFIGDIR/$NODEPLACEMENTFILE"
                    else
                      if [ -e $NODEPLACEMENTFILE ]; then
		        FINALPLMFILE=$NODEPLACEMENTFILE
                      else
                        if [ -e $FINALRESULTDIR/$NODEPLACEMENTFILE ]; then
                          FINALPLMFILE="$FINALRESULTDIR/$NODEPLACEMENTFILE"
                        else
                          FINALPLMFILE="$DIR/../etc/nodeplacement/placement.default"
                        fi
                      fi
                    fi
                  fi
		fi 
		
		POS_X_MAX=0
		POS_Y_MAX=0
		POS_Z_MAX=0

		#echo "FIN: $FINALPLMFILE"  
		for node in $NODELIST; do
		  POS_X=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $2}'`
		  POS_Y=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $3}'`
		  POS_Z=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $4}'`
		  if [ $POS_X -gt $POS_X_MAX ]; then
			    POS_X_MAX=$POS_X;
		  fi
		  if [ $POS_Y -gt $POS_Y_MAX ]; then
			    POS_Y_MAX=$POS_Y;
		  fi
		  if [ $POS_Z -gt $POS_Z_MAX ]; then
			    POS_Z_MAX=$POS_Z;
		  fi
		done
    
		POS_X_MAX=`expr $POS_X_MAX + 50`
		POS_Y_MAX=`expr $POS_Y_MAX + 50`
		POS_Z_MAX=`expr $POS_Z_MAX + 50`
		
		if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ]; then
		  if [ $POS_X_MAX -lt $FIELDSIZE ]; then
		    POS_X_MAX=$FIELDSIZE
		  fi
		  if [ $POS_Y_MAX -lt $FIELDSIZE ]; then
		    POS_Y_MAX=$FIELDSIZE
		  fi
		  POS_Z_MAX=0
		  #FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
		fi
 
#		echo "FIN: $FINALPLMFILE"
		echo "set xsize $POS_X_MAX" >> $TCLFILE
		echo "set ysize $POS_Y_MAX" >> $TCLFILE
		echo "set nodecount $NODECOUNT"	>> $TCLFILE
		echo "set stoptime $TIME" >> $TCLFILE
		
		if [ "x$RESULTDIR" = "x" ]; then
		    RESULTDIR=.
		fi
		
		cat $DIR/../etc/ns/script_01.tcl | sed -e "s#NAME#$NAME#g" -e "s#RESULTDIR#$RESULTDIR#g" >> $TCLFILE
		
		i=0
		echo -n "" > $FINALRESULTDIR/nodes.mac

		NODEMAC_SEDARG=""	
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			    CLICK=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}'`
			    echo "[\$node_($i) entry] loadclick \"$CLICK\"" >> $TCLFILE

			    mac_raw=`expr $i + 1`
			    m1=`expr $mac_raw / 256`
			    m2=`expr $mac_raw % 256`
			    m1h=$(echo "obase=16; $m1" | bc | tr [A-F] [a-f])
			    m2h=$(echo "obase=16; $m2" | bc | tr [A-F] [a-f])
			    if [ $m1 -lt 16 ]; then
			      m1h="0$m1h"
			    fi
			    if [ $m2 -lt 16 ]; then
			      m2h="0$m2h"
			    fi
			    echo "$node $nodedevice 00:00:00:00:$m1h:$m2h $i" >> $FINALRESULTDIR/nodes.mac
			    NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$node:eth#00:00:00:00:$m1h:$m2h#g"
			    
                            i=$mac_raw
		    done
		done
		
		echo "for {set i 0} {\$i < \$nodecount} {incr i} {" >> $TCLFILE
		echo "     \$ns_ at 0.0 \"[\$node_(\$i) entry] runclick\"" >> $TCLFILE
		echo " }" >> $TCLFILE
		
		i=0

		for node in $NODELIST; do
                    POS_X=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    POS_Y=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $3}'`
		    POS_Z=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $4}'`
		    
		    NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		
		    for nodedevice in $NODEDEVICELIST; do		    
		        echo "\$node_($i) set X_ $POS_X" >> $TCLFILE
		      	echo "\$node_($i) set Y_ $POS_Y" >> $TCLFILE
			echo "\$node_($i) set Z_ $POS_Z" >> $TCLFILE
			echo "\$node_($i) label $node.$nodedevice" >> $TCLFILE
			
      			POS_X=`expr $POS_X + 1`
			i=`expr $i + 1`
		    done
		done

		cat $DIR/../etc/ns/script_02.tcl >> $TCLFILE

		if [ "x$CONTROLFILE" != "x" ]; then
		    while read line; do
		        ISCOMMENT=`echo $line | grep "#" | wc -l`
		        if [ $ISCOMMENT -eq 0 ]; then
			    TIME=`echo $line | awk '{print $1}'`
			    NODENAME=`echo $line | awk '{print $2}'`
			    NODEDEVICE=`echo $line | awk '{print $3}'`
			    MODE=`echo $line | awk '{print $4}'`
			    ELEMENT=`echo $line | awk '{print $5}'`
			    HANDLER=`echo $line | awk '{print $6}'`
			    NODENUM=`cat $FINALRESULTDIR/nodes.mac | egrep "^$NODENAME[[:space:]]" | awk '{print $4}'`
			    
			    if [ "x$TIME" != "x" ]; then
    				if [ "x$MODE" = "xwrite" ]; then
				    VALUE=`get_params $line | sed $NODEMAC_SEDARG`
				    echo "\$ns_ at $TIME \"set result \\[\\[\$node_($NODENUM) entry\\] writehandler $ELEMENT $HANDLER \\\"$VALUE\\\" \\]\"" >> $TCLFILE
				else
				    echo "\$ns_ at $TIME \"puts \\\"\\[\\[\$node_($NODENUM) entry\\] readhandler $ELEMENT $HANDLER \\]\\\"\"" >> $TCLFILE
				fi
			    fi
			fi
		    done < $CONTROLFILE
		fi

		cat $DIR/../etc/ns/script_03.tcl >> $TCLFILE
	
		if [ ! -e $LOGDIR ]; then
		    echo "Create $LOGDIR"
		    mkdir -p $LOGDIR
		fi
		if [ ! -e $RESULTDIR ]; then
		    echo "Create $RESULTDIR"
		    mkdir -p $RESULTDIR
		fi

		which valgrind > /dev/null
		if [ $? -ne 0 ]; then
		    VALGRIND=0
		fi
		if [ "x$VALGRIND" = "x1" ]; then
		    NS_FULL_PATH=`which ns`
		    ( cd $FINALRESULTDIR; valgrind --leak-check=full --leak-resolution=high --log-file=$FINALRESULTDIR/valgrind.log $NS_FULL_PATH $TCLFILE > $LOGDIR/$LOGFILE  2>&1 )
		else
		    if [ "x$PROFILE" = "x1" ]; then
			( cd $FINALRESULTDIR; ns-profile $TCLFILE > $LOGDIR/$LOGFILE 2>&1 )
		    else
			( cd $FINALRESULTDIR; ns $TCLFILE > $LOGDIR/$LOGFILE 2>&1 )
		    fi
		fi
		
		if [ $? -eq 0 ]; then
		  MODE=sim SIM=ns2 CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh
		fi		
		;;
	"help")
		echo "Use $0 run dis-file result-dir"
		;;
	*)
		$0 help
		;;
esac

exit 0		
