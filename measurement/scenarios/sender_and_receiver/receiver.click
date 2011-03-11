BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> __WIFIDECAP__
  -> PrintWifi()
  -> Discard;
  //  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");
