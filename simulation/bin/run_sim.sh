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

. $DIR/../../measurement/etc/wifitypes

if [ "x$LOGLEVEL" = "x" ]; then
  LOGLEVEL=1
fi

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
	if [ ! "x$1" = "xjist" ] && [ ! "x$1" = "xns" ] && [ ! "x$1" = "xns3" ]; then
		echo "Use $0 [ns|ns3|jist] des-file"
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


# check for result directory
if [ "x$3" = "x" ]; then
	echo "RESULTDIR is target. No Subdir."

	# check numbered directories to propose automatically
	i=1
	while [ -e "./$i" ]; do i=$((i+1)); done

	echo "Proposing $FINALRESULTDIR/$i"
	FINALRESULTDIR=$FINALRESULTDIR/$i
else
	if [ -e $FINALRESULTDIR/$3 ]; then
		i=$3
	        if [ "x$FORCE_DIR" = "x" ]; then
		  echo "Measurement already exits"

		  while [ -e "./$i" ]; do i=$((i+1)); done

		  if [ $LOGLEVEL -gt 0 ]; then echo "Use $FINALRESULTDIR/$i"; fi

		else
		  rm -rf $FINALRESULTDIR/$i
		fi

		FINALRESULTDIR=$FINALRESULTDIR/$i
	else
		FINALRESULTDIR=$FINALRESULTDIR/$3
	fi
fi

if [ ! -e $FINALRESULTDIR ]; then
  mkdir $FINALRESULTDIR
fi

chmod 777 $FINALRESULTDIR

MODE=sim

