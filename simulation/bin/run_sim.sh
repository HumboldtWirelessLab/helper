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
DESCRIPTIONFILE_TIME="$TIME"

FINALRESULTDIR=`echo $RESULTDIR | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`


# check for result directory
if [ "x$NOSUBDIR" = "x" ]; then
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
fi

if [ ! -e $FINALRESULTDIR ]; then
  mkdir $FINALRESULTDIR
fi

chmod 777 $FINALRESULTDIR

MODE=sim

case "$MODE" in
	"sim")
		POSTFIX=sim

		DESCRIPTIONFILENAME=`basename $DESCRIPTIONFILE`

		if [ "x$NODEPLACEMENT" != "xfile" ]; then
			cat $DESCRIPTIONFILE | sed -e "s#[[:space:]]*NODEPLACEMENTFILE[[:space:]]*=.*##g" -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
			
			#make sure that there is a end of line
			echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		
			echo "NODEPLACEMENTFILE=$FINALRESULTDIR/placementfile.plm" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		else
			cat $DESCRIPTIONFILE | sed -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

			#make sure that there is a end of line
			echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		fi


		if [ "x$NODEPLACEMENT" = "x" ]; then
			echo "use default plm"
			NODEPLACEMENT="random"
		fi
		if [ "x$FIELDSIZE" = "x" ]; then
			FIELDSIZE=1000
		fi

		if [ "x$NODEPLACEMENT" != "xfile" ]; then
			if [ "x$NODEPLACEMENTFILE" = "x" ]; then
				FINALPLMFILE=$FINALRESULTDIR/placementfile.plm
			else
				FINALPLMFILE=$FINALRESULTDIR/$NODEPLACEMENTFILE
			fi
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
			
			if [ ! -e $FINALRESULTDIR/$NODEPLACEMENTFILE ]; then
				cp $FINALPLMFILE $FINALRESULTDIR/$NODEPLACEMENTFILE
			fi
			FINALPLMFILE=$FINALRESULTDIR/$NODEPLACEMENTFILE
		fi

		echo "gen clickfile" >> $FINALRESULTDIR/time.log
		date +"%s:%N" >> $FINALRESULTDIR/time.log
		
		DUMPFILEDIR=$DUMPFILEDIR USED_SIMULATOR=$USED_SIMULATOR CONFIGDIR=$CONFIGDIR POSTFIX=$POSTFIX NODEPLACEMENTFILE=$FINALPLMFILE $DIR/prepare-sim.sh prepare $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

#		echo "run_sim" >> $FINALRESULTDIR/time.log
#		date +"%s:%N" >> $FINALRESULTDIR/time.log

		mv $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		grep -v "NODEPLACEMENTFILE" $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp | sed -e "s#$NODETABLE#$FINALRESULTDIR/$NODETABLE.$POSTFIX#g" > $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "NODEPLACEMENTFILE=$FINALPLMFILE" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		rm $FINALRESULTDIR/$DESCRIPTIONFILENAME.tmp

		SIMDES=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		. $SIMDES

		if  [ "x$USED_SIMULATOR" = "xjist" ]; then
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

		NODELIST=`grep -v "#" $NODETABLE | awk '{print $1}' | uniq`
		NODECOUNT=`grep -v "#" $NODETABLE | wc -l`

#		echo "gen placement" >> $FINALRESULTDIR/time.log
#		date +"%s:%N" >> $FINALRESULTDIR/time.log

		if [ "x$NODEPLACEMENT" != "xfile" ]; then
			TOPORXRANGE=$MAXRXRANGE
			NODEPLACEMENTOPTS="$NODEPLACEMENTOPTS" RXRANGE=$TOPORXRANGE $DIR/generate_placement.sh $NODEPLACEMENT $NODETABLE $FIELDSIZE > $FINALPLMFILE
		fi

#		echo "gen placement (get max)" >> $FINALRESULTDIR/time.log
#		date +"%s:%N" >> $FINALRESULTDIR/time.log

		POS_X_MAX=`awk '{print $2}' $FINALPLMFILE | sort -n | tail -n 1`
		POS_Y_MAX=`awk '{print $3}' $FINALPLMFILE | sort -n | tail -n 1`
		POS_Z_MAX=`awk '{print $4}' $FINALPLMFILE | sort -n | tail -n 1`

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

    echo -e "POS_X_MAX=$POS_X_MAX\nPOS_Y_MAX=$POS_Y_MAX\nPOS_Z_MAX=$POS_Z_MAX" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		if [ "x$RESULTDIR" = "x" ]; then
			RESULTDIR=.
		fi

		$DIR/generate_nodesmac.py --node-list-file=$NODETABLE --name2mac=$NAME2MAC > $FINALRESULTDIR/nodes.mac

		if [ "x$USED_SIMULATOR" = "xns" ]; then
			
			echo "gen ns" >> $FINALRESULTDIR/time.log
			date +"%s:%N" >> $FINALRESULTDIR/time.log
			
			DESCRIPTIONFILENAME=$FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX PLMFILE=$FINALPLMFILE NODECOUNT=$NODECOUNT NODELIST="$NODELIST" $DIR/convert2ns.sh
			
			echo "gen nsfin" >> $FINALRESULTDIR/time.log
			date +"%s:%N" >> $FINALRESULTDIR/time.log
			
		else if [ "x$USED_SIMULATOR" = "xjist" ]; then
  		
  		if [ "x$CONTROLFILE" != "x" ]; then
				echo -n "handler.script = " > $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
				$DIR/decode_ctl.py --control-file="${CONTROLFILE}" --tcl-file="$TCLFILE" --node-list="${NODELIST}" --used-simulator=${USED_SIMULATOR} --node-to-click-map-file=$NODETABLE --node-to-num-map-file=$FINALRESULTDIR/nodes.mac --jist-property-file="$FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties"
				echo "" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties
			fi

			(cd $FINALRESULTDIR; $DIR/convert2jist.sh convert $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.jist.properties )
		
		else #ns3
	    ( cd $FINALRESULTDIR; $DIR/convert2ns3.sh convert $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX >> $FINALRESULTDIR/$NAME.cc )
	  fi
	  fi
	  
		#echo "Finish setup"

		echo "CONFIGDIR=$CONFIGDIR" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "DEFAULT_USED_SIMULATOR=$USED_SIMULATOR" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "DEFAULT_VALGRIND=$VALGRIND" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "DEFAULT_NOSUPP=$NOSUPP" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX
		echo "DEFAULT_GDB=$GDB" >> $FINALRESULTDIR/$DESCRIPTIONFILENAME.$POSTFIX

		if [ "x$PREPARE_ONLY" = "x" ]; then
		  ( cd $FINALRESULTDIR; run_again.sh )
		fi

		# if the simulation was correctly execruted start the automatized evaluation of the experiment
		if [ $? -eq 0 ]; then
			if [ "x$DELAYEVALUATION" = "x" ] && [ "x$PREPARE_ONLY" = "x" ]; then
			  ( cd $FINALRESULTDIR; eval_again.sh )
			fi
		else
			exit 1
		fi

	;;
esac

exit $?
