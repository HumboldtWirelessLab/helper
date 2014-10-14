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
  DESFILE=`ls *.des.sim`
else
  DESFILE=$1
fi

. $DESFILE

if [ "x$USED_SIMULATOR" = "x" ]; then
  USED_SIMULATOR=$DEFAULT_USED_SIMULATOR
fi

if [ "x$VALGRIND" = "x" ]; then
  VALGRIND=$DEFAULT_VALGRIND
fi

if [ "x$NOSUPP" = "x" ]; then
  NOSUPP=$DEFAULT_NOSUPP
fi

if [ "x$GDB" = "x" ]; then
  GDB=$DEFAULT_GDB
fi

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
			GETTIMESTATS="/usr/bin/time --quiet -f %E -o $RESULTDIR/time.stats"
	else
			GETTIMESTATS="/usr/bin/time -f %E -o $RESULTDIR/time.stats"
	fi
else
	GETTIMESTATS=""
fi

# Final stage: valgrind-check and experiment evaluation
if [ "x$USED_SIMULATOR" = "xns" ]; then
  TCLFILE=$NAME.tcl

	echo "Running NS2"
	
	# check running NS with a memory debugger and profiler
	which valgrind > /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then
		VALGRIND=0
	fi

	PRE_CMD=""
	NS_CMD=""
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

		NS_CMD="$GETTIMESTATS valgrind $SUPPRESSION --leak-resolution=high --leak-check=full --show-reachable=yes --log-file=$FINALRESULTDIR/valgrind.log $NS_FULL_PATH $TCLFILE"
	elif [ "x$PROFILE" = "x1" ]; then
		NS_FULL_PATH=`which ns`
		NS_CMD="$GETTIMESTATS valgrind --tool=callgrind --collect-jumps=yes --callgrind-out-file=$RESULTDIR/callgrind.out $NS_FULL_PATH $TCLFILE"
	elif [ "x$GDB" = "x1" ]; then
		NS_FULL_PATH=`which ns`
		echo "run" > $RESULTDIR/gdb.cmd
		( cd $RESULTDIR; gdb -x gdb.cmd --args $NS_FULL_PATH $TCLFILE )
		rm -f $ESULTDIR/gdb.cmd
		exit 0
	else
		NS_CMD="$GETTIMESTATS ns $TCLFILE"
	fi

	if [ "x$PROGRESS" != "x" ]; then
		set -o pipefail
		${NS_CMD} 2>&1 | tee $LOGDIR/$LOGFILE | $DIR/sim_progress_bar.py --max-time=${TIME}
	else
		${NS_CMD} > $LOGDIR/$LOGFILE 2>&1
	fi

  exit $?

else if [ "x$USED_SIMULATOR" = "xjist" ]; then
	# run simulation with jist
	if [ "x$JISTBASEDIR" = "x" ]; then
    JISTBASEDIR=$BRN_TOOLS_PATH/brn.sim
  fi

  JISTCLICK_HOME=$JISTBASEDIR/brn.jist.click
  export CLICK_HOME=$BRN_TOOLS_PATH/click-brn
  export JISTCOMMON_HOME=$JISTBASEDIR/brn.jist
  export JISTCLICK_HOME=$JISTBASEDIR/brn.jist.click
  export JIST_HOME=$JISTBASEDIR/jist.swans

  (cd $JISTCLICK_HOME; $GETTIMESTATS ant run -Drun.class=brn.sim.scenario.jistsimulation.JistSimulation -Drun.args="$RESULTDIR/$NAME.jist.properties"; RESULT=$?) | grep "\[java\]" | grep -v "Controller:INFO:" | sed "s#^[[:space:]]*\[java\][[:space:]]##g" > $LOGDIR/$LOGFILE 2>&1

  exit $RESULT

else #ns3
	# run simulation with NS3
	if [ "x$NS3_HOME" != "x" ] && [ -e $NS3_HOME/ ]; then
		 ( rm -rf $NS3_HOME/scratch/$NAME; mkdir $NS3_HOME/scratch/$NAME; cp $RESULTDIR/$NAME.cc $NS3_HOME/scratch/$NAME; cd $NS3_HOME; ./waf ) > $LOGDIR/ns3_build.log 2>&1
		 ( cd $NS3_HOME; ./waf --run $NAME > $LOGDIR/$LOGFILE 2>&1 ) > $LOGDIR/$LOGFILE 2>&1
		 ( cp $NS3_HOME/scratch/$NAME/* $RESULTDIR ) >> $LOGDIR/ns3_build.log 2>&1
	fi
	exit 0
fi
fi
