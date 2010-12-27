BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> t :: Tee()
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

  t[1]
  -> __WIFIDECAP__
  -> PrintWifi()
  -> Discard;