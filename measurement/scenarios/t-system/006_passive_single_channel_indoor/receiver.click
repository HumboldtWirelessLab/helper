BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
//  -> p::Counter()
    -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> td :: ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");
//  -> Discard;

SYNC
  -> td;
