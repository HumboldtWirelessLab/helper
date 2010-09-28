BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
    -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//    -> td :: ToDump("/tmp/extra/mess_2/NODENAME.NODEDEVICE.dump"/*, SNAPLEN 150*/);

SYNC
 -> td;