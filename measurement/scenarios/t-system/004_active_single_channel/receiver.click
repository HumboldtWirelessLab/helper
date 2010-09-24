BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//-> SimpleQueue(CAPACITY 500)
  -> ct::Counter()
//  ->Discard;
  -> tdraw::TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

Script(
  wait 55,
  read ct.count
);
