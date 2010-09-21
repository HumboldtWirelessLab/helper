gps::GPS();

//ath0 BRNAddressInfo(my_ath0 ath0:eth);
//ath1 BRNAddressInfo(my_ath1 ath1:eth);
//wlan2 BRNAddressInfo(my_wlan2 wlan2:eth);
//wlan3 BRNAddressInfo(my_wlan3 wlan3:eth);

rates :: AvailableRates(DEFAULT 2 4 11 22)
wifiinfo :: WirelessInfo(SSID "");

//ath0 FromDevice(ath0, PROMISC true, OUTBOUND true)
//ath0  -> GPSEncap(GPS gps)
//ath0  -> td :: ToDump("RESULTDIR/devel.ath0.dump");
//ath0 prath0::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_ath0, RT rates)
//ath0  -> SetTXRate(2)
//ath0  //-> PrintWifi()
//ath0  -> Ath2Encap(ATHENCAP true)
//ath0  -> NotifierQueue(50)
//ath0  -> ToDevice(ath0);
//ath0  Script(wait PROBETIME, write prath0.send_probe 0, loop);


//ath1 FromDevice(ath1, PROMISC true, OUTBOUND true)
//ath1  -> GPSEncap(GPS gps)
//ath1  -> td2 :: ToDump("RESULTDIR/devel.ath1.dump");
//ath1 prath1::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_ath1, RT rates)
//ath1  -> SetTXRate(2)
//ath1  //-> PrintWifi()
//ath1  -> Ath2Encap(ATHENCAP true)
//ath1  -> NotifierQueue(50)
//ath1  -> ToDevice(ath1);
//ath1  Script(wait PROBETIME, write prath1.send_probe 0, loop);

//wlan2 FromDevice(wlan2, PROMISC true, OUTBOUND true)
//wlan2  -> GPSEncap(GPS gps)
//wlan2  -> td3 :: ToDump("RESULTDIR/devel.wlan2.dump");
//wlan2 prwlan2::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_wlan2, RT rates)
//wlan2  -> SetTXRate(2)
//wlan2  -> RadiotapEncap()
//wlan2  -> NotifierQueue(50)
//wlan2  -> ToDevice(wlan2);
//wlan2  Script(wait PROBETIME, write prwlan2.send_probe 0, loop);

//wlan3 FromDevice(wlan3, PROMISC true, OUTBOUND true)
//wlan3  -> GPSEncap(GPS gps)
//wlan3  -> td4 :: ToDump("RESULTDIR/devel.wlan3.dump");
//wlan3 prwlan3::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_wlan3, RT rates)
//wlan3  -> SetTXRate(2)
//wlan3  -> RadiotapEncap()
//wlan3  -> NotifierQueue(50)
//wlan3  -> ToDevice(wlan3);
//wlan3  Script(wait PROBETIME, write prwlan3.send_probe 0, loop);

Script(
  write gps.gps_coord STARTGPS,
);

Script(
  wait RUNTIME,
  stop
);

ControlSocket(tcp, 7777);
