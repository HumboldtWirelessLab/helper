BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> tdraw :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> tdraw :: ToDump("/tmp/extra/voip/NODENAME.NODEDEVICE.dump");

SYNC
  -> tdraw;
