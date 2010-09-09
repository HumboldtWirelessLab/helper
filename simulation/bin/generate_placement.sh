#!/bin/sh

#echo "Placement: $1" >&2

case "$1" in
    "random")
          NODES=`cat $2 | grep -v "#" | awk '{print $1}' | sort -u`
          NODECOUNT=`echo $NODES | wc -w`
          for n in $NODES; do
	    N=`head -1 /dev/urandom | od -N 2 -t uL | head -n 1 | awk '{print $2}'`
	    X=`expr $N % $3`
	    N=`head -1 /dev/urandom | od -N 2 -t uL | head -n 1 | awk '{print $2}'`
	    Y=`expr $N % $3`
	    echo "$n $X $Y 0"
	  done
	  ;;
    "grid")
          NODES=`cat $2 | grep -v "#" | awk '{print $1}' | sort -u`
          NODECOUNT=`echo $NODES | wc -w`
          SIDELEN=`echo "sqrt($NODECOUNT)" | bc`
	  SLSQR=`expr $SIDELEN \* $SIDELEN`
	  #echo "NODECOUNT: $NODECOUNT  SLSQR: $SLSQR"
	  if [ $SLSQR -lt $NODECOUNT ]; then
	    SIDELEN=`expr $SIDELEN + 1`
	  fi
	  
	  #echo "SL: $SIDELEN"
	  
	  NODEN=0
	  SIDESTEP=`expr $3 / \( $SIDELEN - 1 \)`
	  #echo "ST: $SIDESTEP"
	  for n in $NODES; do
	    X=`expr \( $NODEN % $SIDELEN \) \* $SIDESTEP`
	    Y=`expr \( $NODEN / $SIDELEN \) \* $SIDESTEP`
	    echo "$n $X $Y 0"
	    NODEN=`expr $NODEN + 1`
	  done
          ;;
       *)
          echo "Use $0 random|grid nodefile fieldsize (distance)"
          ;;
esac   

exit 0;
