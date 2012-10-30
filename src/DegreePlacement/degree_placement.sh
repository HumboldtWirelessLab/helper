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

#echo "Placement: $1" >&2


if [ "x$1" = "xhelp" ]; then
  echo "$0 no_nodes radius degree field_size"
  exit 0
fi

NODES=""

for i in `seq $1`; do
  NODES="$NODES node$i"
done

NODECOUNT=`echo $NODES | wc -w`
java -classpath $DIR/bin/production/DegreePlacement:$DIR/lib/jargs.jar DegreePlacementGenerator -n $NODECOUNT -r $2 -d $3 -x $4 -y $4

exit 0;
