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
		TCLFILE="tmp.tcl"
	    
		POSTFIX=$POSTFIX $DIR/prepare-sim.sh prepare $2
	
		SIMDIS=$2.$POSTFIX
		. $SIMDIS
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`
		cat $DIR/../etc/ns/radio/$RADIO\.tcl > $TCLFILE
		echo "set xsize 200" >> $TCLFILE
		echo "set ysize 200" >> $TCLFILE
		echo "set nodecount $NODECOUNT"	>> $TCLFILE
		echo "set stoptime $TIME" >> $TCLFILE
		
		cat $DIR/../etc/ns/script_01.tcl >> $TCLFILE
		
		i=0
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | grep "^$node" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			CLICK=`cat $NODETABLE | grep -v "#" | grep $node | grep $nodedevice | awk '{print $5}'`
			echo "[\$node_($i) entry] loadclick \"$CLICK\"" >> $TCLFILE
			i=`expr $i + 1`
		    done
		done
		
		echo "for {set i 0} {\$i < \$nodecount} {incr i} {" >> $TCLFILE
		echo "     \$ns_ at 0.0 \"[\$node_(\$i) entry] runclick\"" >> $TCLFILE
		echo " }" >> $TCLFILE
		
		i=0
		for node in $NODELIST; do
		    POS_X=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $2}'`
		    POS_Y=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $3}'`
		    POS_Z=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $4}'`
		    
		    NODEDEVICELIST=`cat $NODETABLE | grep "^$node" | awk '{print $2}'`
		
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
		
		ns $TCLFILE > $LOGDIR/$LOGFILE 2>&1

		POSTFIX=$POSTFIX $DIR/prepare-sim.sh cleanup $2

		;;
	*)
		$0 help
		;;
esac

exit 0		