case "$MODE" in
	"sim")
		declare -a dectohex=('00' '01' '02' '03' '04' '05' '06' '07' '08' '09' '0A' '0B' '0C' '0D' '0E' '0F' '10' '11' '12' '13' '14' '15' '16' '17' '18' '19' '1A' '1B' '1C' '1D' '1E' '1F' '20' '21' '22' '23' '24' '25' '26' '27' '28' '29' '2A' '2B' '2C' '2D' '2E' '2F' '30' '31' '32' '33' '34' '35' '36' '37' '38' '39' '3A' '3B' '3C' '3D' '3E' '3F' '40' '41' '42' '43' '44' '45' '46' '47' '48' '49' '4A' '4B' '4C' '4D' '4E' '4F' '50' '51' '52' '53' '54' '55' '56' '57' '58' '59' '5A' '5B' '5C' '5D' '5E' '5F' '60' '61' '62' '63' '64' '65' '66' '67' '68' '69' '6A' '6B' '6C' '6D' '6E' '6F' '70' '71' '72' '73' '74' '75' '76' '77' '78' '79' '7A' '7B' '7C' '7D' '7E' '7F' '80' '81' '82' '83' '84' '85' '86' '87' '88' '89' '8A' '8B' '8C' '8D' '8E' '8F' '90' '91' '92' '93' '94' '95' '96' '97' '98' '99' '9A' '9B' '9C' '9D' '9E' '9F' 'A0' 'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'AA' 'AB' 'AC' 'AD' 'AE' 'AF' 'B0' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'BA' 'BB' 'BC' 'BD' 'BE' 'BF' 'C0' 'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'CA' 'CB' 'CC' 'CD' 'CE' 'CF' 'D0' 'D1' 'D2' 'D3' 'D4' 'D5' 'D6' 'D7' 'D8' 'D9' 'DA' 'DB' 'DC' 'DD' 'DE' 'DF' 'E0' 'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'EA' 'EB' 'EC' 'ED' 'EE' 'EF' 'F0' 'F1' 'F2' 'F3' 'F4' 'F5' 'F6' 'F7' 'F8' 'F9' 'FA' 'FB' 'FC' 'FD' 'FE' 'FF');
		declare -A node_to_num_map
		declare -A node_to_clickfile_map

		if [ "x$USED_SIMULATOR" = "xjist" ]; then
			POSTFIX=jist
		else if [ "x$USED_SIMULATOR" = "xns3" ]; then
			POSTFIX=ns3
		else
			POSTFIX=ns2
		fi
		fi

		DESCRIPTIONFILENAME=`basename $DESCRIPTIONFILE`

		if [ "x$NODEPLACEMENT" != "xfile" ]; then
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

		if [ "x$NODEPLACEMENT" != "xfile" ]; then
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
							echo "Unable to find placementfile $NODEPLACEMENTFILE. Use default!"
							FINALPLMFILE="$DIR/../etc/nodeplacement/placement.default"
						fi
					fi
				fi
			fi
		fi

		echo "gen clickfile" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log
		DUMPFILEDIR=$DUMPFILEDIR USED_SIMULATOR=$USED_SIMULATOR CONFIGDIR=$CONFIGDIR POSTFIX=$POSTFIX NODEPLACEMENTFILE=$FINALPLMFILE $DIR/prepare-sim.sh prepare $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		date +"%s:%N" >> $FINALRESULTDIR/time.log

		echo "run_sim" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log

		mv $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		cat $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp | grep -v "NODEPLACEMENTFILE" | sed -e "s#$NODETABLE#$FINALRESULTDIR/$NODETABLE.$POSTFIX#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "NODEPLACEMENTFILE=$FINALPLMFILE" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		rm $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		SIMDES=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		. $SIMDES

		if  [ "x$POSTFIX" = "xjist" ]; then
			. $DIR/../etc/jist/distances/default
		else
			if [ -f $DIR/../etc/ns/distances/$RADIO ]; then
				. $DIR/../etc/ns/distances/$RADIO
			fi
		fi

                if [ "x$FIELDSIZE" = "xRXRANGE" ]; then
                  FIELDSIZE=$RXRANGE
                fi
                if [ "x$FIELDSIZE" = "xMAXRXRANGE" ]; then
                  FIELDSIZE=$MAXRXRANGE
                fi
                if [ "x$FIELDSIZE" = "xCSRANGE" ]; then
                  FIELDSIZE=$CSRANGE
                fi
                if [ "x$FIELDSIZE" = "xNORXRANGE" ]; then
                  FIELDSIZE=$NORXRANGE
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

		echo "gen placement" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log
		if [ "x$NODEPLACEMENT" != "xfile" ]; then
			#let TOPORXRANGE=MAXRXRANGE+20
			TOPORXRANGE=$MAXRXRANGE
			NODEPLACEMENTOPTS="$NODEPLACEMENTOPTS" RXRANGE=$TOPORXRANGE $DIR/generate_placement.sh $NODEPLACEMENT $NODETABLE $FIELDSIZE > $FINALRESULTDIR/placementfile.plm
			FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
		fi

		POS_X_MAX=`cat $FINALPLMFILE | awk '{print $2}' | sort | tail -n 1`
		POS_Y_MAX=`cat $FINALPLMFILE | awk '{print $3}' | sort | tail -n 1`
		POS_Z_MAX=`cat $FINALPLMFILE | awk '{print $4}' | sort | tail -n 1`

		let POS_X_MAX=POS_X_MAX+50
		let POS_Y_MAX=POS_Y_MAX+50
		let POS_Z_MAX=POS_Z_MAX+50

		if [ "x$FIELDSIZE" = "x" ]; then
			FIELDSIZE=$POS_X_MAX
		fi
		if [ $FIELDSIZE -lt $POS_X_MAX ]; then
			FIELDSIZE=$POS_X_MAX
		fi
		if [ $FIELDSIZE -lt $POS_Y_MAX ]; then
			FIELDSIZE=$POS_Y_MAX
		fi

		if [ $POS_X_MAX -lt $FIELDSIZE ]; then
			POS_X_MAX=$FIELDSIZE
		fi
		if [ $POS_Y_MAX -lt $FIELDSIZE ]; then
			POS_Y_MAX=$FIELDSIZE
		fi
		POS_Z_MAX=0
		#FINALPLMFILE=$FINALRESULTDIR/placementfile.plm

		#echo "FIN: $FINALPLMFILE"
		echo "set xsize $POS_X_MAX" >> $TCLFILE
		echo "set ysize $POS_Y_MAX" >> $TCLFILE
		echo "set nodecount $NODECOUNT"	>> $TCLFILE
		echo "set stoptime $TIME" >> $TCLFILE

		if [ "x$SEED" != "x" ]; then
		    echo "\$defaultRNG seed $SEED" >> $TCLFILE
		    echo "set arrivalRNG [new RNG]" >> $TCLFILE
		    echo "set sizeRNG [new RNG]" >> $TCLFILE

#		    echo "set seed $SEED" >> $TCLFILE
#		    echo "set seed $SEED" > /dev/null
		fi

		if [ "x$RESULTDIR" = "x" ]; then
			RESULTDIR=.
		fi

		i=0
		echo -n "" > $FINALRESULTDIR/nodes.mac

		NODEMAC_SEDARG=""
		NODENAME_SEDARG=""

		echo "" >> $TCLFILE

		echo "gen nodes.mac" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log
		# Scann the node table to build a NetworkSimulator-Command for
		# each line in the table, using mainly the information of "NODE" and
		# "CLICKSCRIPT".
		for node in $NODELIST; do
			POS_LINE=`cat $FINALPLMFILE | grep -v "#" | egrep "^$node[[:space:]]"`
			read TRASH POS_X POS_Y POS_Z <<< $POS_LINE

			NODEDEVICELIST_CLICK=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2","$7}'`

			for nodedevice_click in $NODEDEVICELIST_CLICK; do

				IFS=, read nodedevice_click_nospace <<< $nodedevice_click
				read nodedevice CLICK <<< $nodedevice_click_nospace

				if [ "x$NAME2MAC" = "xyes" ]; then
				  mac_raw=`echo $node | sed -e "s#[a-z]*[A-Z]*##g"`
				else
				  let mac_raw=i+1
				fi

				let m1=mac_raw/256
				let m2=mac_raw%256

				nodemac="00-00-00-00-${dectohex[m1]}-${dectohex[m2]}"
				echo "$node $nodedevice $nodemac $mac_raw" >> $FINALRESULTDIR/nodes.mac
				node_to_num_map[$node]=$mac_raw
				node_to_clickfile_map[$node]=$CLICK

				if [ "x$NODEMAC_SEDARG" = "x" ]; then
					NODEMAC_SEDARG="-e s#FIRSTNODE:eth#$nodemac#g"
					NODENAME_SEDARG="-e s#FIRSTNODE#$node#g"
				fi

				NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$node:eth#$nodemac#g"

				echo "set node_name($i) \"$node\"" >> $TCLFILE
				echo "set node_mac($i) \"00:00:00:00:${dectohex[m1]}:${dectohex[m2]}\"" >> $TCLFILE

				echo "set pos_x($i) $POS_X" >> $TCLFILE
				echo "set pos_y($i) $POS_Y" >> $TCLFILE
				echo "set pos_z($i) $POS_Z" >> $TCLFILE
				echo "set nodelabel($i) \"$node.$nodedevice\"" >> $TCLFILE

				echo "set clickfile($i) \"$CLICK\"" >> $TCLFILE

				let POS_X=POS_X+1
				let i=i+1
			done
		done

		if [ "x$NODEMAC_SEDARG" != "x" ]; then
			NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#LASTNODE:eth#$nodemac#g"
			NODENAME_SEDARG="$NODENAME_SEDARG -e s#LASTNODE#$node#g"
		fi

                if [ "x$DISABLE_TR" = "x1" ]; then
                  echo "set enable_tr 0" >> $TCLFILE
                else
                  echo "set enable_tr 1" >> $TCLFILE
                fi
                if [ "x$DISABLE_NAM" = "x1" ]; then
                  echo "set enable_nam 0" >> $TCLFILE
                else
                  echo "set enable_nam 1" >> $TCLFILE
                fi

		cat $DIR/../etc/ns/script_01.tcl | sed -e "s#NAME#$NAME#g" -e "s#RESULTDIR#$RESULTDIR#g" >> $TCLFILE

		cat $DIR/../etc/ns/script_02.tcl >> $TCLFILE

		echo "handle" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log
		#echo "Handle Control file"
		# Evaluate the control file (*.ctl)
		if [ "x$CONTROLFILE" != "x" ]; then
			if [ "x$USED_SIMULATOR" = "xjist" ]; then
				echo -n "handler.script = " > $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
			fi
			while read line; do
				ISCOMMENT=`echo $line | grep "#" | wc -l`
				if [ $ISCOMMENT -eq 0 ]; then
					# collect information of control file
					#read TIME NODENAME NODEDEVICE MODE ELEMENT HANDLER <<< $line
					#NODENAME=`echo $NODENAME | sed $NODENAME_SEDARG`

					#OLD VERSION
					TIME=`echo $line | awk '{print $1}'`
					NODENAME=`echo $line | awk '{print $2}' | sed $NODENAME_SEDARG`
					NODEDEVICE=`echo $line | awk '{print $3}'`
					MODE=`echo $line | awk '{print $4}'`
					ELEMENT=`echo $line | awk '{print $5}'`
					HANDLER=`echo $line | awk '{print $6}'`

					#Produces wrong clickfiles from controlfiles
					#read TIME NODENAME NODEDEVICE MODE ELEMENT HANDLER <<< $line
					#NODENAME=`echo $NODENAME | sed $NODENAME_SEDARG`

					# if "ALL" is used, take all nodes of nodelist, else just the respective node
					if [ "x$NODENAME" = "xALL" ]; then
						HANDLERNODES=$NODELIST
					else
						HANDLERNODES=$NODENAME
					fi

					# Main stage: now we set up the click-handler which are going to be
					# used by the simulator to dynamically control the process
					# or get some information out of the network activities... yey!
					for n in $HANDLERNODES; do

						CLICKFILE=${node_to_clickfile_map[$n]}
						#CLICKFILE=`cat $NODETABLE | grep "$n eth0 " | awk '{print $7}'`

						if [ "x$CLICKFILE" = "x" ]; then
							continue;
						fi

						NODENUM=${node_to_num_map[$n]}
						#NODENUM=`cat $FINALRESULTDIR/nodes.mac | egrep "^$n[[:space:]]" | awk '{print $4}'`
						
						let NODENUM=NODENUM-1
						if [ "x$TIME" != "x" ]; then

							# the write handler
							if [ "x$MODE" = "xwrite" ]; then
								VALUE=`get_params $line | sed $NODEMAC_SEDARG`
								if [ "x$USED_SIMULATOR" = "xns" ]; then
									echo "Script(wait $TIME, write  $ELEMENT.$HANDLER $VALUE);" >> $CLICKFILE
									#echo "\$ns_ at $TIME \"set result \\[\\[\$node_($NODENUM) entry\\] writehandler $ELEMENT $HANDLER \\\"$VALUE\\\" \\]\"" >> $TCLFILE
								else
									echo -n "$TIME,$NODENAME,$NODEDEVICE,$MODE,$ELEMENT,$HANDLER,$VALUE;" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
								fi
							# the read handler
							elif [ "x$MODE" = "xread" ]; then
								if [ "x$USED_SIMULATOR" = "xns" ]; then
									echo "Script(wait $TIME, read $ELEMENT.$HANDLER);" >> $CLICKFILE
									#echo "\$ns_ at $TIME \"puts \\\"\\[\\[\$node_($NODENUM) entry\\] readhandler $ELEMENT $HANDLER \\]\\\"\"" >> $TCLFILE
								else
									echo -n "$TIME,$NODENAME,$NODEDEVICE,$MODE,$ELEMENT,$HANDLER,;" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
								fi
							# for special purpose: move nodes in simulator
							elif [ "x$MODE" = "xmove" ]; then
								MOVE_MODE=$ELEMENT
								MOVE_SPEED=$HANDLER
								read TRASH1 TRASH2 TRASH3 TRASH4 TRASH5 TRASH6 MOVE_X MOVE_Y MOVE_Z <<< $line
								if [ "x$USED_SIMULATOR" = "xns" ]; then
									echo "\$ns_ at $TIME \"\$node_($NODENUM) setdest $MOVE_X $MOVE_Y $MOVE_SPEED\"" >> $TCLFILE
								else
									echo -n "$TIME,$NODENAME,$NODEDEVICE,$MODE,$ELEMENT,$HANDLER,;" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
								fi
							fi
						fi
					done
				fi
			done < $CONTROLFILE
			if [ "x$USED_SIMULATOR" = "xjist" ]; then
				echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
			fi
		fi

		cat $DIR/../etc/ns/script_03.tcl >> $TCLFILE

		#echo "Finish setup"

		# Prepare result directories
		if [ ! -e $LOGDIR ]; then
			echo "Create $LOGDIR"
			mkdir -p $LOGDIR
		fi
		if [ ! -e $RESULTDIR ]; then
			echo "Create $RESULTDIR"
			mkdir -p $RESULTDIR
		fi

		if [ -f /usr/bin/time ]; then
		        QUIETSUPPORT=`/usr/bin/time --help | grep "quiet" | wc -l`
			if [ $QUIETSUPPORT -gt 0 ]; then
			    GETTIMESTATS="/usr/bin/time --quiet -f %E -o $FINALRESULTDIR/time.stats"
			else
			    GETTIMESTATS="/usr/bin/time -f %E -o $FINALRESULTDIR/time.stats"
			fi
		else
			GETTIMESTATS=""
		fi

		echo "prepare run_again" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log

		echo "#!/bin/sh" > $FINALRESULTDIR/run_again.sh

		# Final stage: valgrind-check and experiment evaluation
		if [ "x$USED_SIMULATOR" = "xns" ]; then
			echo "echo \"Running NS2\"" >> $FINALRESULTDIR/run_again.sh
			# check running NS with a memory debugger and profiler
			which valgrind > /dev/null 2> /dev/null
			if [ $? -ne 0 ]; then
				VALGRIND=0
			fi
			if [ "x$VALGRIND" = "x1" ]; then
				NS_FULL_PATH=`which ns`
				# run NS (under valgrind)
				#--track-origins=yes
				#--gen-suppressions=all
				#--suppressions=$DIR/../etc/ns/ns.supp
				if [ "x$NOSUPP" = "x1" ]; then
				  SUPPRESSION=""
				else
				  SUPPRESSION="--suppressions=$DIR/../etc/ns/ns.supp"
				fi

				echo "$GETTIMESTATS valgrind $SUPPRESSION --leak-resolution=high --leak-check=full --show-reachable=yes --log-file=$FINALRESULTDIR/valgrind.log $NS_FULL_PATH $TCLFILE > $LOGDIR/$LOGFILE  2>&1" >> $FINALRESULTDIR/run_again.sh
			else
				if [ "x$PROFILE" = "x1" ]; then
					NS_FULL_PATH=`which ns`
					echo "$GETTIMESTATS valgrind --tool=callgrind --collect-jumps=yes --callgrind-out-file=$FINALRESULTDIR/callgrind.out $NS_FULL_PATH $TCLFILE > $LOGDIR/$LOGFILE  2>&1" >> $FINALRESULTDIR/run_again.sh
				else
					if [ "x$GDB" = "x1" ]; then
						NS_FULL_PATH=`which ns`
						echo "run" > $FINALRESULTDIR/gdb.cmd
						( cd $FINALRESULTDIR; gdb -x gdb.cmd --args $NS_FULL_PATH $TCLFILE )
						rm -f $FINALRESULTDIR/gdb.cmd
						exit 0
					else
						echo "$GETTIMESTATS ns $TCLFILE > $LOGDIR/$LOGFILE 2>&1" >> $FINALRESULTDIR/run_again.sh
					fi
				fi
			fi
		else if [ "x$USED_SIMULATOR" = "xjist" ]; then
			echo "Running Jist" >> $FINALRESULTDIR/run_again.sh
			( cd $FINALRESULTDIR; $DIR/convert2jist.sh convert $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties )
			# run simulation with jist
			echo "$GETTIMESTATS $DIR/start-jist-sim.sh $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties > $LOGDIR/$LOGFILE 2>&1" >> $FINALRESULTDIR/run_again.sh
			#( cd $FINALRESULTDIR; $GETTIMESTATS $DIR/start-jist-sim.sh $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties > $LOGDIR/$LOGFILE 2>&1 )
		else #ns3
			echo "Running NS3"
			( cd $FINALRESULTDIR; $DIR/convert2ns3.sh convert $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX >> $FINALRESULTDIR/$NAME.cc )
			# run simulation with NS3
			if [ "x$NS3_HOME" != "x" ] && [ -e $NS3_HOME/ ]; then
			   ( rm -rf $NS3_HOME/scratch/$NAME; mkdir $NS3_HOME/scratch/$NAME; cp $FINALRESULTDIR/$NAME.cc $NS3_HOME/scratch/$NAME; cd $NS3_HOME; ./waf ) > $LOGDIR/ns3_build.log 2>&1
			   ( cd $NS3_HOME; ./waf --run $NAME > $LOGDIR/$LOGFILE 2>&1 ) > $LOGDIR/$LOGFILE 2>&1
			   ( cp $NS3_HOME/scratch/$NAME/* $FINALRESULTDIR ) >> $LOGDIR/ns3_build.log 2>&1
			fi
			exit 0
		fi
		fi

		#Prepare eval-script

		echo "#!/bin/sh" > $FINALRESULTDIR/eval_again.sh
		#echo "echo \"Evaluation...\"" >> $FINALRESULTDIR/eval_again.sh
		echo "MODE=sim SIM=$USED_SIMULATOR CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh 1>&$EVAL_LOG_OUT" >> $FINALRESULTDIR/eval_again.sh

		if [ "x$PREPARE_ONLY" = "x" ]; then
		  ( cd $FINALRESULTDIR; sh ./run_again.sh )
		fi

		# if the simulation was correctly execruted start the automatized evaluation of the experiment
		if [ $? -eq 0 ]; then
			if [ "x$DELAYEVALUATION" = "x" ] && [ "x$PREPARE_ONLY" = "x" ]; then
			  sh $FINALRESULTDIR/eval_again.sh
			fi
		else
			exit 1
		fi
		date +"%s:%N" >> $FINALRESULTDIR/time.log
	;;
esac

exit $?
