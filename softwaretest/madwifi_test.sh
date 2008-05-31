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

STATUSFD=5

if [ "x$STARTREVISION" = "x" ]; then
  STARTREVISION=1
fi

MAXREVISION=`$DIR/madwifi_svn.sh showremoterev`

if [ "x$ENDREVISION" = "x" ]; then
  ENDREVISION=$MAXREVISION
fi

if [ "x$LOGDIR" = "x" ]; then
  LOGDIR=$DIR/log
fi

if [ ! -e $LOGDIR ]; then
  mkdir -p $LOGDIR
fi

test_parameters() {
  if [ "x$MODULSDIR" = "x" ]; then
    echo "Please set MODULSDIR"
    exit 0
  fi

  if [ "x$TESTSCRIPT" = "x" ]; then
    echo "Please set TESTSCRIPT"
    exit 0
  fi
}

test_revision() {
	MAXREVISION=`$DIR/madwifi_svn.sh showremoterev`
        if [ "x$MAXREVISION" = "x" ]; then
	  echo "Error on svn"
	  exit 0
	fi
	if [ $ENDREVISION -lt $STARTREVISION ]; then
	  echo "Endrevision is lower than start"
	  exit 0
	fi
	if [ $ENDREVISION -gt $MAXREVISION ]; then
	  echo "Endrevision is greater than latest"
	  exit 0
	fi
}

install_revision() {
	REVISION=$1 MODULSDIR=$MODULSDIR $DIR/madwifi_svn.sh installrev
}

