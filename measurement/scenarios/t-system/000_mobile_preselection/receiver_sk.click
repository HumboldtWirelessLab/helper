gps::GPS();

FROMRAWDEVICE(ath0)
    -> GPSEncap(GPS gps)
    -> td :: ToDump("RESULTDIR/NODENAME.ath0.dump");

FROMRAWDEVICE(ath1)
    -> GPSEncap(GPS gps)
    -> td2 :: ToDump("RESULTDIR/NODENAME.ath1.dump");

SYNC
 -> t::Tee()
 -> td;

t[1]
 -> td2;
