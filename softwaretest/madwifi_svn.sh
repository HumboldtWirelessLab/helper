#!/bin/sh

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

case "$SIGN" in
  "/")
	DIR=$dir
	PROG=$0
        ;;
  ".")
	DIR=$pwd/$dir
	PROG=$pwd/$0
	;;
   *)
	COMPLETEDIR=`which $0`
	echo $COMPLETEDIR
	if [ "x$COMPLETEDIR" = "x$0" ]; then
	    DIR=$pwd/$dir
	    PROG=$pwd/$0
	else
	    DIR=$(dirname "$COMPLETEDIR")
	    PROG=$COMPLETEDIR
	fi
	;;
esac

AC_MADWIFIREVISION=0
HIGHEST_MADWIFIREVISION=0

if [ "x$KERNELDIR" = "x" ]; then
    KERNELDIR=$DIR/linux-2.6.19.2/linux
else

    SIGN=`echo $KERNELDIR | cut -b 1`

    case "$SIGN" in
	"/")
    	    ;;
	*)
	    KERNELDIR=$pwd/$KERNELDIR
	    ;;
    esac

fi


if [ "x$MODULSDIR" = "x" ]; then
  MODULSDIR=$DIR/module
fi

get_revision() {
  AC_MADWIFIREVISION=`( cd $DIR/madwifi/; LANG=C svn info 2>&1 | grep "Revision" | awk '{print $2}' )`
  if [ "x$AC_MADWIFIREVISION" = "x" ]; then
    AC_MADWIFIREVISION=0
  fi

  return 0
}

get_remote_revision() {
  HIGHEST_MADWIFIREVISION=`( cd $DIR/madwifi/; LANG=C svn status -u 2>&1 | grep "revision" | tail -n 1 | awk '{print $4}' )`
  if [ "x$HIGHEST_MADWIFIREVISION" = "x" ]; then
    HIGHEST_MADWIFIREVISION=0
  fi

  return 0
}

checkout_revision() {
  get_remote_revision
  if [ $HIGHEST_MADWIFIREVISION -ge $1 ]; then
    ( cd $DIR/madwifi/; svn -r $1 up )
  fi
}

