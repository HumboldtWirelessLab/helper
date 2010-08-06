BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
  
Script(
  wait RUNTIME,
  stop
);
