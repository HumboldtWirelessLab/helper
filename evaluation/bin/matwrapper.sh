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

which matlab > /dev/null 2>&1
NO_MATLAB=$?

which octave > /dev/null 2>&1
NO_OCTAVE=$?

if [ $NO_MATLAB -eq 0 ]; then
  matlab -nodesktop -nosplash -nojvm -nodisplay -r "$@" > /dev/null 2>&1
else
  if [ $NO_OCTAVE -eq 0 ]; then
    octave -q --eval "$@" > /dev/null 2>&1
  else
    echo "Matlab/Ocatve not found!"
    exit 1
  fi

fi