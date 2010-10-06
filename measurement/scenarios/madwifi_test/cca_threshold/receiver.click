BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> ct::Counter()
  -> tdraw::TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

Script(
  wait 55,
  read ct.count
);
