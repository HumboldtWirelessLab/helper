#!/bin/sh
TARGETHOST=localhost

if [ "x$1" = "x" ]; then
  echo "Use $0 number"
  exit 0
fi

echo "Kill screen"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall screen" > /dev/null 2>&1
echo "Kill click"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall click" > /dev/null 2>&1
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall screen" > /dev/null 2>&1

echo "Restart gpsd"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "/etc/init.d/gpsd restart" > /dev/null 2>&1

NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "rmmod ath5k" > /dev/null 2>&1

RUNMODE=REBOOT ../../../bin/run_measurement.sh receiver.dis $1

