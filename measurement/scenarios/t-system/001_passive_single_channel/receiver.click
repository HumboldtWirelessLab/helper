BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//  -> p::Counter()
    -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> td :: ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");
//  -> Discard;


Idle
  -> Socket(UDP, 0.0.0.0, 60000)
  -> Print("Sync",TIMESTAMP true)
  -> Discard;
