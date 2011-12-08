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


if [ "x$1" = "xhelp" ]; then
  echo "Use: [DUMPFILEDIR=Path-to-dumps] $0 [ns|jist [des-file  [target-dir]]]"
  
  exit 0
fi

if [ $# -gt 0 ]; then
  if [ ! "x$1" = "xjist" ] && [ ! "x$1" = "xns" ]; then
	echo "Use $0 [ns|jist] des-file"
	exit 0
  fi

  USED_SIMULATOR=$1
else
  USED_SIMULATOR=ns
fi


if [ "x$EVAL_LOG_OUT" = "x" ]; then
  EVAL_LOG_OUT=1
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

if [ $# -gt 1 ]; then
  if [ -f $2 ]; then
    DESCRIPTIONFILE=$2
  else
    echo "$2 : No such file !"
    exit 0;
  fi
else
  DESCRIPTIONFILE=`ls *.des | awk '{print $1}'`
  
  if [ "x$DESCRIPTIONFILE" = "x" ]; then
    echo "No description-file"
    exit 0
  fi
fi

. $DESCRIPTIONFILE

FINALRESULTDIR=`echo $RESULTDIR | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

if [ "x$3" = "x" ]; then
    echo "RESULTDIR is target. No Subdir."
    
    # check numbered directories to propose automatically 
    i=1 
    while [ -e "./$i" ]; do i=$((i+1)); done 
         
    echo "Proposing $FINALRESULTDIR/$i" 
    FINALRESULTDIR=$FINALRESULTDIR/$i 
else
    if [ -e $FINALRESULTDIR/$3 ]; then
	echo "Measurement already exits"
	
        i=$3
        while [ -e "./$i" ]; do i=$((i+1)); done 
	echo "Use $FINALRESULTDIR/$i"
	FINALRESULTDIR=$FINALRESULTDIR/$i
	#exit 0
    else
	FINALRESULTDIR=$FINALRESULTDIR/$3
    fi
fi

mkdir $FINALRESULTDIR
chmod 777 $FINALRESULTDIR

MODE=sim

case "$MODE" in
    "sim")
	        if [ "x$USED_SIMULATOR" = "xjist" ]; then
		    POSTFIX=jist
		else
		    POSTFIX=ns2
		fi

		DESCRIPTIONFILENAME=`basename $DESCRIPTIONFILE`

                if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ]; then
		  cat $DESCRIPTIONFILE | sed -e "s#[[:space:]]*NODEPLACEMENTFILE[[:space:]]*=.*##g" -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		  echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		  echo "NODEPLACEMENTFILE=$FINALRESULTDIR/placementfile.plm" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		else
		  cat $DESCRIPTIONFILE | sed -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		fi

                if [ "x$NODEPLACEMENT" = "x" ]; then
		  echo "use default plm"
		  NODEPLACEMENT="random"
		fi
		if [ "x$FIELDSIZE" = "x" ]; then
		  FIELDSIZE=1000
		fi

                if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ] || [ "x$NODEPLACEMENT" = "xstring" ]; then
		  FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
                else
		  #use Placementfile
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

		DUMPFILEDIR=$DUMPFILEDIR USED_SIMULATOR=$USED_SIMULATOR CONFIGDIR=$CONFIGDIR POSTFIX=$POSTFIX NODEPLACEMENTFILE=$FINALPLMFILE $DIR/prepare-sim.sh prepare $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		mv $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		cat $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp | grep -v "NODEPLACEMENTFILE" | sed -e "s#$NODETABLE#$FINALRESULTDIR/$NODETABLE.$POSTFIX#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "NODEPLACEMENTFILE=$FINALPLMFILE" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		
		rm $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		SIMDES=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		
		. $SIMDES
		
		if [ -f $DIR/../etc/ns/distances/$RADIO ]; then
		  . $DIR/../etc/ns/distances/$RADIO
		  if [ "x$FIELDSIZE" = "xRXRANGE" ]; then
		    FIELDSIZE=$RXRANGE
		  fi
		fi
				
		if [ "x$POSTFIX" = "xns2" ]; then
		  TCLFILE="$FINALRESULTDIR/$NAME.tcl"
		  WIFICONFIGFILE=`cat $NODETABLE | grep -v "#" | head -n 1 | awk '{print $5}'`
		  
		  . $DIR/../../nodes/etc/wifi/default

		  if [ -f $WIFICONFIGFILE ]; then
		    . $WIFICONFIGFILE
		  else
		    if [ -f $CONFIGDIR/$WIFICONFIGFILE ]; then
		      . $CONFIGDIR/$WIFICONFIGFILE
		    else
		      if [ -f $DIR/../../nodes/etc/wifi/$WIFICONFIGFILE ]; then
		        . $DIR/../../nodes/etc/wifi/$WIFICONFIGFILE
		      fi
		    fi
		  fi
		  
		  if [ "x$CWMIN" = "x" ]; then
		    CWMIN=$DEFAULT_CWMIN
		  fi 
		  if [ "x$CWMAX" = "x" ]; then
		    CWMAX=$DEFAULT_CWMAX
		  fi 
		  if [ "x$AIFS" = "x" ]; then
		    AIFS=$DEFAULT_AIFS
		  fi 
  
		else
		  TCLFILE="/dev/null"
		fi
		
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | uniq`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`
		
		echo "#Autogenerated" > $TCLFILE
		
		INDEX=1
		
		for hwq in `seq 0 3`; do
		   echo $CWMIN | awk -v I=$hwq '{print "Mac/802_11 set CWMin"I"_ "$(I+1)}' | sed "s#0_#_#g" >> $TCLFILE   
		   echo $CWMAX | awk -v I=$hwq '{print "Mac/802_11 set CWMax"I"_ "$(I+1)}' | sed "s#0_#_#g" >> $TCLFILE
		done
		
		echo "Mac/802_11 set NoHWQueues_ 4" >> $TCLFILE
		
		cat $DIR/../etc/ns/radio/$RADIO\.tcl >> $TCLFILE
		
                if [ "x$NODEPLACEMENT" = "xrandom" ] || [ "x$NODEPLACEMENT" = "xgrid" ] || [ "x$NODEPLACEMENT" = "xnpart" ] || [ "x$NODEPLACEMENT" = "xstring" ]; then
		  NODEPLACEMENTOPTS="$NODEPLACEMENTOPTS" $DIR/generate_placement.sh $NODEPLACEMENT $NODETABLE $FIELDSIZE > $FINALRESULTDIR/placementfile.plm
		  FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
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
 
                 # write position to .click file (there call a handler in Script like) 
                 # Script (
                 #   "write loc.cart_coord NODEPOSITIONX NODEPOSITIONY NODEPOSITIONZ,"
                 #   ...
                 # );
		  NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		  for nodedevice in $NODEDEVICELIST; do		    
		    CLICK=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}'`
		    if [ "x$CLICK" != "x-" ] && [ -f $CLICK ]; then
		      cat $CLICK | sed -e "s#NODEPOSITIONX#$POS_X#g" -e "s#NODEPOSITIONY#$POS_Y#g" -e "s#NODEPOSITIONZ#$POS_Z#g" > $CLICK.tmp
		      mv $CLICK.tmp $CLICK
		    fi
                  done

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
		NODENAME_SEDARG=""
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
			    if [ "x$NODEMAC_SEDARG" = "x" ]; then
			      NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#FIRSTNODE:eth#00:00:00:00:$m1h:$m2h#g"
			      NODENAME_SEDARG="$NODENAME_SEDARG -e s#FIRSTNODE#$node#g"
			    fi
			    
			    NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$node:eth#00:00:00:00:$m1h:$m2h#g"
			    
                            i=$mac_raw
			    
			    last_node=$node
		    done
		done

		if [ "x$NODEMAC_SEDARG" != "x" ]; then
		  NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#LASTNODE:eth#00:00:00:00:$m1h:$m2h#g"
		  NODENAME_SEDARG="$NODENAME_SEDARG -e s#LASTNODE#$last_node#g"
		fi
		
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
		    if [ "x$USED_SIMULATOR" = "xjist" ]; then
		      echo -n "handler.script = " > $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
		    fi
		    while read line; do
		        ISCOMMENT=`echo $line | grep "#" | wc -l`
		        if [ $ISCOMMENT -eq 0 ]; then
			    TIME=`echo $line | awk '{print $1}'`
			    NODENAME=`echo $line | awk '{print $2}' | sed $NODENAME_SEDARG`
			    NODEDEVICE=`echo $line | awk '{print $3}'`
			    MODE=`echo $line | awk '{print $4}'`
			    ELEMENT=`echo $line | awk '{print $5}'`
			    HANDLER=`echo $line | awk '{print $6}'`
			    NODENUM=`cat $FINALRESULTDIR/nodes.mac | egrep "^$NODENAME[[:space:]]" | awk '{print $4}'`
			    
			    if [ "x$TIME" != "x" ]; then
    				if [ "x$MODE" = "xwrite" ]; then
				    VALUE=`get_params $line | sed $NODEMAC_SEDARG`
				    if [ "x$USED_SIMULATOR" = "xns" ]; then
				      echo "\$ns_ at $TIME \"set result \\[\\[\$node_($NODENUM) entry\\] writehandler $ELEMENT $HANDLER \\\"$VALUE\\\" \\]\"" >> $TCLFILE
				    else
				      echo -n "$TIME,$NODENAME,$NODEDEVICE,$MODE,$ELEMENT,$HANDLER,$VALUE;" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
				    fi
				else
				    if [ "x$USED_SIMULATOR" = "xns" ]; then
				      echo "\$ns_ at $TIME \"puts \\\"\\[\\[\$node_($NODENUM) entry\\] readhandler $ELEMENT $HANDLER \\]\\\"\"" >> $TCLFILE
				    else
				      echo -n "$TIME,$NODENAME,$NODEDEVICE,$MODE,$ELEMENT,$HANDLER,;" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
				    fi
				fi
			    fi
			fi
		    done < $CONTROLFILE
		    if [ "x$USED_SIMULATOR" = "xjist" ]; then
		      echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
		    fi
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

		if [ "x$USED_SIMULATOR" = "xns" ]; then
		    which valgrind > /dev/null
		    if [ $? -ne 0 ]; then
			VALGRIND=0
		    fi
		    if [ "x$VALGRIND" = "x1" ]; then
			NS_FULL_PATH=`which ns`
			( cd $FINALRESULTDIR; valgrind --leak-check=full --leak-resolution=high --leak-check=full --show-reachable=yes --log-file=$FINALRESULTDIR/valgrind.log $NS_FULL_PATH $TCLFILE > $LOGDIR/$LOGFILE  2>&1 )
		    else
			if [ "x$PROFILE" = "x1" ]; then
			    ( cd $FINALRESULTDIR; ns-profile $TCLFILE > $LOGDIR/$LOGFILE 2>&1 )
			else
			    ( cd $FINALRESULTDIR; ns $TCLFILE > $LOGDIR/$LOGFILE 2>&1 )
			fi
		    fi
		
		    if [ $? -eq 0 ]; then
			MODE=sim SIM=ns2 CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh 1>&$EVAL_LOG_OUT
		    else
		      exit 1
		    fi
		else
		    ( cd $FINALRESULTDIR; $DIR/convert2jist.sh convert $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties )
		    ( cd $FINALRESULTDIR; $DIR/start-jist-sim.sh $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties > $LOGDIR/$LOGFILE 2>&1 )

		    if [ $? -eq 0 ]; then
			MODE=sim SIM=ns2 CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh 1>&$EVAL_LOG_OUT
		    else
		      exit 1
		    fi
		    
		fi		
		;;
esac

exit $?		
