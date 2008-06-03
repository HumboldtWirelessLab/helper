AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> pw :: PrintWifi(TIMESTAMP true)
//->td :: ToDump("/home/sombrutz/Download/r.dump");
  ->Discard;
  
BRN2PacketSource(1000, 1000, my_wlan, ff:ff:ff:ff:ff:ff)
 -> SetTimestamp()
 -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);

wlan_out_queue
-> TODEVICE;

ftx[1]
-> Print("TX")
-> [0]ff;

ff[1]
-> Print("Failure")
-> [0]fphy;

fphy[1]
-> Print("Phy")
-> [0]pw;

Script(
  wait RUNTIME,
  stop
);
