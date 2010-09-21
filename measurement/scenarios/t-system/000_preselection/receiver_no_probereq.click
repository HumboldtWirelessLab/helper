gps::GPS();

BRNAddressInfo(my_wlan ath0:eth);

//ath0 FromDevice(ath0, PROMISC true, OUTBOUND true)
//ath0  -> GPSEncap(GPS gps)
//ath0  -> td :: ToDump("RESULTDIR/devel.ath0.dump");

//ath1 FromDevice(ath1, PROMISC true, OUTBOUND true)
//ath1  -> GPSEncap(GPS gps)
//ath1  -> td2 :: ToDump("RESULTDIR/devel.ath1.dump");

//wlan2 FromDevice(wlan2, PROMISC true, OUTBOUND true)
//wlan2  -> GPSEncap(GPS gps)
//wlan2  -> td3 :: ToDump("RESULTDIR/devel.wlan2.dump");

//wlan3 FromDevice(wlan3, PROMISC true, OUTBOUND true)
//wlan3  -> GPSEncap(GPS gps)
//wlan3  -> td4 :: ToDump("RESULTDIR/devel.wlan3.dump");

Script(
  write gps.gps_coord STARTGPS,
);

Script(
  wait RUNTIME,
  stop
);

ControlSocket(tcp, 7777);
