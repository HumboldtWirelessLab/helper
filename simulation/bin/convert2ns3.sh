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
	"help")
		echo "Use $0 convert des-file"
		;;
	"convert")
	  . $2

	  NONODES=`cat $NODEPLACEMENTFILE | wc -l`

          cat $DIR/../etc/ns-3/nsclick-template_01.cc | sed "s#NUMBER_OF_NODES#$NONODES#g"
	  
	  NODE=1
          while read line; do
            X=`echo $line | awk '{print $2}'`
            Y=`echo $line | awk '{print $3}'`
            echo "positionAlloc->Add (Vector ($X, $Y, 0.0));"
            NODE=`expr $NODE + 1`
         done < $NODEPLACEMENTFILE

         cat $DIR/../etc/ns-3/nsclick-template_02.cc

         NODE=1
		while read line; do
		  NODENAME=`echo $line | awk '{print $1}'`
		  NODEDEVICE=`echo $line | awk '{print $2}'`
		  NODECONFIG=`echo $line | awk '{print $5}'`
		  NODECLICK=`echo $line | awk '{print $7}'`


		  if [ ! -f $NODECONFIG ]; then
		    if [ -f $DIR/../../nodes/etc/wifi/$NODECONFIG ]; then
                      NODECONFIG="$DIR/../../nodes/etc/wifi/$NODECONFIG"
		    else
		      if [ -f ./$NODECONFIG ]; then
		        NODECONFIG=./$NODECONFIG
                      else
		        NODECONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
		      fi
		    fi
		  fi

		  . $NODECONFIG

		    NODENUM=`expr $NODE - 1`

		     echo "ClickInternetStackHelper clickinternet$NODE;"
		    echo "clickinternet$NODE.SetClickFile (wifiNodes.Get ($NODENUM), \"$NODECLICK\");"
			echo "clickinternet$NODE.SetRoutingTableElement (wifiNodes.Get ($NODENUM), \"rt\");"
			echo "clickinternet$NODE.Install (wifiNodes.Get ($NODENUM));"
			    

		  NODE=`expr $NODE + 1`

		done < $NODETABLE
		
		cat $DIR/../etc/ns-3/nsclick-template_03.cc | sed "s#SIMNAME#$NAME#g" | sed "s#SIMDURATION#$TIME#g"
		
		;;
	*)
		$0 help
		;;
esac

exit 0
