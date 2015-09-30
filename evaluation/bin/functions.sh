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


function matwrapper {

  which matlab > /dev/null 2>&1
  NO_MATLAB=$?

  which octave > /dev/null 2>&1
  NO_OCTAVE=$?

  if [ $NO_MATLAB -eq 0 ]; then
    #matlab -nodesktop -nosplash -nojvm -nodisplay -r "$@" > /dev/null 2>&1
    matlab -nodesktop -nosplash -nodisplay -r "$@" > /dev/null 2>&1
  else
    if [ $NO_OCTAVE -eq 0 ]; then
      octave -qf --eval "$@" > /dev/null 2>&1
    else
      echo "Matlab/Ocatve not found!"
      exit 1
    fi

  fi

}

function calculate {
 which calc > /dev/null 2>&1

 if [ $? -eq 0 ]; then
   calc $@
 else
   COMMAND="print "$@
   echo $COMMAND | perl
   echo ""
 fi

}

function get_cpu_count {
  NO_CPUS=`cat /proc/cpuinfo | grep processor | wc -l`

  if [ "x$MAX_NO_CPUS" != "x" ]; then
    if [ $MAX_NO_CPUS -lt $NO_CPUS ]; then
      NO_CPUS=$MAX_NO_CPUS
    fi
  fi

  echo $NO_CPUS
}
