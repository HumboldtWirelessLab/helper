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
		SIMDIS=$2
		. $SIMDIS
		NODELIST=`cat $MES | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $MES | grep -v "#" | wc -l`
		cat $DIR/../etc/ns/radio/$RADIO\.tcl > tmp.tcl
		echo "set xsize 200" >> tmp.tcl
		echo "set ysize 200" >> tmp.tcl
		echo "set nodecount $NODECOUNT"	>> tmp.tcl
		echo "set stoptime $TIME" >> tmp.tcl
		
		cat $DIR/../etc/ns/script_01.tcl >> tmp.tcl
		
		i=0
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $MES | grep "^$node" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			CLICK=`cat $MES | grep -v "#" | grep $node | grep $nodedevice | awk '{print $5}'`
			echo "[\$node_($i) entry] loadclick \"$CLICK\"" >> tmp.tcl
			i=`expr $i + 1`
		    done
		done
		
		echo "for {set i 0} {\$i < \$nodecount} {incr i} {" >> tmp.tcl
		echo "     \$ns_ at 0.0 \"[\$node_(\$i) entry] runclick\"" >> tmp.tcl
		echo " }" >> tmp.tcl
		
		i=0
		for node in $NODELIST; do
		    POS_X=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $2}'`
		    POS_Y=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $3}'`
		    POS_Z=`cat $DIR/../../host/etc/nodeplacement/placement.default | grep -v "#" | grep $node | awk '{print $4}'`
		    
		    NODEDEVICELIST=`cat $MES | grep "^$node" | awk '{print $2}'`
		
		    for nodedevice in $NODEDEVICELIST; do		    

		        echo "\$node_($i) set X_ $POS_X" >> tmp.tcl
			echo "\$node_($i) set Y_ $POS_Y" >> tmp.tcl
			echo "\$node_($i) set Z_ $POS_Z" >> tmp.tcl
#		    	echo "\$node_($i) label \$node_mac($i).$node" >> tmp.tcl
			echo "\$node_($i) label $node.$nodedevice" >> tmp.tcl
			
			POS_X=`expr $POS_X + 1`
			i=`expr $i + 1`
		    done
		done

		cat $DIR/../etc/ns/script_02.tcl >> tmp.tcl
		
		ns tmp.tcl

		;;
	*)
		$0 help
		;;
esac

exit 0		
