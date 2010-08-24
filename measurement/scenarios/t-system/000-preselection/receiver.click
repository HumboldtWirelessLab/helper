gps::GPS();

BRNAddressInfo(my_wlan ath0:eth);

FromDevice(ath0, PROMISC true, OUTBOUND true)
  -> GPSEncap(GPS gps)
  -> td :: ToDump("RESULTDIR/devel.ath0.dump");

Script(
  write gps.gps_coord STARTGPS,
);

Script(
  wait RUNTIME,
  stop
);

ControlSocket(tcp, 7777);
