gps::GPS();

FROMRAWDEVICE(NODEDEVICE)
    -> GPSEncap(GPS gps)
    -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

SYNC
 -> td;
