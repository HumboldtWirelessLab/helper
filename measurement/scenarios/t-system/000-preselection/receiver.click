gps::GPS();

BRNAddressInfo(my_wlan ath0:eth);

FromDevice(ath0, PROMISC true, OUTBOUND true)
  -> GPSEncap(GPS gps)
  -> td :: ToDump("RESULTDIR/devel.ath0.dump");

Script(
  write gps.gps_coord 0.0 0.0 0.0,
);

Script(
  wait RUNTIME,
  stop
);

ControlSocket(udp, 7777);