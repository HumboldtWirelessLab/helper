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


function comp_cat {
  if [ -f $1 ]; then
    GZIP=`file $1 | grep gzip | wc -l`

    if [ $GZIP -ne 0 ]; then
      gunzip --stdout $1
    else
      BZ2=`file $1 | grep bzip2 | wc -l`

      if [ $BZ2 -ne 0 ]; then
        bzcat $1
      else
        XZ=`file $1 | grep XZ | wc -l`

        if [ $XZ -ne 0 ]; then
          xzcat $1
        else
          cat $1
        fi
      fi
    fi
  else
    if [ -f $1.gz ]; then
      gunzip --stdout $1.gz
    elif [ -f $1.bz2 ]; then
       bzcat $1.bz2
    elif [ -f $1.xz ]; then
      xzcat $1.xz
    else
      echo "$0: $1 not found."
    fi
  fi
}
