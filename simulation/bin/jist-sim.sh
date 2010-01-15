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

case "$1" in
	"help")
		echo "Use $0 run"
		;;
	"run")
			POSTFIX=ns2
    if [ "x$NODEPLACEMENT" = "xRANDOM" ]; then
      USERANDOMPLM=yes
    else
      USERANDOMPLM=no
    fi
    
		DISCRIPTIONFILENAME=`basename $DISCRIPTIONFILE`
		if [ $USERANDOMPLM = "yes" ]; then
		  cat $DISCRIPTIONFILE | sed -e "s#[[:space:]]*NODEPLACEMENTFILE[[:space:]]*=.*##g" -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DISCRIPTIONFILENAME.$POSTFIX
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
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`
		cat $DIR/../etc/ns/radio/$RADIO\.tcl > $TCLFILE

		POS_X_MAX=0
		POS_Y_MAX=0
		POS_Z_MAX=0
		if [ $USERANDOMPLM = "yes" ]; then
		  POS_X_MAX=$FIELDSIZE
		  POS_Y_MAX=$FIELDSIZE
		  POS_Z_MAX=0
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
    fi
    
		echo "set xsize $POS_X_MAX" >> $TCLFILE
		echo "set ysize $POS_Y_MAX" >> $TCLFILE
		echo "set nodecount $NODECOUNT"	>> $TCLFILE
		echo "set stoptime $TIME" >> $TCLFILE
		
		if [ "x$RESULTDIR" = "x" ]; then
		    RESULTDIR=.
		fi
		
		cat $DIR/../etc/ns/script_01.tcl | sed -e "s#NAME#$NAME#g" -e "s#RESULTDIR#$RESULTDIR#g" >> $TCLFILE
		
		i=0
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			    CLICK=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}'`
			    echo "[\$node_($i) entry] loadclick \"$CLICK\"" >> $TCLFILE
          i=`expr $i + 1`
		    done
		done
		
		echo "for {set i 0} {\$i < \$nodecount} {incr i} {" >> $TCLFILE
		echo "     \$ns_ at 0.0 \"[\$node_(\$i) entry] runclick\"" >> $TCLFILE
		echo " }" >> $TCLFILE
		
		i=0

    if [ $USERANDOMPLM = "yes" ]; then
      rm -rf $FINALPLMFILE
		fi
		
		for node in $NODELIST; do
		    if [ $USERANDOMPLM = "yes" ]; then
		      POS_X=$(( $RANDOM % $FIELDSIZE ))
		      POS_Y=$(( $RANDOM % $FIELDSIZE ))
		      POS_Z=0
		      echo "$node $POS_X $POS_Y $POS_Z" >> $FINALPLMFILE
		    else
		      POS_X=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $2}'`
		      POS_Y=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $3}'`
		      POS_Z=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]" | awk '{print $4}'`
		    fi
		    
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
	
		if [ ! -e $LOGDIR ]; then
		    echo "Create $LOGDIR"
		    mkdir -p $LOGDIR
		fi
		if [ ! -e $RESULTDIR ]; then
		    echo "Create $RESULTDIR"
		    mkdir -p $RESULTDIR
		fi

		( cd $FINALRESULTDIR; ns $TCLFILE > $LOGDIR/$LOGFILE 2>&1 )

		;;
	*)
		$0 help
		;;
esac

exit 0		
