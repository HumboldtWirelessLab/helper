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

SCREENNAME="tunnel"

screensession() {

case "$1" in
	"start")
		screen -d -m -S $SCREENNAME
		sleep 0.2
		;;
	"stop")
		screen -S $SCREENNAME -X quit
		;;
	*)
		;;
esac

}

open_tunnel() {
	TUNNELLINE=`cat $DIR/../etc/roofnodes/ssh.conf | grep -v "#" | grep "^$2"`
	TARGETLINE=`cat $DIR/../etc/roofnodes/ssh.conf | grep -v "#" | grep "^$1"`

	NODE=`echo $TUNNELLINE | awk '{print $2}'`
	PORT=`echo $TUNNELLINE | awk '{print $3}'`
	USER=`echo $TUNNELLINE | awk '{print $4}'`
	KEY=`echo $TUNNELLINE | awk '{print $5}'`
	if [ -e $DIR/../etc/keys/$KEY ]; then
		KEY=$DIR/../etc/keys/$KEY
	fi

	TARGETNODE=`echo $TARGETLINE | awk '{print $2}'`
	TARGETPORT=`echo $TARGETLINE | awk '{print $3}'`
	TUNNELPORT=`echo $TARGETLINE | awk '{print $7}'`

	SCREENT="ssh_$1\_$2"

	screen -S $SCREENNAME -X screen -t $SCREENT
	sleep 0.2
	
	screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $KEY -p $PORT -R $TUNNELPORT:$TARGETNODE:$TARGETPORT $USER@$NODE"
	screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
}

close_tunnel() {
	SCREENT="ssh_$1\_$2"

	screen -S $SCREENNAME -p $SCREENT -X stuff "exit"
	screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
}


open_ssh() {
	CONFIGLINE=`cat $DIR/../etc/roofnodes/ssh.conf | grep -v "#" | grep "^$1"`
	TUNNELOVER=`echo $CONFIGLINE | awk '{print $6}'`

	if [ "x$TUNNELOVER" != "x-" ]; then
		open_tunnel $1 $TUNNELOVER
		NODE=`echo $CONFIGLINE | awk '{print $6}'`
		PORT=`echo $CONFIGLINE | awk '{print $7}'`
	else
		NODE=`echo $CONFIGLINE | awk '{print $2}'`
		PORT=`echo $CONFIGLINE | awk '{print $3}'`
	fi
	
	USER=`echo $CONFIGLINE | awk '{print $4}'`
	KEY=`echo $CONFIGLINE | awk '{print $5}'`

	if [ -e $DIR/../etc/keys/$KEY ]; then
		KEY=$DIR/../etc/keys/$KEY
	fi

	SCREENT="ssh_$1"

	screen -S $SCREENNAME -X screen -t $SCREENT
	sleep 0.2
	
	screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $KEY -p $PORT $USER@$NODE"
	screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
}

exec_ssh() {
	CONFIGLINE=`cat $DIR/../etc/roofnodes/ssh.conf | grep -v "#" | grep "^$1"`
	TUNNELOVER=`echo $CONFIGLINE | awk '{print $6}'`

	SCREENT="ssh_$1"

	screen -S $SCREENNAME -p $SCREENT -X stuff "$2"
	screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'

}

close_ssh() {
	exec_tunnel $1 exit
}


. $DIR/functions.sh

if [ "x$NODELIST" = "x" ] && [ "x$1" != "xhelp" ]; then
    	$0 help
	exit 0
fi

case "$1" in
	"help")
		echo "Use $0 run | info"
		echo "Use NODELIST"
		;;
	"run")
		screensession start
		open_tunnel localhost
		exec_tunnel localhost ls
		close_tunnel localhost		
		;;
	"info")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "/etc/init.d/watchdog start" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"settime")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "$DIR/../../nodes/bin/" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
