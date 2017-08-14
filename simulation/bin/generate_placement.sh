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

FAILURELOG=/dev/shm/plm.log
FAILURELOG=/dev/null

echo $1 >> $FAILURELOG

if [ "x$NODEPLACEMENTOPTS" = "xrelative" ]; then
  RELATIVE=1
else
  RELATIVE=0
fi

if [ "x$SEED" = "x" ]; then
  SEED="-1"
fi


case "$1" in
    "random")
	  $DIR/generate_placement.py --node-list-file=$2 --placement=random --sidelen=$3 --relative=$RELATIVE --seed=$SEED
	  ;;
    "grid")
	  $DIR/generate_placement.py --node-list-file=$2 --placement=grid --sidelen=$3 --relative=$RELATIVE
          ;;
    "gridrand")
	  $DIR/generate_placement.py --node-list-file=$2 --placement=gridrand --sidelen=$3 --relative=$RELATIVE  --seed=$SEED
          ;;
    "string")
	  $DIR/generate_placement.py --node-list-file=$2 --placement=string --sidelen=$3 --relative=$RELATIVE
	  ;;
    "npart")
	  NODES=`cat $2 | grep -v "#" | awk '{print $1"\n"}' | uniq`
          NODECOUNT=`echo $NODES | wc -w`
	  REPLACE=`cat $2 | grep -v "#" | awk '{print " -e s#node_" NR - 1 "[[:space:]]#"$1";#g"}' | sed 's/$/ /' | tr -d '\n'`
	  #REPLACE=`cat $2 | grep -v "#" | awk '{print " \"s#node_" NR - 1 " #"$1" #g\""}'`
	  #echo "$REPLACE"
	  NPART_DIR="$DIR/../../src/Npart"
	  (cd $NPART_DIR; RXRANGE=$RXRANGE ./gen_topo.sh $NODECOUNT | sed $REPLACE | sed "s#;# #g")
	  ;;
    "degree")
	  NODES=`cat $2 | grep -v "#" | awk '{print $1"\n"}' | uniq`
          NODECOUNT=`echo $NODES | wc -w`
	  REPLACE=`cat $2 | grep -v "#" | awk '{print " -e s#node_" NR - 1 "[[:space:]]#"$1";#g"}' | sed 's/$/ /' | tr -d '\n'`
	  #REPLACE=`cat $2 | grep -v "#" | awk '{print " \"s#node_" NR - 1 " #"$1" #g\""}'`
	  #echo "$REPLACE"
	  DEGREE_DIR="$DIR/../../src/DegreePlacement"
	  java -classpath $DEGREE_DIR/bin/production/DegreePlacement:$DEGREE_DIR/lib DegreePlacementGenerator -n $NODECOUNT -r $3 -d 4 -x 1000 -y 1000
	  ;;
       *)
          if [ -f $1 ]; then
            NODES=`cat $2 | grep -v "#" | awk '{print $1}' | uniq` | tee -a $FAILURELOG
            NODEPLACEMENTOPTS=$NODEPLACEMENTOPTS sh $1 $2 $3 | tee -a $FAILURELOG
          else
            echo "Use $0 random|grid|npart|string|degree nodefile fieldsize (distance)" >> $FAILURELOG
          fi
          ;;
esac

exit 0;
