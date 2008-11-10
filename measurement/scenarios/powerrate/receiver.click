BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

Script(
  wait RUNTIME,
  stop
);
