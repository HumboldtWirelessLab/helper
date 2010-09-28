BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

SYNC
  -> tdraw;