clean_revision() {
	$DIR/madwifi_svn.sh cleansvn
	rm -f $MODULSDIR/*
}


case "$1" in
  "help")
	echo "use $0 minok | minfailed | complete | completedown | single"
	echo "Set parameter MODULSDIR TESTSCRIPT STARTREVISION ENDREVISION LOGDIR" 
	;;
  "minok")
        test_parameters
        test_revision
	echo "Check for first working version"
	echo "Revision: $STARTREVISION -> $ENDREVISION"
	echo "Check for first working version in revisions $STARTREVISION -> $ENDREVISION" > $LOGDIR/test.log
	AC_STARTREVISION=$STARTREVISION
	AC_ENDREVISION=$ENDREVISION
	FOUND=0
		
	while [ $FOUND -eq 0 ]; do
	    AC_REVISION=`expr \( $AC_STARTREVISION + $AC_ENDREVISION \) / 2`
	
	    STATUS=`cat $LOGDIR/test.log | grep "^$AC_REVISION " | awk '{print $2}'`
	    
	    if [ "x$STATUS" = "x" ]; then
	        echo "Test Revision $AC_REVISION"
    		install_revision $AC_REVISION >> $LOGDIR/$AC_REVISION.log 2>&1
	  
    		STATUS=`LOGDIR=$LOGDIR MODULSDIR=$MODULSDIR REVISION=$AC_REVISION STATUSFD=$STATUSFD $TESTSCRIPT 5>&1 1>> $LOGDIR/$AC_REVISION.log 2>&1`
		echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
	  
		clean_revision >> $LOGDIR/$AC_REVISION.log 2>&1
	    else
		echo "$AC_REVISION $STATUS recheck" >> $LOGDIR/test.log
	    fi

	    case "$STATUS" in
		"failed")
	    	    if [ $AC_STARTREVISION = $AC_REVISION ]; then
			if [ $AC_STARTREVISION = $AC_ENDREVISION ]; then
			    FOUND=2
			else
			    AC_STARTREVISION=$AC_ENDREVISION
			fi 
		    else
			AC_STARTREVISION=$AC_REVISION
		    fi
		    ;;
		"ok")
	    	    if [ $AC_STARTREVISION = $AC_REVISION ]; then
			if [ $AC_ENDREVISION = $AC_STARTREVISION ]; then
			    FOUND=1
			 else
			    AC_ENDREVISION=$AC_STARTREVISION
			fi 
		    else
			AC_ENDREVISION=$AC_REVISION
		    fi
		    ;;
		"error")
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION"
		    exit 0;			
		    ;;
		*)
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION"
		    #TODO short this using tee
		    exit 0;
		    ;;
	    esac
	
	done
	
	if [ $FOUND -eq 1 ]; then
	    echo "Revision $AC_REVISION is the first successful version"
	    echo "Revision $AC_REVISION is the first successful version"  >> $LOGDIR/test.log
	fi
	
	if  [ $FOUND -eq 2 ]; then
	    echo "There is no successful version"
	    echo "There is no successful version"  >> $LOGDIR/test.log
	fi 
	
	;;
  "minfailed")
        test_parameters
        test_revision
	echo "Check for first not working version"
	echo "Revision: $STARTREVISION -> $ENDREVISION"
	echo "Check for first not working version in revisions $STARTREVISION -> $ENDREVISION" > $LOGDIR/test.log
	AC_STARTREVISION=$STARTREVISION
	AC_ENDREVISION=$ENDREVISION
	FOUND=0
		
	while [ $FOUND -eq 0 ]; do
	    AC_REVISION=`expr \( $AC_STARTREVISION + $AC_ENDREVISION \) / 2`
	
	    STATUS=`cat $LOGDIR/test.log | grep "^$AC_REVISION " | awk '{print $2}'`
	
	    if [ "x$STATUS" = "x" ]; then
        	echo "Test Revision $AC_REVISION"
        	install_revision $AC_REVISION >> $LOGDIR/$AC_REVISION.log 2>&1
	  
    	        STATUS=`LOGDIR=$LOGDIR MODULSDIR=$MODULSDIR REVISION=$AC_REVISION STATUSFD=$STATUSFD $TESTSCRIPT 5>&1 1>> $LOGDIR/$AC_REVISION.log 2>&1`
		echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
	  
		clean_revision >> $LOGDIR/$AC_REVISION.log 2>&1
	    else
		echo "$AC_REVISION $STATUS recheck" >> $LOGDIR/test.log
	    fi

	    case "$STATUS" in
		"ok")
	    	    if [ $AC_STARTREVISION = $AC_REVISION ]; then
			if [ $AC_STARTREVISION = $AC_ENDREVISION ]; then
			    FOUND=2
			else
			    AC_STARTREVISION=$AC_ENDREVISION
			fi 
		    else
			AC_STARTREVISION=$AC_REVISION
		    fi
		    ;;
		"failed")
	    	    if [ $AC_STARTREVISION = $AC_REVISION ]; then
			if [ $AC_ENDREVISION = $AC_STARTREVISION ]; then
			    FOUND=1
			else
			    AC_ENDREVISION=$AC_STARTREVISION
			fi 
		    else
			AC_ENDREVISION=$AC_REVISION
		    fi
		    ;;
		"error")
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION"
		    exit 0;			
		    ;;
		*)
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION"
		    #TODO short this using tee
		    ;;
	    esac
	
	done
	
	if [ $FOUND -eq 1 ]; then
	  echo "Revision $AC_REVISION is the first failed version"
	  echo "Revision $AC_REVISION is the first failed version"  >> $LOGDIR/test.log
	fi
	if  [ $FOUND -eq 2 ]; then
	  echo "There is no failed version"
	  echo "There is no failed version"  >> $LOGDIR/test.log
	fi 
	 
	;;
  "complete")
        test_parameters
	test_revision
	echo "Check all versions"
	echo "Revision: $STARTREVISION -> $ENDREVISION"
	echo "Check all versions $STARTREVISION -> $ENDREVISION" > $LOGDIR/test.log
	AC_REVISION=$STARTREVISION
	
	while [ $AC_REVISION -le $ENDREVISION ]; do
	    echo "Test Revision $AC_REVISION"
	    install_revision $AC_REVISION >> $LOGDIR/$AC_REVISION.log 2>&1
	  
    	    STATUS=`LOGDIR=$LOGDIR MODULSDIR=$MODULSDIR REVISION=$AC_REVISION STATUSFD=$STATUSFD $TESTSCRIPT 5>&1 1>> $LOGDIR/$AC_REVISION.log 2>&1`
	    case "$STATUS" in
		"ok")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"failed")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"error")
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION"
		    ;;
		*)
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION"
		    #TODO short this using tee
		    ;;
	    esac
		    
	    clean_revision >> $LOGDIR/$AC_REVISION.log 2>&1
	  
	    AC_REVISION=`expr $AC_REVISION + 1`
	done
	;;
  "completedown")
        test_parameters
	test_revision
	echo "Check all versions"
	echo "Revision: $STARTREVISION -> $ENDREVISION"
	echo "Check all versions $ENDREVISION -> $STARTREVISION" > $LOGDIR/test.log
	AC_REVISION=$ENDREVISION
	
	while [ $AC_REVISION -ge $STARTREVISION ]; do
	    echo "Test Revision $AC_REVISION"
	    install_revision $AC_REVISION >> $LOGDIR/$AC_REVISION.log 2>&1
	    
    	    STATUS=`LOGDIR=$LOGDIR MODULSDIR=$MODULSDIR REVISION=$AC_REVISION STATUSFD=$STATUSFD $TESTSCRIPT 5>&1 1>> $LOGDIR/$AC_REVISION.log 2>&1`
	    case "$STATUS" in
		"ok")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"failed")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"error")
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION"			
		    ;;
		*)
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION"
		    #TODO short this using tee
		    ;;
	    esac
		    
	    clean_revision >> $LOGDIR/$AC_REVISION.log 2>&1
	  
	    AC_REVISION=`expr $AC_REVISION - 1`
	done
	;;
  "single")
        test_parameters
	test_revision
	echo "Check all versions"
	echo "Revision: $REVISION"
	echo "Check all versions $REVISION" > $LOGDIR/test.log
	AC_REVISION=$REVISION
	echo "Test Revision $AC_REVISION"
	install_revision $AC_REVISION >> $LOGDIR/$AC_REVISION.log 2>&1
	
        STATUS=`LOGDIR=$LOGDIR MODULSDIR=$MODULSDIR REVISION=$AC_REVISION STATUSFD=$STATUSFD $TESTSCRIPT 5>&1 1>> $LOGDIR/$AC_REVISION.log 2>&1`
   	    case "$STATUS" in
		"ok")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"failed")
		    echo "$AC_REVISION $STATUS" >> $LOGDIR/test.log
		    ;;
		"error")
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript error on Revision $AC_REVISION"			
		    ;;
		*)
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/$AC_REVISION.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION" >> $LOGDIR/test.log
		    echo "FATAL: Testscript failed on Revision $AC_REVISION"
		    #TODO short this using tee
		    ;;
	    esac
          
	    clean_revision >> $LOGDIR/$AC_REVISION.log 2>&1
	  
	;;
  *)
	$0 help
	;;
esac

exit 0
