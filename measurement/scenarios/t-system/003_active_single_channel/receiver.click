BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//-> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
  -> tdraw :: ToDump("/tmp/extra/NODENAME.NODEDEVICE.dump");
  
Script(
  wait RUNTIME,
  stop
);
