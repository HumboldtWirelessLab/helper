#!/bin/sh

add_include() {
  if [ "x$1" = "x" ]; then
    echo "#include \"brn/helper.inc\""
  fi
  cat <&0
  echo ""
  echo "#include \"brn/helper_tools.inc\""
}


get_wifitype() {
 NODEARCH=`cat $5 | grep $1 | awk '{print $2}'`
 KERNELVERSION=`cat $5 | grep $1 | awk '{print $3}'`
 MODOPTIONS=$4 MODULSDIR=$3 KERNELVERSION=$KERNELVERSION NODEARCH=$NODEARCH $HELPERDIR/nodes/bin/wlanmodules.sh wifi_type
}
