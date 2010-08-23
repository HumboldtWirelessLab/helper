gps::GPS();

BRNAddressInfo(my_wlan ath0:eth);

FromDevice(ath0, PROMISC true, OUTBOUND true)
  -> GPSEncap(GPS gps)
  -> td :: ToDump("RESULTDIR/devel.ath0.dump");


Script(
  write gps.gps_coord 52.521111 13.41 0.0,
);

Script(
  wait RUNTIME,
  stop
);
