BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
    -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> Idle;

SYNC
 -> td;