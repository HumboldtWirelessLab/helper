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

. $DIR/../../measurement/etc/wifitypes

add_include() {
  if [ "x$1" = "x0" ]; then
    echo "#include \"brn/helper.inc\""
  fi
  cat <&0
  echo ""
  echo "#include \"brn/helper_tools.inc\""  
}

if [ "x$POSTFIX" = "x" ]; then
    POSTFIX="simulation"
fi

BASEDIR=$DIR/../../

if [ "x$USED_SIMULATOR" = "x" ]; then
  USED_SIMULATIOR=ns
fi

if [ "$USED_SIMULATOR" != "jist" ] && [ "$USED_SIMULATOR" != "ns" ] && [ "$USED_SIMULATOR" != "ns3" ]; then
  echo "USED_SIMULATOR is unknown ($USED_SIMUALTOR). Use ns, ns3 or jist."
  exit 0
fi

if [ "x$LOGLEVEL" = "x1" ]; then echo "sim is $USED_SIMULATOR"; fi

case "$1" in
	"help")
		echo "Use $0 prepare des-file"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS
		
		if [ "x$WORKDIR" = "x" ]; then
		    WORKDIR=$RESULTDIR
		fi

		ALLNODES="| "`cat $CONFIGDIR/$NODETABLE`

		MES_VAR=""

		declare -A nodes_in_map

		while read line; do
		    ISCOMMENT=`echo $line | grep "#" | wc -l`
		    if [ $ISCOMMENT -eq 0 ]; then

	              read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line

	              ISGROUP=`echo $CNODE | grep "group:" | wc -l`

		      if [ "x$ISGROUP" = "x1" ]; then
		        GROUP=`echo $CNODE | sed "s#group:##g"`
			HASLIMIT=`echo $GROUP | grep ":" | wc -l`
			
			if [ $HASLIMIT -eq 1 ]; then
			  GROUP_LIMIT=`echo $GROUP | sed -e "s#.*:##g"`
			  GROUP=`echo $GROUP | sed -e "s#:.*##g"`
			  #echo "$GROUP $GROUP_LIMIT"
			else
			  GROUP_LIMIT=0
			fi

		        CNODES=`grep -v "#" $CONFIGDIR/$GROUP`
		        #echo "NODES: $CNODE"
		      else
	                ISRANDOM=`echo $CNODE | grep "random:" | wc -l`
			
			LIMIT=`echo $CNODE | sed "s#random:##g"`
			
			if [ $ISRANDOM -gt 0 ] && [ "x$LIMIT" != "x" ]; then
			  NO_NODES=0
			  AC_NODEID=1
			
			  CNODES=""
			  while [ $NO_NODES -lt $LIMIT ]; do
			    NEW_NODE="node$AC_NODEID"

			    let AC_NODEID=AC_NODEID+1

			    NODEINFILE=`echo $ALLNODES | grep -e "[[:space:]]$NEW_NODE[[:space:]]" | wc -l`

			    ncheck=${nodes_in_map[$NEW_NODE]}

			    if [ "x$ncheck" = "x" ] && [ $NODEINFILE -eq 0 ]; then
			      CNODES="$CNODES $NEW_NODE"
			      let NO_NODES=NO_NODES+1
			    fi

			  done

			  GROUP_LIMIT=0

			else
		          CNODES=$CNODE
			  GROUP_LIMIT=0
			fi
        	      fi

                      NODES_OF_GROUP=0

		      if [ "x$USED_SIMULATOR" = "xns" ] || [ "x$USED_SIMULATOR" = "xns3" ]; then
			  DEVICE_TMPL=`echo $CDEV | grep "DEV" | wc -l`
			  if [ $DEVICE_TMPL -eq 0 ]; then
			    CDEV=eth0
			  else
			    CDEV=`echo $CDEV | sed "s#DEV##g"`
			    CDEV="eth$CDEV"
			  fi
		      else
			  DEVICE_TMPL=`echo $CDEV | grep "DEV" | wc -l`
			  if [ $DEVICE_TMPL -eq 0 ]; then
			    CDEV=ath0
			  else
			    CDEV=`echo $CDEV | sed "s#DEV##g"`
			    CDEV="ath$CDEV"
			  fi
                      fi

                if [ "x$DEBUG" = "x" ]; then
                  DEBUG=2
                else
                  if [ $DEBUG -gt 4 ] || [ $DEBUG -lt 0 ]; then
                    DEBUG=2
                  fi
                fi

                if [ ! -f $WIFICONFIG ]; then
                  if [ -f $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
		  else
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
		  fi
		fi

		. $WIFICONFIG

		#echo "$WIFICONFIG"

	  if [ "x$USED_SIMULATOR" = "xjist" ]; then
		  cp $WIFICONFIG $RESULTDIR

		  if [ "x$WIFITYPE" = "x" ] || [ "x$WIFITYPE" = "x0" ] || [ "x$WIFITYPE" = "xDEFAULT" ]; then
		    WIFITYPE=$WIFITYPE_EXTRA
		  fi
		  if [ "x$WIFITYPE" != "x$WIFITYPE_EXTRA" ] && [ "x$WIFITYPE" != "x$WIFITYPE_ATH" ] && [ "x$WIFITYPE" != "x$WIFITYPE_ATH2" ]; then
		    WIFITYPE=$WIFITYPE_EXTRA
		  fi
#TODO: don't force to use extra encap
		  WIFITYPE=$WIFITYPE_EXTRA
		else
		  #read wificonfig for aifs, cwmin etc.
		  #Hint: already done
		  #but overwrite wifitype, since ns2 only support wifiextra
		  WIFITYPE=$WIFITYPE_EXTRA
		fi

		STARTCPPOPTS=""
    STARTCPPOPTS="$STARTCPPOPTS -DNODEDEVICE=$CDEV -DTIME=$TIME"
    STARTCPPOPTS="$STARTCPPOPTS -DDEBUGLEVEL=$DEBUG"
    STARTCPPOPTS="$STARTCPPOPTS -DSIMULATION"

		if [ "x$USED_SIMULATOR" = "xns" ] && [ "x$GUICONNECTOR" = "xyes" ]; then
		  STARTCPPOPTS="$STARTCPPOPTS -DGUICONNECTOR" 
		fi

		if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`
			if [ -e $CLICK ] || [ -e $CONFIGDIR/$CLICK ]; then
				 CLICKBASENAME=`basename $CLICK`
				 HAS_BRNINCLUDE=`grep '#include "brn/helper.inc"' $CLICK | wc -l`

				 NODEID_INC=`(cd $CONFIGDIR; grep -v "^//" $CLICK | grep "BRN2NodeIdentity" | wc -l)`

				 if [ $NODEID_INC -gt 0 ]; then
					 STARTCPPOPTS="$STARTCPPOPTS -DNODEID_NAME"
				 fi

			else
				 CLICK="-"
			fi
		fi

		NODE_IN_CNODES=1

#		echo "tab start" >> $RESULTDIR/time.log
#		date +"%s:%N" >> $RESULTDIR/time.log

		declare -A cnodes_map

		for CNODE in $CNODES; do

			if [ $GROUP_LIMIT -ne 0 ] && [ $NODES_OF_GROUP -eq $GROUP_LIMIT ]; then
			    #echo "Reach Nodeslimit: $NODES_OF_GROUP of $GROUP_LIMIT"
			    break;
			fi

			ncheckkey="$CNODE$CDEV"
			#check whether node is already in group or in the file (e.g. other group)
			ncheck=${cnodes_map[$ncheckkey]}
			map_ncheck=${nodes_in_map[$CNODE]}
			if [ "x$ncheck" != "x" ] || [ "x$map_ncheck" != "x" ]; then
			  continue
			else
			  let NODES_OF_GROUP=NODES_OF_GROUP+1
			fi
			
			cnodes_map[$ncheckkey]=$ncheckkey
			nodes_in_map[$CNODE]=$CNODE

      if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
        if [ "x$USE_SINGLE_CLICKFILE" = "x1" ] ; then
          CLICKFINALNAME="$RESULTDIR/$CLICKBASENAME.$CDEV"
        else
          CLICKFINALNAME="$RESULTDIR/$CLICKBASENAME.$CNODE.$CDEV"
  	    fi

				NODEWIFITYPE=$WIFITYPE

				CPPOPTS="$STARTCPPOPTS"
		
				#echo "DUMP: $DUMPFILEDIR" >> $RESULTDIR/debug.txt
				if [ "x$DUMPFILEDIR" != "x" ]; then
					if  [ -e $PWD/$DUMPFILEDIR ]; then
						DUMPFILEDIR=$PWD/$DUMPFILEDIR
					fi
					DUMPFILESRC="$DUMPFILEDIR/$CNODE.$CDEV.raw.dump"
					#echo "SRC: $DUMPFILESRC" >> $RESULTDIR/debug.txt
					if [ -e $DUMPFILESRC ]; then
						NODEWIFITYPE=`test_header.sh $DUMPFILESRC`
						#echo "WIFI: $NODEWIFITYPE" >> $RESULTDIR/debug.txt
						CPPOPTS="$CPPOPTS -DDUMPDEVICE -DDUMPFILESRC=\"$DUMPFILESRC\""
						#echo "CPPOPTS: $CPPOPTS" >> $RESULTDIR/debug.txt
					fi
				fi

				CPPOPTS="$CPPOPTS -DNODEDEVICE=$CDEV"

				if [ "x$USE_SINGLE_CLICKFILE" = "x1" ] ; then
					if [ $NODE_IN_CNODES -eq 1 ]; then
						CPPOPTS="$CPPOPTS -DNODENAME=auto -DWIFITYPE=$NODEWIFITYPE"
						( cd $CONFIGDIR; cat $CLICK | add_include $HAS_BRNINCLUDE | cpp -I$DIR/../../measurement/etc/click $CPPOPTS | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" | grep -v "^#" > $CLICKFINALNAME ) &
					fi
					let NODE_IN_CNODES=NODE_IN_CNODES+1
				else
					CPPOPTS="$CPPOPTS -DNODENAME=$CNODE -DWIFITYPE=$NODEWIFITYPE"
					( cd $CONFIGDIR; cat $CLICK | add_include $HAS_BRNINCLUDE | cpp -I$DIR/../../measurement/etc/click $CPPOPTS | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" | grep -v "^#" > $CLICKFINALNAME ) &
				fi
			else
				CLICKFINALNAME="-"
			fi

			MES_VAR="$MES_VAR$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIG $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL\n"

	done

	unset cnodes_map

#          echo "tab fin" >> $RESULTDIR/time.log
#          date +"%s:%N" >> $RESULTDIR/time.log

      fi
		done < $CONFIGDIR/$NODETABLE

		echo -e -n $MES_VAR | sed -e "s#LOGDIR#$LOGDIR#g" -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $RESULTDIR/$NODETABLE.$POSTFIX
		
		unset nodes_in_map

		;;
	"cleanup")
		echo "Not supported"
		;;
	*)
		$0 help
		;;
esac

exit 0		
