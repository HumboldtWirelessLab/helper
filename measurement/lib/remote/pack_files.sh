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

case "$1" in
    "pack")
	ARCH=`cat $2 | awk '{print $1}' | sort -u`
	BASEDIR=`(cd $DIR/../../..; pwd)`
	PACK_BASEDIR=/tmp/pack_files/
	PACK_DIR=$PACK_BASEDIR/$BASEDIR
	PACK_FILE=pack_file.tar.bz2
	PACK_LOG=/dev/null
	
	rm -rf $PACK_BASEDIR
	mkdir -p $PACK_DIR
	BASEDIR=`(cd $DIR/../../..; pwd)`
	echo "$BASEDIR" >> $PACK_DIR/info
	cp -r $BASEDIR/nodes/ $PACK_DIR/
	
	#CLICK and modules
	#TODO: next more general
	rm -rf $PACK_DIR/nodes/lib/modules
	rm -f $PACK_DIR/nodes/bin/click-*
	rm -f $PACK_DIR/nodes/bin/click-align*
#	echo $ARCH
	for a in $ARCH; do
	    ISX86=`echo "i386 i486 i586 i686" | grep $a | wc -l`
	    if [ $ISX86 -ne 0 ]; then
	      SUFFIX="-$a"
	      NEWSUFFIX="-i386"
	      PREFIX="i386-linux-"
	    else
	      if [ "x$a" = "xnone" ]; then
	        SUFFIX=""
		NEWSUFFIX=""
		PREFIX=""
	      else
	        SUFFIX="-$a"
	        NEWSUFFIX="-$a"
	        PREFIX="$a-linux-"
	      fi
	    fi

	    HASSTRIP=`which $PREFIX\strip 2> /dev/null | wc -l`
	    if [ -f $BASEDIR/nodes/bin/click$SUFFIX ]; then
	      cp -L $BASEDIR/nodes/bin/click$SUFFIX $PACK_DIR/nodes/bin/click$NEWSUFFIX
	      if [ $HASSTRIP -ne 0 ]; then
	        $PREFIX\strip --strip-unneeded $PACK_DIR/nodes/bin/click$NEWSUFFIX
	      fi
	      if [ "$NEWSUFFIX" = "-i386" ]; then
	        ln -s click-i386 $PACK_DIR/nodes/bin/click-i486
	        ln -s click-i386 $PACK_DIR/nodes/bin/click-i586
	        ln -s click-i386 $PACK_DIR/nodes/bin/click-i686
	      fi
	    fi	
	    if [ -f $BASEDIR/nodes/bin/click-align$SUFFIX ]; then
	      cp -L $BASEDIR/nodes/bin/click-align$SUFFIX $PACK_DIR/nodes/bin/click-align$NEWSUFFIX
	      if [ $HASSTRIP -ne 0 ]; then
	        $PREFIX\strip --strip-unneeded $PACK_DIR/nodes/bin/click-align$NEWSUFFIX
	      fi
	      if [ "$NEWSUFFIX" = "-i386" ]; then
	        ln -s click-align-i386 $PACK_DIR/nodes/bin/click-align-i486
	        ln -s click-align-i386 $PACK_DIR/nodes/bin/click-align-i586
	        ln -s click-align-i386 $PACK_DIR/nodes/bin/click-align-i686
	      fi
	    fi

	    MODULES=`cat $2 | grep $a | awk '{print $2}'`

	    for m in $MODULES; do
	      mkdir -p $PACK_DIR/nodes/lib/modules/$a/
	      cp -r $BASEDIR/nodes/lib/modules/$a/$m $PACK_DIR/nodes/lib/modules/$a/
	    done
	done
	
	if [ "x$3" != "x" ] & [ "x$4" != "x" ]; then

#	    echo "pack files"
	    mkdir -p $PACK_DIR/measurement/bin/

	    NODES=`cat $3 | awk '{print $1}'`

	    for n in $NODES; do
		WIFIFILE=`cat $4 | grep $n | awk '{print $5}'`
		CLICKFILE=`cat $4 | grep $n | awk '{print $7}'`
#		echo "$n $WIFIFILE $CLICKFILE"

		NEXT_BASEDIR=`dirname $WIFIFILE`
		mkdir -p $PACK_BASEDIR/$NEXT_BASEDIR
		NEXT_BASEDIR=`dirname $CLICKFILE`
		mkdir -p $PACK_BASEDIR/$NEXT_BASEDIR

		cp $WIFIFILE $PACK_BASEDIR/$WIFIFILE
		cp $CLICKFILE $PACK_BASEDIR/$CLICKFILE
	    done

	    rm -rf $PACK_DIR/measurement/
	fi

	
	(cd $PACK_BASEDIR/; tar cfvj ../$PACK_FILE *) > $PACK_LOG 2>&1
	cp $PACK_BASEDIR/../$PACK_FILE .
	#rm -rf $PACK_DIR

        ;;
    *)
	echo "Use $0 pack"
	;;
esac

exit 0
