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

if [ "x$1" = "xhelp" ]; then
  echo "Use $0 no_node clickfile runtime fieldsize"
  exit 0
fi

echo "#NODE DEVICE MODULSDIR MODOPTIONS WIFICONFIG CLICKMODDIR CLICKSCRIPT CLICKLOGFILE APPLICATION APPLICATIONLOGFILE" > simulation.mes

for i in `seq $1`; do
  echo "node$i ath0 - - monitor.default - CONFIGDIR/$2 node$i.log - -" >> simulation.mes
done

cat > simulation.dis << EOF
NAME=simulation
SIMULATOR=ns2
RADIO=shadowing11b
FORGEINNODES=no

TIME=$3

CLICKMODE=kernel

NODETABLE=simulation.mes

NODEPLACEMEN=RANDOM
NODEPLACEMENTFILE=NONE

FIELDSIZE=$4

LOGDIR=WORKDIR
LOGFILE=measurement.log

RESULTDIR=WORKDIR
EVALUATIONSDIR=WORKDIR
EVALUATIONSDIRPOSTFIX=_evaluation

GPS=no
NOTICE=no
LOS=no

EOF

exit 0
