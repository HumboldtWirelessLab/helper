BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
    -> td :: TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> td :: ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");

rates :: AvailableRates(DEFAULT 2 4 11 22)
wifiinfo :: WirelessInfo(SSID "");

probereq::ProbeRequester(WIRELESS_INFO wifiinfo, ETH my_wlan, RT rates)
-> __WIFIENCAP__
-> q :: NotifierQueue(50)
-> TORAWDEVICE(NODEDEVICE);

SYNC
 -> td;

Script(wait 10, write probereq.send_probe 0, loop);
