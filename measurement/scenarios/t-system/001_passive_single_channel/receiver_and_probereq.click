BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//  -> rawtee :: Tee()
//  -> Ath2Decap( ATHDECAP true )
//  -> ftx :: FilterTX()
//  -> ff :: FilterFailures()
//  -> fphy :: FilterPhyErr()
//  -> Print("Raw")
//  -> pw :: PrintWifi(TIMESTAMP true)
//  -> Discard();
  
//  rawtee[1]
    -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//    -> td :: ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");
//  -> Idle;


rates :: AvailableRates(DEFAULT 2 4 11 22)
wifiinfo :: WirelessInfo(SSID "");

probereq::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_wlan, RT rates)
-> WIFIENCAPTMPL
-> q :: NotifierQueue(50)
-> TORAWDEVICE;

Script(wait 10, write probereq.send_probe 0, loop);

Script(
  wait RUNTIME,
  stop
);
