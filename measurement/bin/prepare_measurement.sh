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

if [ "x$POSTFIX" = "x" ]; then
    POSTFIX="real"
fi

if [ "x$WORKDIR" = "x" ]; then
    WORKDIR=$pwd
fi

if [ -f $2 ]; then
    DISCRIPTIONFILE=$2
     .  $DISCRIPTIONFILE
else
     echo "$2 : No such file !"
     exit 0;
fi

BASEDIR=$DIR/../../

case "$1" in
	"help")
		echo "Use $0 prepare"
		echo "Tool wich prepares the final skripts for a measurement (run_single_measurement). Replaces Variables ind the skript (like NODENAME, NODEDEVICE, ...)"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS

		SIMDISBASENAME=`basename $SIMDIS`
		cat $SIMDIS | sed "s#$NODETABLE#$RESULTDIR/$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $RESULTDIR/$SIMDISBASENAME.$POSTFIX

		if [ "x$REMOTEDUMP" = "xyes" ]; then
                  if [ "x$DUMPPORTBASE" = "x" ]; then
		    DUMPPORTBASE=40000
		  fi
                  if [ "x$DUMPIP" = "x" ]; then
		    DUMPIP="192.168.3.100"
		  fi
	  
		  echo -n "" > $RESULTDIR/remotedump.map
		  echo -n "" > $RESULTDIR/remotedump.click
                fi		  

		#Prepare click
		echo -n "" > $RESULTDIR/$NODETABLE.$POSTFIX
		while read line; do
		    ISCOMMENT=`echo $line | grep "#" | wc -l`
		    NOSPACELINE=`echo $line | sed -e "s#[[:space:]]##g"`
		    
		    if [ ! "x$NOSPACELINE" = "x" ]; then
		        if [ $ISCOMMENT -eq 0 ]; then
			    
			    #read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line
			    CNODE=`echo $line | awk '{print $1}'`
			    CDEV=`echo $line | awk '{print $2}'`
			    CMODDIR=`echo $line | awk '{print $3}'`
			    CMODOPT=`echo $line | awk '{print $4}'`
			    WIFICONFIG=`echo $line | awk '{print $5}'`
			    CCMODDIR=`echo $line | awk '{print $6}'`
			    CLICK=`echo $line | awk '{print $7}'`
			    CCLOG=`echo $line | awk '{print $8}'`
			    CAPP=`echo $line | awk '{print $9}'`
			    CAPPL=`echo $line | awk '{print $10}'`
			
			    WIFICONFIG=`echo "$WIFICONFIG" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

			    ISGROUP=`echo $CNODE | grep "group:" | wc -l`
			    
			    if [ "x$ISGROUP" = "x1" ]; then
			      GROUP=`echo $CNODE | sed "s#group:##g"`
			      CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
			      #echo "NODES: $CNODE"
			    else
			      CNODES=$CNODE
			    fi
			    
			    for CNODE in $CNODES; do
			    
			      NODEINFILE=`cat $RESULTDIR/$NODETABLE.$POSTFIX | grep -e "^$CNODE[[:space:]]*$CDEV" | wc -l`
			      
			      if [ $NODEINFILE -ne 0 ]; then
			        #echo "Found node $CNODE with device $CDEV. Step over" 
			        continue
			      fi
			    
			      if [ ! "x$WIFICONFIG" = "x" ] && [ ! "x$WIFICONFIG" = "x-" ]; then
				if [ -f  $CONFIGDIR/$WIFICONFIG ]; then                                                                                                                                                   
				    . $CONFIGDIR/$WIFICONFIG
				    WIFICONFIGFINALNAME=$CONFIGDIR/$WIFICONFIG
				else
				    if [ -f  $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then                                                                                                                                                   
					. $DIR/../../nodes/etc/wifi/$WIFICONFIG
					WIFICONFIGFINALNAME="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
				    else
					if [ -f $WIFICONFIG ]; then
					    . $WIFICONFIG
					    WIFICONFIGFINALNAME="$WIFICONFIG"
					else
					    echo "Error: WIFICONFIG does'nt exist"
					    WIFICONFIGFINALNAME="-"
				        fi
				    fi
				fi
						
				case "$WIFITYPE" in
				    "801")
					WIFIENCAP="Null()"
					WIFIDECAP="Null()"
					;;
				    "802")
					WIFIENCAP="RadiotapEncap()"
					WIFIDECAP="RadiotapDecap()"
					;;
				    "803")
					WIFIENCAP="Prism2Encap()"
					WIFIDECAP="Prism2Decap()"
					;;
				    "804")
					WIFIENCAP="AthdescEncap()"
					WIFIDECAP="AthdescDecap()"
					;;
				    "805")
					WIFIENCAP="Ath2Encap(ATHENCAP\ttrue)"
					WIFIDECAP="Ath2Decap(ATHDECAP\ttrue)"
					;;
			    	    *)
					WIFIENCAP="Null()"
					WIFIDECAP="Null()"
					;;
				esac
			      else
				WIFICONFIGFINALNAME="-"
			      fi
			
			      if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
				CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`
			    
				if [ -e $CLICK ] || [ -e $CONFIGDIR/$CLICK ]; then
				    CLICKBASENAME=`basename $CLICK`
				    CLICKFINALNAME="$RESULTDIR/$CLICKBASENAME.$CNODE.$CDEV"
				    if [ "x$DEBUG" = "x" ]; then
				      DEBUG=2
				    else
				      if [ $DEBUG -gt 4 ] || [ $DEBUG -lt 0 ]; then
				        DEBUG=2
				      fi
        			    fi
				    
				    echo -n "" > $CLICKFINALNAME
				    
				    ###################
				    ### Remote Dump ###
				    ###################
                                    if [ "x$REMOTEDUMP" = "xyes" ]; then
				      NODUMP=`(cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "TODUMP" | wc -l)`
				      
				      NODEDUMPNR=1
				      
				      DUMPSEDARG=" -e s#-#-#g"
				      
				      while [ $NODEDUMPNR -le $NODUMP ]; do
                                        DUMPLINE=`( cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "TODUMP" | head -n $NODEDUMPNR | tail -n 1 | sed -e "s#^.*TODUMP(##g" -e "s#).*##g" )`
					echo "$CNODE $CDEV $NODEDUMPNR $DUMPLINE $DUMPIP $DUMPPORTBASE" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" >> $RESULTDIR/remotedump.map
					NODEDUMPNR=`expr $NODEDUMPNR + 1`
					DUMPPORTBASE=`expr $DUMPPORTBASE + 1`
					
			                if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" = "xuserlevel" ]; then
					  DUMPSEDARG="$DUMPSEDARG -e s#TODUMP\(.*$DUMPLINE.*\)#Socket\(UDP,$DUMPIP,$DUMPPORTBASE,CLIENT\ttrue\)->Discard#g"
					else
					  echo "BRNAddressInfo(ethdev eth0:eth);" >> $CLICKFINALNAME
					  echo "BRNAddressInfo(ipdev eth0:ip);" >> $CLICKFINALNAME
					  DUMPSEDARG="$DUMPSEDARG -e s#TODUMP\(.*$DUMPLINE.*\)#UDPIPEncap(SRC\tipdev,SPORT\t30000,DST\t$DUMPIP,DPORT\t$DUMPPORTBASE,CHECKSUM\tfalse,ALIGNFIX\ttrue)\n\t->EtherEncap(ETHERTYPE\t0x0800,SRC\tethdev,DST\t$DUMPMAC)->ethq::SimpleQueue(CAPACITY\t500)->ToDevice(eth0);#g"
					fi
					  
					echo "Idle->Socket(UDP,$DUMPIP,$DUMPPORTBASE,$DUMPIP,$DUMPPORTBASE)->ToDump("$DUMPLINE");" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" >> $RESULTDIR/remotedump.click
			              done
				    else
				      DUMPSEDARG=" -e s#TODUMP#ToDump#g"
				    fi
			        
    				    #echo "SED: $DUMPSEDARG"
	                            DEBUGSEDARG="-e s#//[0-$DEBUG]/##g -e s#/\*[0-$DEBUG]/##g -e s#/[0-$DEBUG]\*/##g -e s#DEBUGLEVEL#$DEBUG#g"
				    FROMTODEVICESEDARG="-e s#FROMDEVICE#FROMRAWDEVICE->WIFIDECAPTMPL#g -e s#TODEVICE#WIFIENCAPTMPL->TORAWDEVICE#g"
				    DIRSEDARG="-e s#NODEDEVICE#$CDEV#g -e s#NODENAME#$CNODE#g -e s#RUNTIME#$TIME#g -e s#RESULTDIR#$RESULTDIR#g -e s#WORKDIR#$WORKDIR#g -e s#BASEDIR#$BASEDIR#g"

				    if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" = "xuserlevel" ]; then
				      DEVICESEDARG="-e s#WIFIDECAPTMPL#$WIFIDECAP#g -e s#WIFIENCAPTMPL#$WIFIENCAP#g -e s#FROMRAWDEVICE#FromDevice(NODEDEVICE,PROMISC\ttrue,OUTBOUND\ttrue,SNIFFER\tfalse)#g -e s#TORAWDEVICE#ToDevice(NODEDEVICE)#g"
				      SYNCARG="-e s#SYNC#Idle\n\t->Socket(UDP,0.0.0.0,60000)\n\t->Print(\"Sync\",TIMESTAMP\ttrue)#g"
				    else
				      DEVICESEDARG="-e s#WIFIDECAPTMPL#$WIFIDECAP#g -e s#WIFIENCAPTMPL#$WIFIENCAP#g -e s#FROMRAWDEVICE#FromDevice(NODEDEVICE)#g -e s#TORAWDEVICE#ToDevice(NODEDEVICE)#g"
				      SYNCARG="-e s#SYNC#FromHost(sync0,192.168.20.1\/24)\n\t->fhc::Classifier(12/0806,12/0800)\n\t->ARPResponder(0.0.0.0/0\t1:1:1:1:1:1)\n\t->ToHost(sync0);\nfhc[1]\n\t->Strip(14)\n\t->MarkIPHeader()\n\t->StripIPHeader()\n\t->max::CheckLength(12)[1]\n\t->Discard;\nmax[0]\n\t->Strip(8)\n\t//->Print(TIMESTAMP\ttrue)#g"
				    fi

				    ( cd $CONFIGDIR; cat $CLICK | sed $DEBUGSEDARG | sed $FROMTODEVICESEDARG | sed $DEVICESEDARG | sed $SYNCARG | sed $DUMPSEDARG | sed $DIRSEDARG >> $CLICKFINALNAME )
				    
				    echo "Script(wait $TIME, stop);" >> $CLICKFINALNAME
				    
				    if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" = "xuserlevel" ]; then
				      if [ "x$CONTROLSOCKET" != "xno" ]; then
				        echo "ControlSocket(tcp, 7777);" >> $CLICKFINALNAME
				      fi
				    fi
				    
				  else
				    CLICKFINALNAME="-"
				  fi
			      else
			   	CLICKFINALNAME="-"
			      fi
			
			      echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIGFINALNAME $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" -e "s#NODENAME#$CNODE#g" -e "s#NODEDEVICE#$CDEV#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

                          done
			fi
		    fi
		done < $CONFIGDIR/$NODETABLE
		
		if [ "x$REMOTEDUMP" = "xyes" ]; then
		  REMOTEDUMPTIME=`expr $TIME + 5`
		  echo "Script(wait $REMOTEDUMPTIME, stop);" >> $RESULTDIR/remotedump.click
		fi
		
				
		;;
	*)
		$0 help
		;;
esac

exit 0
