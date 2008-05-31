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


AC_MADWIFIREVISION=0
HIGHEST_MADWIFIREVISION=0

if [ "x$KERNELDIR" = "x" ]; then
  KERNELDIR=linux-2.6.19.2/linux
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
  HIGHEST_MADWIFIREVISION=`( cd $DIR/madwifi/; LANG=C svn status -u 2>&1 | grep "revision" | awk '{print $4}' )`
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
    if [ -e $DIR/$KERNELDIR ]; then
      if [ "x$CROSS_COMPILE" = "x" ]; then
        ( cd $DIR/madwifi; make KERNELPATH=$DIR/$KERNELDIR; )
      else
        ( cd $DIR/madwifi; make KERNELPATH=$DIR/$KERNELDIR CROSS_COMPILE=$CROSS_COMPILE; )
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
    #( cd $DIR/madwifi; make DESTDIR=$1 KERNELPATH=$DIR/$KERNELDIR install-modules)
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
	case "$REVISION" in
	    "0.9.1")
		    if [ ! -e $DIR/release-0.9.1 ]; then
			echo "No release-0.9.1 !"
		        exit 0
		    fi
		    ( cd $DIR/release-0.9.1; make clean );
		    ( cd $DIR/release-0.9.1; make KERNELPATH=$DIR/$KERNELDIR );
		    ( cd $DIR/release-0.9.1; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
		    ;;
	    "brn-0.9.3")
		    if [ ! -e $DIR/brn-madwifi-0.9.3 ]; then
			echo "No brn-madwifi-0.9.3 !"
		        exit 0
		    fi
		    ( cd $DIR/brn-madwifi-0.9.3; make clean );
		    ( cd $DIR/brn-madwifi-0.9.3; make KERNELPATH=$DIR/$KERNELDIR );
		    ( cd $DIR/brn-madwifi-0.9.3; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
		    ;;
	    "brn-0.9.1")
		    if [ ! -e $DIR/brn-madwifi-0.9.1 ]; then
			echo "No brn-madwifi-0.9.1 !"
		        exit 0
		    fi
		    ( cd $DIR/brn-madwifi-0.9.1; make clean );
		    ( cd $DIR/brn-madwifi-0.9.1; make KERNELPATH=$DIR/$KERNELDIR );
		    ( cd $DIR/brn-madwifi-0.9.1; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
		    ;;
	    "mad-0.9.1")
		    if [ ! -e $DIR/madwifi-0.9.1 ]; then
			echo "No madwifi-0.9.1 !"
		        exit 0
		    fi
		    ( cd $DIR/madwifi-0.9.1; make clean );
		    ( cd $DIR/madwifi-0.9.1; make KERNELPATH=$DIR/$KERNELDIR );
		    ( cd $DIR/madwifi-0.9.1; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
		    ;;
	    "mad-0.9.2.1")
		    if [ ! -e $DIR/madwifi-0.9.2.1-modified ]; then
			echo "No madwifi-0.9.2.1-modified !"
		        exit 0
		    fi
		    ( cd $DIR/madwifi-0.9.2.1-modified; make clean );
		    ( cd $DIR/madwifi-0.9.2.1-modified; make KERNELPATH=$DIR/$KERNELDIR );
		    ( cd $DIR/madwifi-0.9.2.1-modified; find . -name "*.ko" -print0 | xargs -0 cp --target=$MODULSDIR );
		    ;;
		*)
		    if [ ! -e $DIR/madwifi ]; then
			echo "No svn ! use '$0 initsvn' to setup the svn !"
			exit 0
		    fi

		    REVISION=$REVISION MODULSDIR=$MODULSDIR $0 cleansvn
		    REVISION=$REVISION MODULSDIR=$MODULSDIR KERNELDIR=$KERNELDIR CROSS_COMPILE=$CROSS_COMPILE $0 buildrev
		    REVISION=$REVISION MODULSDIR=$MODULSDIR $0 installsvn
		    ;;
	esac
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

#svnversion 0.9.1 release-0.9.1
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion
#svnversion

#svnversion
#svnversion
#svnversion
