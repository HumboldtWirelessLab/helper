#!/bin/bash

MOD=`/sbin/modinfo $MODULSDIR/wlan.ko | grep "^version" | awk '{print $3}' | sed -e "s/r/\ /g"`

echo "revision is $MOD"

if [ $MOD -gt 3574 ]; then
  echo "ok" 1>&$STATUSFD
else
  echo "failed" 1>&$STATUSFD
fi

exit 0
 