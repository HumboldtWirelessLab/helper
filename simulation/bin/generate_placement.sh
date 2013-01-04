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

case "$1" in
    "random")
          NODES=`cat $2 | grep -v "#" | awk '{print $1}' | uniq`
          NODECOUNT=`echo $NODES | wc -w`
    
	  if [ "x$NODEPLACEMENTOPTS" = "xrelative" ]; then
	    NODEDIST=$3
	    SIDELEN=`echo "sqrt(${NODECOUNT})*${NODEDIST}" | bc`
	  else
	    SIDELEN=$3
	  fi
    
          for n in $NODES; do
	    N=`head -1 /dev/urandom | od -N 2 -t uL | head -n 1 | awk '{print $2}'`
	    X=`expr $N % $SIDELEN`
	    N=`head -1 /dev/urandom | od -N 2 -t uL | head -n 1 | awk '{print $2}'`
	    Y=`expr $N % $SIDELEN`
	    echo "$n $X $Y 0"
	  done
	  ;;
    "grid")
          NODES=`cat $2 | grep -v "#" | awk '{print $1}' | uniq`
          NODECOUNT=`echo $NODES | wc -w`
          SIDELEN=`echo "sqrt($NODECOUNT)" | bc`
	  SLSQR=`expr $SIDELEN \* $SIDELEN`
	  #echo "NODECOUNT: $NODECOUNT  SLSQR: $SLSQR"
	  if [ $SLSQR -lt $NODECOUNT ]; then
	    SIDELEN=`expr $SIDELEN + 1`
	  fi
	  
	  #echo "SL: $SIDELEN"
	  
	  NODEN=0
	  if [ "x$NODEPLACEMENTOPTS" = "xrelative" ]; then
	    SIDESTEP=$3
	  else
	    if [ $SIDELEN -eq 1 ]; then
	      SIDESTEP=$3
	    else
	      SIDESTEP=`expr $3 / \( $SIDELEN - 1 \)`
	    fi
	  fi
	  #echo "ST: $SIDESTEP"
	  for n in $NODES; do
	    X=`expr \( $NODEN % $SIDELEN \) \* $SIDESTEP`
	    Y=`expr \( $NODEN / $SIDELEN \) \* $SIDESTEP`
	    echo "$n $X $Y 0"
	    NODEN=`expr $NODEN + 1`
	  done
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
    "string")
          NODES=`cat $2 | grep -v "#" | awk '{print $1}' | uniq`
          NODECOUNT=`echo $NODES | wc -w`
	  NODEN=0

	  if [ "x$NODEPLACEMENTOPTS" = "xrelative" ]; then
	    SIDESTEP=$3
	  else
	    if [ $NODECOUNT -eq 1 ]; then
	      SIDESTEP=$3
	    else
	      SIDESTEP=`expr $3 / \( $NODECOUNT - 1 \)`
	    fi
	  fi

  	  Y=`expr $3 / 2`

	  for n in $NODES; do
	    X=`expr $NODEN \* $SIDESTEP`
	    echo "$n $X $Y 0"
	    NODEN=`expr $NODEN + 1`
	  done	  
	  ;;
       *)
          echo "Use $0 random|grid|npart nodefile fieldsize (distance)"
          ;;
esac   

exit 0;