checkout_svn() {
  if [ ! -e $DIR/madwifi ]; then
    ( cd $DIR; svn checkout http://svn.madwifi.org/madwifi/trunk madwifi )
  else
    echo "Directory exists"
  fi
}

update_svn() {
  if [ -e $DIR/madwifi ]; then
    ( cd $DIR/madwifi; svn update )
  fi
}

build_svn() {
  if [ -e $DIR/madwifi ]; then
    if [ -e $KERNELDIR ]; then
      if [ ! "x$CPU" = "x" ]; then
	HAVEARCH=`cat $PROG | grep "#arch" | grep " $CPU" | wc -l`
	
	if [ $HAVEARCH -gt 0 ]; then
	    CROSS_COMPILE=`cat $PROG | grep "#arch" | grep " $CPU" | awk '{ print $3 }'`
	fi
      fi
    
      if [ "x$CROSS_COMPILE" = "x" ]; then
        ( cd $DIR/madwifi; make KERNELPATH=$KERNELDIR; )
      else
        ( cd $DIR/madwifi; make KERNELPATH=$KERNELDIR CROSS_COMPILE=$CROSS_COMPILE; )
      fi
    else
      echo "kernelsourece doesn't exist"
    fi
  else
    echo "SVN doesn't exist"
  fi
}

clean_svn() {
  if [ -e $DIR/madwifi ]; then
    ( cd $DIR/madwifi; make clean; )
  else
    echo "SVN doesn't exist"
  fi
}


install_svn_modules() {
  if [ -e $DIR/madwifi ]; then
    if [ ! -e $1 ]; then
      mkdir -p $1
    fi
    ( cd $DIR/madwifi; find . -name "*.ko" -print0 | xargs -0 cp --target=$1 )
  else
    echo "SVN doesn't exist"
  fi
}


case "$1" in
  "help")
	echo "use $0 initsvn | buildsvn | getrev | buildrev | installsvn | showrev | showremoterev | updatesvn | installlatest | installrev | cleansvn"
	echo "use MODULSDIR=/path/to/moduls to set modulstarget"
	echo "use REVISION=XXX to set revision"
	echo "use KERNELDIR=/path/to/linux to set the kerneldir"
	echo "use CPU=arch to set the Architecture"
	echo "use CROSS_COMPILE=compiler-prefix to setup cross-compiling ( e.g. "CROSS_COMPILE=arm-linux-" )"
	;;
  "initsvn")
        echo "Checkout svn"
        checkout_svn
	;;
  "buildsvn")
        echo "Build svn"
	build_svn
	;;
  "getrev")
        if [ "x$REVISION" = "x" ]; then
	  echo "use REVISION=xxx to set the wanted revision"
	  exit 0
	fi
	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
	echo -n "Check the highest available revision: "
	get_remote_revision
	echo "$HIGHEST_MADWIFIREVISION"
	echo -n "Check the actual revision: "
	get_revision
	echo "$AC_MADWIFIREVISION"
        echo "You want revision: $REVISION"
	if [ $REVISION -gt $HIGHEST_MADWIFIREVISION ]; then
	  echo "Wanted revision is not available !"
	  exit 0
	fi
	echo "Checkout revision $REVISION ..."
	checkout_revision $REVISION
	echo "done"
	;;
  "buildrev")
        if [ "x$REVISION" = "x" ]; then
	  echo "use REVISION=xxx to set the wanted revision"
          exit 0
        fi
	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
	
        REVISION=$REVISION $0 getrev
	echo "Build svn"
	build_svn
	;;
  "installsvn")
	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi

        echo "Install Modules to $MODULSDIR"
	install_svn_modules $MODULSDIR
	;;
  "updatesvn")
  	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
	echo "checkout latest revision"
        update_svn
        ;;
   "cleansvn")
  	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
	echo "Clean svn"
	clean_svn
	;;
   "installlatest")
  	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
	update_svn
	build_svn
	MODULSDIR=$MODULSDIR $0 installsvn
	;;
   "installrev")
	if [ "x$REVISION" = "x" ]; then
	  echo "use REVISION=xxx to set the wanted revision"
          exit 0
        fi
	
	HAVEREV=`cat $PROG | grep "#svnversion" | grep " $REVISION" | wc -l`
	
	if [ $HAVEREV -gt 0 ]; then
	    REVISIONDIR=`cat $PROG | grep "#svnversion" | grep " $REVISION" | awk '{ print $3 }'`
	    if [ ! -e $DIR/$REVISIONDIR ]; then
		echo "No $REVISIONDIR !"
		exit 0
	    fi
	    
	    if [ ! "x$CPU" = "x" ]; then
		HAVEARCH=`cat $PROG | grep "#arch" | grep " $CPU" | wc -l`
	
		if [ $HAVEARCH -gt 0 ]; then
		    CROSS_COMPILE=`cat $PROG | grep "#arch" | grep " $CPU" | awk '{ print $3 }'`
		fi
    	    fi

	    ( cd $DIR/$REVISIONDIR; make clean )
	    
    	    if [ "x$CROSS_COMPILE" = "x" ]; then
		( cd $DIR/$REVISIONDIR; make KERNELPATH=$KERNELDIR )
	    else
    		( cd $DIR/$REVISIONDIR; make KERNELPATH=$KERNELDIR  CROSS_COMPILE=$CROSS_COMPILE; )
	    fi
	    
	    ( cd $DIR/$REVISIONDIR; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
	    
	else
	    if [ ! -e $DIR/madwifi ]; then
		echo "No svn ! use '$0 initsvn' to setup the svn !"
		exit 0
	    fi

	    REVISION=$REVISION MODULSDIR=$MODULSDIR $0 cleansvn
	    REVISION=$REVISION MODULSDIR=$MODULSDIR KERNELDIR=$KERNELDIR CROSS_COMPILE=$CROSS_COMPILE $0 buildrev
	    REVISION=$REVISION MODULSDIR=$MODULSDIR $0 installsvn
	fi
	
	;;
   "showrev")
	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
        get_revision
	echo "$AC_MADWIFIREVISION"
	;;
   "showremoterev")
	if [ ! -e $DIR/madwifi ]; then
	  echo "No svn ! use '$0 initsvn' to setup the svn !"
	  exit 0
	fi
        get_remote_revision
	echo "$HIGHEST_MADWIFIREVISION"
	;;
     *)
        $0 help
	;;
esac

exit 0

#help 

#svnversion ubi		madwifi-dfs-r3319-20080201
#svnversion 0.9.1	release-0.9.1
#svnversion brn-0.9.1	brn-madwifi-0.9.1
#svnversion brn-0.9.3	brn-madwifi-0.9.3
#svnversion mad-0.9.1	madwifi-0.9.1
#svnversion mad-0.9.2.1	madwifi-0.9.2.1
#svnversion k-07	kamikaze-7.07
#svnversion k-trunk	kamikaze-trunk
#svnversion b105	madwifi-branch/madwifi-hal-0.10.5.6
#svnversion t094	madwifi-tags/release-0.9.4
#arch mips mipsel-linux-
